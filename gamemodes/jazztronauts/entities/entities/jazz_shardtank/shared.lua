AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = "models/sunabouzu/shard_tank.mdl"

ENT.ActivateRadius = 300
ENT.AnimationActivated = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "CollectedShards")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)

        self:SetSequence(self:LookupSequence("Fill_Tank"))

        self:SetCollectedShards(progress.GetMapShardCount())

        local ending, isended = newgame.GetGlobal("ending"), tobool(newgame.GetGlobal("ended"))

        -- If above shard threshold, spawn the group vote to start endgame
        if not ending and not isended and progress.GetMapShardCount() >= mapgen.GetTotalRequiredShards() then
            local voter = ents.Create("jazz_vote_podiums")
            voter:SetKeyValue("PodiumRadius", 100)
            voter:SetKeyValue("ApproachRadius", self.ActivateRadius)
            voter:SetPos(self:GetPos())
            voter:Spawn()
            voter:Activate()
            voter:StoreActivatedCallback(function(who_found)
                self:OnStartGoodEnd()
            end )

            self.EndgameVoter = voter
        end
    end

    function ENT:OnStartGoodEnd()
        newgame.SetGlobal("ending", newgame.ENDING_ASH)

        mapcontrol.Launch(mapcontrol.GetEndMaps()[newgame.ENDING_ASH])
    end

