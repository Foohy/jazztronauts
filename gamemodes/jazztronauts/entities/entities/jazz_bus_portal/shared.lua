-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model = "models/sunabouzu/bus_breakableWall.mdl"

ENT.GibModels = {}
for i=1, 37 do 
    local path = "models/sunabouzu/gib_bus_breakablewall_gib" .. i .. ".mdl"
    util.PrecacheModel(path)
    table.insert(ENT.GibModels, path)
end

ENT.VoidModels = {
    "models/sunabouzu/oleg_is_cool.mdl",
    "models/Gibs/HGIBS.mdl",
    "models/props_junk/ravenholmsign.mdl",
    "models/props_interiors/BathTub01a.mdl",
    "models/player/skeleton.mdl"
}

ENT.VoidSphereModel = "models/hunter/misc/sphere375x375.mdl"
ENT.VoidBorderModel = "models/sunabouzu/bus_brokenwall.mdl"
ENT.VoidRoadModel = "models/sunabouzu/jazzroad.mdl"
ENT.VoidTunnelModel = "models/sunabouzu/jazztunnel.mdl"

ENT.BackgroundHumSound = "ambient/levels/citadel/zapper_ambient_loop1.wav"

ENT.RTSize = 1024
ENT.Size = 184

local zbumpMat = Matrix()
zbumpMat:Translate(Vector(0, -2, 184/2))
zbumpMat:Scale(Vector(1, 1, 1) * .9)
zbumpMat:Translate(Vector(0, 0, -184/2))
ENT.ZBump = zbumpMat

if SERVER then
lastBusEnts = lastBusEnts or {}
concommand.Add("jazz_call_bus", function(ply, cmd, args, argstr)
    local eyeTr = ply:GetEyeTrace()
    local pos = eyeTr.HitPos
    local ang = eyeTr.HitNormal:Angle()
    
    mapcontrol.SpawnExitBus(pos, ang)
end )
end

function ENT:Initialize()

    if SERVER then 
        self:SetModel(self.Model)
        self:PrecacheGibs() -- Probably isn't necessary
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    end

    self:DrawShadow(false)

    if CLIENT then
        ParticleEffect( "shard_glow", self:GetPos(), self:GetAngles(), self )

        -- Take a snapshot of the surface that's about to be destroyed
        self:StoreSurfaceMaterial()

        -- Create all the gibs beforehand, get them ready to go (but hide them for now)
        self.Gibs = {}
        for _, v in pairs(self.GibModels) do
            local gib = ents.CreateClientProp(v)
            gib:SetModel(v)
            gib:SetPos(self:GetPos())
            gib:SetAngles(self:GetAngles())
            gib:Spawn()
            gib:PhysicsInit(SOLID_VPHYSICS)
            gib:SetSolid(SOLID_VPHYSICS)
            gib:SetCollisionGroup(self:GetIsExit() and COLLISION_GROUP_IN_VEHICLE or COLLISION_GROUP_WORLD)
            gib:SetNoDraw(true)
            gib:GetPhysicsObject():SetMass(500)

            gib:SetMaterial("!bus_wall_material")
            table.insert(self.Gibs, gib)
        end

        -- Also get the void props ready too
        self.VoidProps = {}
        for _, v in pairs(self.VoidModels) do
            local mdl = ents.CreateClientProp(v)
            mdl:SetModel(v)
            mdl:SetNoDraw(true)
            table.insert(self.VoidProps, mdl)
        end

        self.VoidSphere = ents.CreateClientProp(self.VoidSphereModel)
        self.VoidSphere:SetModel(self.VoidSphereModel)
        self.VoidSphere:SetNoDraw(true)

        self.VoidBorder = ents.CreateClientProp(self.VoidBorderModel)
        self.VoidBorder:SetModel(self.VoidBorderModel)
        self.VoidBorder:SetNoDraw(true)

        self.VoidRoad = ents.CreateClientProp(self.VoidRoadModel)
        self.VoidRoad:SetModel(self.VoidRoadModel)
        self.VoidRoad:SetNoDraw(true)

        self.VoidTunnel = ents.CreateClientProp(self.VoidTunnelModel)
        self.VoidTunnel:SetModel(self.VoidTunnelModel)
        self.VoidTunnel:SetNoDraw(true)

        self.BackgroundHum = CreateSound(self, self.BackgroundHumSound)

        -- Hook into when the void renders so we can insert our props into it
        hook.Add("JazzDrawVoid", self, self.OnPortalRendered)
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Bus")
    self:NetworkVar("Bool", 1, "IsExit") -- Are we the exit from the map into the void?
