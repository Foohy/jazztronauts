include("shared.lua")

ENT.ChatFadeSpeed = 1.2
ENT.ChatFadeDistance = 150

ENT.ChatFade = 0

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

function ENT:Draw()
    if not self.GetNPCID then return end 
    self:DrawModel()

    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    local offset = self:GetAngles():Up() * 70
    offset = offset + self:GetAngles():Forward() * -5
    local right = self:GetAngles():Right()

    -- Draw debug name above their head. TODO: This is lazy. Style cat models.
    cam.Start3D2D(self:GetPos() + offset, ang, 0.1)
        draw.DrawText(missions.GetNPCName(self:GetNPCID()), "SteamCommentFont", 0, 0, color_white, TEXT_ALIGN_CENTER)
    cam.End3D2D()
    
    -- Only the bartender has multiple options, everyone else just chats
    if self:GetNPCID() == missions.NPC_CAT_BAR then
        self:UpdateChatFade()

        -- Don't draw if 100% hidden
        if self.ChatFade > 0 then
            self:DrawDialogEntry(self.BarChoices, self.ChatFade)
        end
    end
end