else
    ENT.TankAmbientSound = "ambient/water/water_in_boat1.wav"
    ENT.TankSplashSounds = {
        "ambient/water/water_splash1.wav",
        "ambient/water/water_splash2.wav",
        "ambient/water/water_splash3.wav"
    }
    ENT.TankIncreaseSound = "jazztronauts/jazz_tank_choir.wav"

    ENT.FinishedAnimation = false
    ENT.AnimationStartShards = 0
    ENT.AnimShardCount = 0
    ENT.AnimShardRate = 8 --shards per second to drop into shard soup

    ENT.GoalCompletePercent = 0

    local sizeX = 256
    local sizeY = 256
    local screen_rt = irt.New("jazz_shardtank_screen", sizeX, sizeY)

    surface.CreateFont( "JazzShardTankFont", {
        font = "KG Shake it Off Chunky",
        extended = false,
        size = 65,
        weight = 500,
        antialias = true,
    } )

    surface.CreateFont( "JazzShardTankSubtextFont", {
        font = "KG Shake it Off Chunky",
        extended = false,
        size = 25,
        weight = 500,
        antialias = true,
    } )

    function ENT:Initialize()
        self:SetSequence(self:LookupSequence("Fill_Tank"))
    end

    function ENT:CheckSound()
        
        if not self.TankAmbient then
            self.TankAmbient = CreateSound(self, self.TankAmbientSound) 
            self.TankAmbient:SetSoundLevel(50)
            self.TankAmbient:Play()
            self.TankAmbient:ChangePitch(45)
            self.TankAmbient:ChangeVolume(0)
        end

        if not self.TankFill then
            self.TankFill = CreateSound(self, self.TankIncreaseSound)
            self.TankFill:SetSoundLevel(60)
            self.TankFill:Play()
            //self.TankFill:ChangePitch(45)
            self.TankFill:ChangeVolume(0)
        end
    end

    function ENT:OnRemove()
        if self.TankAmbient then
            self.TankAmbient:Stop()
            self.TankAmbient = nil
        end

        if self.TankFill then
            self.TankFill:Stop()
            self.TankFill = nil
        end
    end

    function ENT:GetCollectedShardCount()
        return self.AnimShardCount
    end

    function ENT:GetLiquidLevel()
        return self:GetPos() + Vector(0, 0, 1) * self:GetCompletePercent() * 110 + Vector(0, 0, 10)
    end

    function ENT:GetCompletePercent()
        local c = self:GetCollectedShardCount()
        local t = mapgen.GetTotalRequiredShards()

        return c * 1.0 / t
    end

    function ENT:DoShardAnimation(delay, last)
        coroutine.wait(delay)

        local shard = ManagedCSEnt("jazz_shardtank_" .. delay, "models/sunabouzu/jazzshard.mdl")
        shard:SetNoDraw(false)
        shard:SetPos(self:GetPos() + Vector(0, 0, 400))
        shard:SetAngles(AngleRand())
        local t = 0
        local endt = 1.0
        while t < endt do
            t = t + FrameTime() 
            local p = t / endt
            local pos = 400 * (1 - math.pow(p, 2))

            shard:SetPos(self:GetPos() + Vector(0, 0, pos))
            coroutine.yield()
        end

        shard:SetNoDraw(true)

        self.AnimShardCount = math.Approach(self.AnimShardCount, self:GetCollectedShards(), 1)

        local waterLevel = self:GetLiquidLevel()

        local completePerc = self:GetCompletePercent()
        if self.TankAmbient then
            self.TankAmbient:ChangeVolume(math.min(0.8, completePerc * 4))
        end

        if self.TankFill then
            self.TankFill:ChangeVolume(1.0)
            self.TankFill:ChangePitch(50 + completePerc * 75)

            if last then 
                self.TankFill:ChangeVolume(0.0, 4)
            end
        end

        -- Sound effects
        self:EmitSound(table.Random(self.TankSplashSounds), 75, 100, 0.3)
        
        -- Splash effect
        local effectdata = EffectData()
        effectdata:SetOrigin( waterLevel )
        effectdata:SetMagnitude(4)
        effectdata:SetScale(0.25)
        effectdata:SetRadius(0.25)
        effectdata:SetEntity(self)
        util.Effect("ElectricSpark", effectdata)

    end

    function ENT:DoAllShardAnimation()
        local curShards = self.AnimShardCount
        local numShards = self:GetCollectedShards()
        local numIterations = 0
        
        self.AnimCoroutines = self.AnimCoroutines or {}
        while curShards != numShards do
            curShards = math.Approach(curShards, numShards, 1)
            numIterations = numIterations + 1

            local delay = numIterations / self.AnimShardRate
            local co = coroutine.create(self.DoShardAnimation)
            table.insert(self.AnimCoroutines, co)
            coroutine.resume(co, self, delay, curShards == numShards)
        end
    end

    function ENT:TickAnimCoroutines()
        if not self.AnimCoroutines then return end
        for i=#self.AnimCoroutines, 1, -1 do
            local co = self.AnimCoroutines[i]
            local succ, err
            succ = coroutine.status(co) != "dead"
            if succ then
                succ, err = coroutine.resume(co)
            end

            if not succ then 
                if err then ErrorNoHalt(err) end
                table.remove(self.AnimCoroutines, i)
            end
        end
    end

    function ENT:ShouldActivate()
        local dist2 = (LocalPlayer():EyePos() - self:GetPos()):LengthSqr()
        
        return dist2 < math.pow(self.ActivateRadius, 2)
    end

    function ENT:Think()
        if not self.AnimationActivated then
            if not self:ShouldActivate() then
                return
            else 
                self.AnimationActivated = true
            end
        end

        if not self.AnimCoroutines or #self.AnimCoroutines == 0 then
            if self.AnimShardCount != self:GetCollectedShards() then
                self:DoAllShardAnimation()
            end
        end
        self:TickAnimCoroutines()
        self:CheckSound()

        self.GoalCompletePercent = Lerp(FrameTime() * 1, self.GoalCompletePercent or 0, self:GetCompletePercent())
        self:SetCycle(self.GoalCompletePercent + math.sin(CurTime() * 2) * 0.007)

        //self.AnimShardCount = math.Approach(self.AnimShardCount, self:GetCollectedShards(), 1)
    end

    function ENT:DrawRTScreen()
        screen_rt:Render(function()
            local c = HSVToColor(math.NormalizeAngle(CurTime() * 40), 0.8, 0.5)
            render.Clear(c.r, c.g, c.b, 255)
            cam.Start2D()
                local ctext = self:GetCollectedShardCount() .. " shards"
                local ntext = mapgen.GetTotalRequiredShards() .. " needed"

                draw.SimpleText(ctext, "JazzShardTankFont", sizeX / 2, sizeY / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(ntext, "JazzShardTankSubtextFont", sizeX / 2, sizeY / 1.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)  
            cam.End2D()
		end)
    end

    function ENT:Draw()
        self:DrawRTScreen()
        render.MaterialOverrideByIndex(3, screen_rt:GetUnlitMaterial())
        self:DrawModel()
        render.MaterialOverrideByIndex(3, nil)
    end
end