end

function ENT:OnRemove()
    if self.BackgroundHum then
        self.BackgroundHum:Stop()
        self.BackgroundHum = nil 
    end

    if self.Gibs then
        for _, v in pairs(self.Gibs) do
            if IsValid(v) then v:Remove() end
        end
    end
end

-- Test which side the given point is of the portal
function ENT:DistanceToVoid(pos, dontflip)
    local dir = pos - self:GetPos()
    local fwd = self:GetAngles():Right()
    local mult = (!dontflip and self:GetIsExit() and -1) or 1

    return fwd:Dot(dir) * mult
end

if SERVER then return end

TEXTUREFLAGS_ANISOTROPIC = 16
TEXTUREFLAGS_RENDERTARGET = 32768

-- Render the wall we're right next to so we can break it
function ENT:StoreSurfaceMaterial()

    -- Create (or retrieve) the render target
    local rtname = "bus_wall_rt"
    if self:GetIsExit() then rtname = rtname .. "_exit" end
    self.WallTexture = GetRenderTargetEx(rtname, self.RTSize, self.RTSize, 
        RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SEPARATE, 
        bit.bor(TEXTUREFLAGS_RENDERTARGET,TEXTUREFLAGS_ANISOTROPIC), 
        CREATERENDERTARGETFLAGS_AUTOMIPMAP, IMAGE_FORMAT_DEFAULT)

    -- Note we just keep reusing "bus_wall_material". If we wanted multiple buses at the same time,
    -- then we'll need a unique name for each material. But not yet.
    self.WallMaterial = CreateMaterial("bus_wall_material", "UnlitGeneric", { ["$nocull"] = 1})
    self.WallMaterial:SetTexture("$basetexture", self.WallTexture)

    -- Bam, just like that, render the wall to the texture
    local pos = self.Size / 2
    local viewang = self:GetAngles()
    viewang:RotateAroundAxis(viewang:Up(), 90)
    render.PushRenderTarget(self.WallTexture)

        render.RenderView( {
            origin = self:GetPos() + viewang:Forward() * -5 + viewang:Up() * pos,
            angles = viewang,
            drawviewmodel = false,
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH(),
            ortholeft = -pos,
            orthoright = pos,
            orthotop = -pos,
            orthobottom = pos,
            ortho = true,
            bloomtone = false,
            dopostprocess = false,
        } )

    render.PopRenderTarget()
end

function ENT:Think()
    -- Break when the distance of the bus's front makes it past our portal plane
    if !self.Broken then 
        self.Broken = self:ShouldBreak()

        if self.Broken then 
            self:OnBroken()
        end

    end

    -- This logic is for the exit view only
    if self:GetIsExit() then
        -- Mark the exact time when the client's eyes went into the void
        if self.Broken and !self.VoidTime then
            if self:DistanceToVoid(LocalPlayer():EyePos(), true) < 0 then 
                self.VoidTime = CurTime()
                //self:GetBus().JazzSpeed = self:GetBus():GetVelocity():Length()
            end
        end

        -- Bus have not have networked, but we need a way to go from Bus -> Portal
        -- Just set a value on the bus entity that points to us
        if IsValid(self:GetBus()) then
            self:GetBus().ExitPortal = self
        end
    end

    -- Insert into the local list of portals to render this frame
    local ply = LocalPlayer()
    ply.ActiveBusPortals = ply.ActiveBusPortals or {}
    table.insert(ply.ActiveBusPortals, self)
end

function ENT:UpdateCustomTexture()
    self.WallMaterial:SetTexture("$basetexture", self.WallTexture)
end

