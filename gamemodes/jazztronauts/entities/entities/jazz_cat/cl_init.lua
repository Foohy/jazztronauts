include("shared.lua")

-- How quickly the chat fades in and out
ENT.ChatFadeSpeed = 1.2

-- How quickly to approach the look goal
ENT.HeadLookSpeed = 3
ENT.HeadLookBone = "rig_cat:j_head"
ENT.HeadLookDistance = 400
ENT.HeadLookRange = math.cos(math.rad(80))

ENT.ChatFade = 0
ENT.AttentionMarker = Material("materials/ui/jazztronauts/yes.png", "smooth")
ENT.QuestionMarker = Material("materials/ui/jazztronauts/question.png", "smooth")
ENT.ChatMarker = Material("materials/ui/jazztronauts/catchat.png", "smooth")
ENT.StoreMarker = Material("materials/ui/jazztronauts/catcoin.png", "smooth")

function ENT:Initialize()
    self:SetupChatTables()

    -- Allow mouse clicks on the chat menu (and make it so clicking doesn't shoot their weapon)
    if self.ChatChoices and #self.ChatChoices > 0 then
        hook.Add("KeyPress", self, function(self, ply, key) return self:OnMouseClicked(ply, key) end )
        hook.Add("KeyRelease", self, function(self, ply, key) return self:OnMouseReleased(ply, key) end)
    end

    worldmarker.Register(self, self.AttentionMarker, 20)
    worldmarker.Update(self, self:GetPos() + Vector(0, 0, 70))
    worldmarker.SetEnabled(false)
end

function ENT:OnMouseClicked(ply, key)
    if not IsFirstTimePredicted() or key != IN_ATTACK then return end

    if self.IsLeftDown then return end
    self.IsLeftDown = true

    local opt = self:GetSelectedOption(LocalPlayer(), self.ChatChoices)
    if opt then

        surface.PlaySound("buttons/button9.wav")
        self.ChatChoices[opt].func(self, LocalPlayer())
    end
end

function ENT:OnMouseReleased(ply, key)
    if not IsFirstTimePredicted() then return end
    if key == IN_ATTACK or (key == IN_ZOOM and self.IsLeftDown) then
        self.IsLeftDown = false      
    end
end 

function ENT:ShouldDrawChat()
    local pos = self:GetMenuPosAng(LocalPlayer())
    return LocalPlayer():EyePos():Distance(pos) < self.ChatFadeDistance
end

function ENT:UpdateChatFade()
    local shouldDraw = self:ShouldDrawChat()
    local change = 0
    if shouldDraw && self.ChatFade < 1.0 then
        change = 1
    elseif not shouldDraw && self.ChatFade > 0.0 then
        change = -1
    end

    self.ChatFade = math.Clamp(self.ChatFade + FrameTime() * self.ChatFadeSpeed * change, 0, 1)
end

function ENT:UpdateWorldMarker()
    local script, cond = converse.GetMissionScript(LocalPlayer(), self:GetNPCID())
    local actualscript = converse.GetNextScript(LocalPlayer(), self:GetNPCID())

    local icon = nil
    if dialog.IsScriptValid(actualscript) then
        if script == actualscript then
            local stateTable = 
            {
                [converse.MISSION_COMPLETED] = self.AttentionMarker,
                [converse.MISSION_AVAILABLE] = self.QuestionMarker
            }
            icon = stateTable[cond]
        else
            icon = self.ChatMarker
        end
    end

    self:SetChoiceIcon(self.ChatChoices, 3, icon)

    -- New item in store checks
    if self:GetNPCID() == missions.NPC_CAT_BAR then
        local newTools = jstore.HasNewItems("tools")
        local newUpgrades = jstore.HasNewItems("upgrades")

        self:SetChoiceIcon(self.ChatChoices, 1, newUpgrades and self.StoreMarker)
        self:SetChoiceIcon(self.ChatChoices, 2, newTools and self.StoreMarker)

        if not icon and (newTools or newUpgrades) then
            icon = self.StoreMarker
        end
    end

    if icon then
        worldmarker.SetIcon(self, icon)
    end

    worldmarker.SetEnabled(self, icon != nil)
end

function ENT:UpdateHeadFollow()

    local bone = self:LookupBone(self.HeadLookBone)

    local withinRange = (self:GetPos() - LocalPlayer():EyePos()):LengthSqr() < math.pow(self.HeadLookDistance, 2)

    self:SetupBones()
    local mat = self:GetBoneMatrix(bone)

    local goalAng = mat:GetAngles()

    if withinRange then
        local lookAng = (mat:GetTranslation() - LocalPlayer():EyePos()):Angle()
        lookAng:RotateAroundAxis(lookAng:Up(), 90)
        lookAng:RotateAroundAxis(lookAng:Right(), 90)

        if mat:GetRight():Dot(lookAng:Right()) > self.HeadLookRange then
            goalAng = lookAng
        end
    end

    self.CurFollowAngle = self.CurFollowAngle or goalAng
    self.CurFollowAngle = LerpAngle(FrameTime() * self.HeadLookSpeed, self.CurFollowAngle, goalAng)
end


function ENT:Think()
    -- Check for mission changes
    if not self.NextWorldMarkerThink or CurTime() > self.NextWorldMarkerThink then
        self:UpdateWorldMarker()
        self.NextWorldMarkerThink = CurTime() + 1
    end
    
    -- Update head follow angle
    self:UpdateHeadFollow()
end

function ENT:DrawModelFollow()
    local bone = self:LookupBone(self.HeadLookBone)
    local mat = self:GetBoneMatrix(bone)
    local default = mat:GetAngles()
    mat:SetAngles(self.CurFollowAngle or Angle())
    self:SetBoneMatrix(bone, mat)

    self:DrawModel()

    mat:SetAngles(default)
    self:SetBoneMatrix(bone, mat)
end

function ENT:Draw()
    if not self.GetNPCID then return end
    if self.NoFollowPlayer then
        self:DrawModel()
    else
        self:DrawModelFollow()
    end

    -- Only the bartender has multiple options, everyone else just chats
    if self.ChatChoices and #self.ChatChoices > 0 then
        self:UpdateChatFade()

        -- Don't draw if 100% hidden
        if self.ChatFade > 0 then
            self:DrawDialogEntry(self.ChatChoices, self.ChatFade)
        end
    
        -- Play a small click sound when switching between options
        local opt = self:GetSelectedOption(LocalPlayer(), self.ChatChoices)
        if self.LastOption != opt then
            self.LastOption = opt

            LocalPlayer():EmitSound("buttons/lightswitch2.wav", 0, 175)
        end
    end

end

local bitch = [[What the fuck did you just fucking say about me, you little bitch? I’ll have you know I graduated top of my class in the Navy Seals, and I’ve been involved in numerous secret raids on Al-Quaeda, and I have over 300 confirmed kills. I am trained in gorilla warfare and I’m the top sniper in the entire US armed forces. You are nothing to me but just another target. I will wipe you the fuck out with precision the likes of which has never been seen before on this Earth, mark my fucking words. You think you can get away with saying that shit to me over the Internet? Think again, fucker. As we speak I am contacting my secret network of spies across the USA and your IP is being traced right now so you better prepare for the storm, maggot. The storm that wipes out the pathetic little thing you call your life. You’re fucking dead, kid. I can be anywhere, anytime, and I can kill you in over seven hundred ways, and that’s just with my bare hands. Not only am I extensively trained in unarmed combat, but I have access to the entire arsenal of the United States Marine Corps and I will use it to its full extent to wipe your miserable ass off the face of the continent, you little shit. If only you could have known what unholy retribution your little “clever” comment was about to bring down upon you, maybe you would have held your fucking tongue. But you couldn’t, you didn’t, and now you’re paying the price, you goddamn idiot. I will shit fury all over you and you will drown in it. You’re fucking dead, kiddo.]]
local bitchArr = string.Split(bitch, " ")
dialog.RegisterFunc("bitch", function(d)
    for i=1, #bitchArr do
        d.rate = i
        surface.PlaySound("garrysmod/balloon_pop_cute.wav")
        coroutine.yield(bitchArr[i] .. (i % 17 == 0 and "\n" or " "))
    end
end )
