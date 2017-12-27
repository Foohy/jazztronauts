include("shared.lua")

ENT.ScreenHeight = 0
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .1

ENT.CommentOffset = Vector(-200, 12, 0)

ENT.BusWidth = 70
ENT.BusLength = 248


function ENT:Initialize()

end


function ENT:StartLaunchEffects()
	print("Starting clientside launch")
	self.IsLaunching = true
	self.StartLaunchTime = CurTime()
	LocalPlayer().LaunchingBus = self
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()

end

function ENT:OnRemove()

end