function ENT:SetupVoidLighting()
    
    render.SetModelLighting(BOX_FRONT, 100/255.0, 0, 244/255.0)
    render.SetModelLighting(BOX_BACK, 150/255.0, 0, 234/255.0)
    render.SetModelLighting(BOX_LEFT, 40/255.0, 0, 144/255.0)
    render.SetModelLighting(BOX_RIGHT, 100/255.0, 0, 244/255.0)
    render.SetModelLighting(BOX_TOP, 255/255.0, 1, 255/255.0)
    render.SetModelLighting(BOX_BOTTOM, 20/255.0, 0, 45/255.0)

    local fogOffset = EyePos():Distance(self:GetPos())
    render.FogMode(MATERIAL_FOG_LINEAR)
    render.FogStart(100 + fogOffset)
    render.FogEnd(20000 + fogOffset)
    render.FogMaxDensity(.35)
    render.FogColor(180, 169, 224)
end

function ENT:GetPortalAngles()
    if IsValid(self:GetBus()) then 
        local bang = self:GetBus():GetAngles() 
        if self:GetIsExit() then 
            bang:RotateAroundAxis(bang:Up(), 180)
        end

        return bang
    end

    return self:GetAngles()
end

function ENT:OnPortalRendered()
    self:DrawInsidePortal()
    self:DrawInteriorDoubles()
end

function ENT:DrawInsidePortal()

    -- Define our own lighting environment for this
    render.SuppressEngineLighting(true)

    self:SetupVoidLighting()

    local portalAng = self:GetPortalAngles()
    local center = self:GetPos() + portalAng:Up() * self.Size/2
    local ang = Angle(portalAng)
    ang:RotateAroundAxis(ang:Up(), -90)

    -- Draw a few random floating props in the void
    /*
    for i = 1, 10 do
        -- Lifehack: SharedRandom is a nice stateless random function
        local randX = util.SharedRandom("prop", -500, 500, i)
        local randY = util.SharedRandom("prop", -500, 500, -i)

        local offset = portalAng:Right() * (-200 + i * -120)
        offset = offset + portalAng:Up() * randY
        offset = offset + portalAng:Forward() * randX

        -- Subtle twists and turns, totally arbitrary
        local angOffset = Angle(
            randX + CurTime()*randX/50, 
            randY + CurTime()*randY/50, 
            math.sin(randX + randY) * 360 + CurTime() * 10)

        -- Just go through the list of props, looping back
        local mdl = self.VoidProps[(i % #self.VoidProps) + 1]
        //debugoverlay.Sphere(center + offset, 10, 0, Color( 255, 255, 255 ), true)
        mdl:SetPos(center + offset)
        mdl:SetAngles(ang + angOffset)
        mdl:SetupBones() -- Since we're drawing in multiple locations
        mdl:DrawModel()
    end*/

    -- If we're the exit portal, draw the gibs floating into space
    if self:GetIsExit() and self.Broken then 
        for _, gib in pairs(self.Gibs) do
            gib:DrawModel()
        end
    end

    -- Draw a fixed border to make it look like cracks in the wall
    -- Disable fog for this, we want it to be seamless
    render.FogMode(MATERIAL_FOG_NONE)
    self.VoidBorder:SetPos(self:GetPos())
    self.VoidBorder:SetAngles(self:GetAngles())
    self.VoidBorder:SetMaterial("!bus_wall_material")
    self.VoidBorder:SetupBones()
    self.VoidBorder:DrawModel()
    render.FogMode(MATERIAL_FOG_LINEAR)

    render.SuppressEngineLighting(false)
end

