include("shared.lua")

ENT.ScreenHeight = 0
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .1

ENT.CommentOffset = Vector(-200, 12, 0)

ENT.BusWidth = 70
ENT.BusLength = 248

local destRTWidth = 256
local destRTHeight = 256
function ENT:Initialize()
	self.IRT = irt.New("jazz_bus_destination_explore", destRTWidth, destRTHeight )
	self.DestMat = self.IRT:GetUnlitMaterial()
	self:UpdateDestinationMaterial()
end

function ENT:UpdateDestinationMaterial()
	JazzRenderDestinationMaterial(self, "the bar")
end

function ENT:StartLaunchEffects()
	print("Starting clientside launch")
	self.IsLaunching = true
	self.StartLaunchTime = CurTime()
	LocalPlayer().LaunchingBus = self
end

function ENT:Draw()
	self:UpdateDestinationMaterial()
	render.MaterialOverrideByIndex(2, self.DestMat)
	self:DrawModel()
	render.MaterialOverrideByIndex(1, nil)
end

function ENT:Think()

end

function ENT:OnRemove()

end

net.Receive("jazz_bus_explore_voideffects", function(len, ply)
	local bus = net.ReadEntity()
	local startTime = net.ReadFloat()
	local nomusic = net.ReadBool()

	-- Queried elsewhere for certain effects
	if IsValid(bus) then
		bus.IsLaunching = true
	end

	local waitTime = math.max(0, startTime - CurTime())
	if not nomusic then
		timer.Simple(waitTime, function()
			if IsValid(bus) then 
				surface.PlaySound(bus.VoidMusicName)
			end
		end )
	end
	
	local fadeWaitTime = waitTime + bus.VoidMusicFadeStart
	transitionOut(fadeWaitTime + 8)
	
	timer.Simple(fadeWaitTime, function()
		if IsValid(bus) and LocalPlayer():InVehicle() then 
			local fadelength = bus.VoidMusicFadeEnd - bus.VoidMusicFadeStart
			LocalPlayer():ScreenFade(SCREENFADE.OUT, color_white, fadelength, 15)
		end
	end)
end )