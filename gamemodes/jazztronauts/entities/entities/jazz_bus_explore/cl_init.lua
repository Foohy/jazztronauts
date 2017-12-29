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

net.Receive("jazz_bus_explore_voideffects", function(len, ply)
	local bus = net.ReadEntity()
	local startTime = net.ReadFloat()

	local waitTime = math.max(0, startTime - CurTime())
	timer.Simple(waitTime, function()
		if bus then 
			surface.PlaySound(bus.VoidMusicName)
		end
	end )
	
	local fadeWaitTime = waitTime + bus.VoidMusicFadeStart
	timer.Simple(fadeWaitTime, function()
		if bus and LocalPlayer():InVehicle() then 
			local fadelength = bus.VoidMusicFadeEnd - bus.VoidMusicFadeStart
			LocalPlayer():ScreenFade(SCREENFADE.OUT, color_white, fadelength, 10)
		end
	end)
end )