-- Draws doubles of things that are in the normal world too
-- (eg. the Bus, seats, other players, etc.)
function ENT:DrawInteriorDoubles()
    local portalAng = self:GetPortalAngles()

    -- Define our own lighting environment for this
    render.SuppressEngineLighting(true)
    self:SetupVoidLighting()

    -- Draw background
    render.FogMode(MATERIAL_FOG_NONE) -- Disable fog so we can get those deep colors

    self.VoidTunnel:SetPos(self:GetPos())
    self.VoidTunnel:SetAngles(portalAng)
    self.VoidTunnel:SetupBones()
    self.VoidTunnel:SetModelScale(0.34)

    -- First draw with default material but darkened
    render.SetColorModulation(55/255.0, 55/255.0, 55/255.0)
    self.VoidTunnel:SetMaterial("")
    //self.VoidTunnel:DrawModel()
    render.SetColorModulation(1, 1, 1)
    
    -- Now two more times with each of sun's groovy additive jazz materials
    //self.VoidTunnel:SetMaterial("sunabouzu/jazzLake01")
    //self.VoidTunnel:DrawModel()

    -- Blend in so it doesn't all of a sudden pop into the jazz void
    local blendIn = math.min(1, (CurTime() - self:GetCreationTime()) / 2)
    render.SetBlend(blendIn)
    self.VoidTunnel:SetMaterial("sunabouzu/jazzLake02")
    self.VoidTunnel:DrawModel()

    render.FogMode(MATERIAL_FOG_LINEAR)
    
    -- Draw the wiggly wobbly road into the distance
    self.VoidRoad:SetPos(self:GetPos())
    self.VoidRoad:SetAngles(portalAng)
    self.VoidRoad:SetupBones()
    self.VoidRoad:DrawModel()
    render.SetBlend(1.0)

    -- Draw bus
    if IsValid(self:GetBus()) then 
        self:GetBus():DrawModel() 
        local childs = self:GetBus():GetChildren()
        for _, v in pairs(childs) do
            v:DrawModel()
        end
    end

    -- Draw players (only applies if exiting)
    -- NOTE: Usually this is a bad idea, but legitimately every single player should be in the bus
    if self:GetIsExit() then
        for _, ply in pairs(player.GetAll()) do
            local seat = ply:GetVehicle()
            if IsValid(seat) and seat:GetParent() == self:GetBus() then 
                ply:DrawModel()
            end
        end
    end

    render.SuppressEngineLighting(false)
end

-- Break if the front of the bus has breached our plane of existence
function ENT:ShouldBreak()
    if !IsValid(self:GetBus()) then return false end
    
    local busFront = self:GetBus():GetFront()
    return self:DistanceToVoid(busFront) > 0
end

-- Right when we switch over to the jazz dimension, the bus will stop moving
-- So we immediately start 'virtually' moving through the jazz dimension instead
-- IDEALLY I'D LIKE TO RETURN A VIEW MATRIX, BUT GMOD DOESN'T HANDLE THAT VERY WELL
function ENT:GetJazzVoidView()
    if !self.VoidTime or !IsValid(self:GetBus()) then return Vector() end

    local t = CurTime() - self.VoidTime
    return self:GetAngles():Right() * self:GetBus().JazzSpeed * -t
end

function ENT:OnBroken()

    -- Draw and wake up every gib
    for _, gib in pairs(self.Gibs) do

        -- Gibs are manually drawn for exit portal (they're in the void)
        if !self:GetIsExit() then
            gib:SetNoDraw(false)
        else
            gib:GetPhysicsObject():EnableGravity(false)
        end

        gib:GetPhysicsObject():Wake()
        local mult = self:GetIsExit() and -1 or 1 -- Break INTO the void, not out of
        local force = math.random(200, 700) * mult
        gib:GetPhysicsObject():SetVelocity(self:GetAngles():Right() * force)
        gib:GetPhysicsObject():AddAngleVelocity(VectorRand() * 100)
    end

    -- Effects
    local center = self:GetPos() + self:GetAngles():Up() * self.Size/2
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Right(), 90)

    local ed = EffectData()
    ed:SetScale(10)
    ed:SetMagnitude(30)
	ed:SetEntity(self)
    ed:SetOrigin(center)
    ed:SetAngles(ang)

    util.Effect("HelicopterMegaBomb", ed)

    self:EmitSound("ambient/machines/wall_crash1.wav", 130)
    self:EmitSound("ambient/machines/thumper_hit.wav", 130)

    util.ScreenShake(self:GetPos(), 15, 3, 3, 1000)

    local ed2 = EffectData()
    ed2:SetStart(self:GetPos())
    ed2:SetOrigin(self:GetPos())
    ed2:SetScale(100)
    ed2:SetMagnitude(100)
    ed2:SetNormal(self:GetAngles():Right())

    -- TODO: Glue these to the bus's two front wheels
    util.Effect("ManhackSparks", ed2, true, true)

    self.BackgroundHum:SetSoundLevel(60)
    self.BackgroundHum:Play()

    -- Start rendering the portal view
    self.RenderView = true
end

function ENT:DrawPortal()
    if !self.RenderView then return end

    -- Don't bother rendering if the eyes are behind the plane anyway
    if self:DistanceToVoid(EyePos(), true) < 0 then return end
    self.DrawingPortal = true
    self:UpdateCustomTexture()

    render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.ClearStencil()

        -- First, draw where we cut out the world
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)

        -- Push this slightly outward to prevent z fighting with the surface
        self:EnableMatrix("RenderMultiply", self.ZBump)
        self:DrawModel()
        self:DisableMatrix("RenderMultiply")

        -- Second, draw the interior
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.ClearBuffersObeyStencil(55, 0, 55, 255, true)

        cam.Start2D()
            render.DrawTextureToScreen(snatch.GetVoidTexture())
        cam.End2D()
        

        -- Draw into the depth buffer for the interior to prevent
        -- Props from going through
        render.OverrideColorWriteEnable(true, false)
            self:DrawModel()
        render.OverrideColorWriteEnable(false, false)

    render.SetStencilEnable(false)
    self.DrawingPortal = false
end

function ENT:Draw()
    if !self.RenderView then return end
    if !self.DrawingPortal then return end
    self:DrawModel()
end


local function GetExitPortal()
    local bus = IsValid(LocalPlayer():GetVehicle()) and LocalPlayer():GetVehicle():GetParent() or nil
    if !IsValid(bus) or !bus:GetClass() == "jazz_bus_explore" then return nil end 

    return bus.ExitPortal
end

local function IsInExitPortal()
    local exitPortal = GetExitPortal()
    if !IsValid(exitPortal) then return false end
    
    -- If the local player's view is past the portal 'plane', ONLY render the jazz dimension
    return exitPortal:DistanceToVoid(LocalPlayer():EyePos()) > 0
end

-- PostRender and PostDrawOpaqueRenderables are what draws the stencil portal in the world
hook.Add("PostRender", "JazzClearExteriorVoidList", function()
    local portals = LocalPlayer().ActiveBusPortals
    if !portals then return end

    table.Empty(portals)
end )

hook.Add("PostDrawOpaqueRenderables", "JazzBusDrawExteriorVoid", function(depth, sky)
    local portals = LocalPlayer().ActiveBusPortals
    if !portals then return end

    for _, v in pairs(portals) do
        if IsValid(v) and v.DrawPortal then     
            v:DrawPortal()
        end
    end
end )

-- Override PreDraw*Renderables to not draw _anything_ if we're inside the portal
hook.Add("PreDrawOpaqueRenderables", "JazzHaltWorldRender", function(depth, sky)
    if IsInExitPortal() then return true end 
end )
hook.Add("PreDrawTranslucentRenderables", "JazzHaltWorldRender", function()
    if IsInExitPortal() then return true end 
end )
hook.Add("PreDrawSkyBox", "JazzHaltSkyRender", function()
    if IsInExitPortal() then return true end
end)

-- Totally overrwrite the world with the custom void world
hook.Add("PreDrawEffects", "JazzDrawPortalWorld", function()
    local exitPortal = GetExitPortal()
    if !IsValid(exitPortal) then return end

    -- If the local player's view is past the portal 'plane', ONLY render the jazz dimension
    local origin = EyePos()
    local angles = EyeAngles()

    if exitPortal:DistanceToVoid(origin) > 0 then
        
        local voffset = exitPortal:GetJazzVoidView()

        snatch.UpdateVoidTexture(origin, angles)

        render.Clear(55, 0, 55, 255, true, true) -- Dump anything that was rendered
        cam.Start2D()
            render.DrawTextureToScreen(snatch.GetVoidTexture())
        cam.End2D()
    end
end )