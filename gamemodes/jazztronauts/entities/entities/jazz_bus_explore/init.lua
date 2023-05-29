AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.ShadowControl = {}
ENT.ShadowControl.secondstoarrive  = 0.0000001
ENT.ShadowControl.pos			  = Vector(0, 0, 0)
ENT.ShadowControl.angle			= Angle(0, 0, 0)
ENT.ShadowControl.maxspeed		 = 1000000000000
ENT.ShadowControl.maxangular	   = 1000000
ENT.ShadowControl.maxspeeddamp	 = 10000
ENT.ShadowControl.maxangulardamp   = 1000000
ENT.ShadowControl.dampfactor	   = 1
ENT.ShadowControl.teleportdistance = 10
ENT.ShadowControl.deltatime		= 0

-- Different movement states the bus can be in
-- Wink wink nudge nudge zak's state machine library
local MOVE_STATIONARY	= 1
local MOVE_ARRIVING	= 2
local MOVE_LEAVING		= 3
local MOVE_LEAVING_PORTAL = 4

ENT.BusLeaveDelay = 1
ENT.BusLeaveAccel = 500

local noMoveEntsConVar = CreateConVar("jazz_bus_nomove", "0")

ENT.PrelimSounds =
{
	{ snd = "ambient/machines/wall_move1.wav", delay = 2.8 },
	{ snd = "ambient/machines/wall_move4.wav", delay = 2.8},
	{ snd = "ambient/machines/thumper_startup1.wav", delay = 2.8},
	{ snd = "jazztronauts/trolley/jazz_trolley_bell.wav", delay = 1.0}
}

ENT.BrakeSounds =
{
	"jazztronauts/trolley/brake_1.wav",
	"jazztronauts/trolley/brake_2.wav",
}

local shockingisntit = {
	"npc/roller/mine/rmine_explode_shock1.wav",
	"npc/roller/mine/rmine_shockvehicle1.wav",
	"npc/roller/mine/rmine_shockvehicle2.wav",
	"npc/scanner/scanner_pain1.wav",
	"npc/scanner/scanner_pain2.wav"
}

ENT.TravelTime = 1.5

util.AddNetworkString("jazz_bus_explore_voideffects")

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetTrigger(true) -- So we get 'touch' callbacks that fuck shit up
	self:SetNoDraw(true)

	hook.Add( "CanTool", "NoBusRemoval", function( ply, tr, toolname, tool )
		if toolname ~= "remover" then return end
		if !IsValid( tr.Entity ) then return end
		if tr.Entity:GetClass() ~= "jazz_bus_explore" then return end

		ply:Freeze(true)
		ply:DropWeapon()
		ply:EmitSound(table.Random(shockingisntit), 50)
		util.ScreenShake(ply:GetPos(), 20, 5, 2, 50)

		timer.Create( "BusRemovalUnfreeze", 1.5, 1, function()
			if !IsValid( ply ) then return end
			ply:Freeze(false)
		end )
		return false
	end )

	-- Setup seat offsets
	for i=1, 8 do
		self:AttachSeat(Vector(40, i * 40 - 180, 80), Angle(0, 180, 0))
		self:AttachSeat(Vector(-40, i * 40 - 180, 80), Angle(0, 180, 0))
	end

	-- Setup radio
	self:AttachRadio(Vector(40, -190, 50), Angle(0, 150, 0))

	local spawnPos = self:GetPos()
	self.StartPos = spawnPos + self:GetAngles():Right() * (-self.HalfLength - 20) + Vector(0, 0, 20)
	self.GoalPos = self:GetFront()
	self.StartAngles = self:GetAngles()
	self.MoveState = MOVE_STATIONARY

	-- Start us off right at the start
	self:SetPos(self.StartPos)

	-- Play an ominous sound that something's coming
	local prelim = table.Random(self.PrelimSounds)
	sound.Play(prelim.snd, spawnPos, 85, 100, 1)

	-- Also setup the screetching sound
	local rf = RecipientFilter()
	rf:AddAllPlayers()
	self.BrakeSound = CreateSound(self, table.Random(self.BrakeSounds), rf)
	self.BrakeSound:SetSoundLevel(100)

	-- Let it sink in
	self:SetBreakTime(CurTime() + prelim.delay)
	timer.Simple(prelim.delay, function()
		if IsValid(self) then self:Arrive() end
	end )

	if SERVER then
		hook.Add("PlayerEnteredVehicle", self, function(self, ply, veh, role)
			self:CheckLaunch()
		end)

		-- Hook into when a player leaves so we can double check launch conditions
		hook.Add("PlayerDisconnected", self, function()
			timer.Simple(0, function()
				self:CheckLaunch()
			end)
		end )
	end
end

-- Automatically sit the provided player down into an available seat
function ENT:SitPlayer(ply)
	if not IsValid(ply) then return false end

	for _, v in pairs(self.Seats) do
		if IsValid(v) and not IsValid(v:GetDriver()) then
			ply:EnterVehicle(v)
			return true
		end
	end

	return false
end

function ENT:CheckLaunch()
	if self.CommittedToLeaving then return end

	local filled, total = self:GetNumOccupants()
	local required = math.min(player.GetCount(), total)

	if filled >= required then
		self.CommittedToLeaving = true
		self:EmitSound( "jazz_bus_idle", 90, 150 )
		util.ScreenShake(self:GetPos(), 10, 5, 1, 1000)

		-- Queue up the void music
		self:QueueTimedMusic()

		timer.Simple(self.BusLeaveDelay, function()
			if IsValid(self) then
				self.IsLaunching = true
				self:Leave()
			end
		end )
	end
end

function ENT:Arrive()
	-- Setup shadow controller
	self:StartMotionController()

	local phys = self:GetPhysicsObject()

	if phys then
		phys:EnableGravity( true )
		phys:EnableMotion( true )
		phys:Wake()
	end
	self:SetNoDraw(false)

	if IsValid(self.RadioEnt) then
		self.RadioEnt:SetNoDraw(false)
	end
	for _, v in pairs(self.Seats) do
		if IsValid(v) then
			v:SetNoDraw(false)
		end
	end

	self.BrakeSound:Play()

	self.StartTime = CurTime()
	self.MoveState = MOVE_ARRIVING

	-- Tweak the arrive position so we don't break the second barrier in a narrow space
	if IsValid(self.ExitPortal) then
		local MoveDistance = math.Clamp(self.ExitPortal:DistanceToVoid(self:GetFront(), true), 50, self.HalfLength*2)
		self.GoalPos = self:GetPos() + self:GetAngles():Right() * MoveDistance
	end

end

function ENT:Leave()
	if self.MoveState == MOVE_LEAVING then return end

	self:EmitSound("jazz_bus_accelerate2")

	self.StartTime = CurTime()
	self.StartPos = self:GetPos()
	local BusAngle = self:GetAngles():Right()
	self.GoalPos = self.GoalPos + BusAngle * 2000

	self.MoveState = MOVE_LEAVING
	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():Wake()

	hook.Add( "PlayerLeaveVehicle", "VoidEjection", function( ply )
		timer.Create( "VoidEjectTimer", 0, 1, function() -- timer prevents crash
			local repcount = 0
			local BehindBus = self:GetPos() + Vector(0, 0, 50) + BusAngle * -150
			repeat
				repcount = repcount + 1
				BehindBus = BehindBus + BusAngle * -100
				ply:SetPos(BehindBus)
			until ( ply:IsInWorld( BehindBus ) or repcount > 20 )

			local EjectSpeed = Vector(0, 0, 0) + BusAngle * -2000
			ply:SetVelocity(EjectSpeed)

			ply:Kill()
			ply:Spectate(OBS_MODE_DEATHCAM)
			hook.Add( "PlayerSpawn", "VoidEjectedRespawn", function()
				self:SitPlayer(ply)
			end )
		end )
	end )

end

function ENT:AttachRadio(pos, ang)
	pos = self:LocalToWorld(pos)
	ang = self:LocalToWorldAngles(ang)

	-- Make a "fake" version of the radio, the "real" one can be stolen.
	local ent = ents.Create("jazz_static_proxy")
	ent:SetModel(self.RadioModel)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetParent(self)
	ent:Spawn()
	ent:Activate()
	self.Radio = ent

	local radio_ent = ents.Create("prop_dynamic")
	radio_ent:SetModel(self.RadioModel)
	radio_ent:SetPos(pos)
	radio_ent:SetAngles(ang)
	radio_ent:SetParent(ent)
	radio_ent:Spawn()
	radio_ent:Activate()
	radio_ent:SetNoDraw(true)
	self.RadioEnt = radio_ent

	-- Attach a looping audiozone
	self.RadioMusic = CreateSound(ent, self.RadioMusicName)
	hook.Add("EntityRemoved", "JazzBusRadioCheck", function(removed)
		if removed ~= radio_ent then return end
		self.RadioMusic:Stop()
		ent:Remove()
	end)
end

function ENT:AttachSeat(pos, ang)
	pos = self:LocalToWorld(pos)
	ang = self:LocalToWorldAngles(ang)

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	ent:SetModel("models/nova/airboat_seat.mdl")
	ent:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetParent(self)
	ent:Spawn()
	ent:Activate()
	ent:SetNoDraw(true)

	self.Seats = self.Seats or {}
	table.insert(self.Seats, ent)
end

function ENT:GetNumOccupants()
	if !self.Seats then return 0 end

	local count = 0
	local total = 0
	for _, v in pairs(self.Seats) do
		if IsValid(v) then
			total = total + 1
			if IsValid(v:GetDriver()) then
				count = count + 1
			end
		end
	end

	return count, total
end

-- Predict when we'll blast into the jazz dimension
-- This is so we can 'preroll' some shnazzy music that blasts into high gear right when it gets going
function ENT:QueueTimedMusic()
	local estHitTime = self.BusLeaveDelay
	local dist = self:GetFront():Distance(self.ExitPortal:GetPos())
	estHitTime = estHitTime + math.sqrt(2 * dist / self.BusLeaveAccel) -- d = 0.5at^2

	local startTime = estHitTime - self.VoidMusicPreroll
	self.ChangelevelTime = CurTime() + estHitTime + self.VoidMusicFadeEnd

	self.RadioMusic:FadeOut(startTime)

	local bshard = ents.FindByClass("jazz_shard_black")[1]
	local isCorrupted = IsValid(bshard) and bshard:GetStartSuckTime() > 0

	net.Start("jazz_bus_explore_voideffects")
		net.WriteEntity(self)
		net.WriteFloat(CurTime() + startTime)
		net.WriteBool(isCorrupted)
	net.Broadcast()
end

function ENT:Touch(other)
	if noMoveEntsConVar:GetBool() then return end
	if self.MoveState == MOVE_STATIONARY then return end
	if !IsValid(other:GetPhysicsObject()) then return end
	if (other:GetClass() == self:GetClass()) then return end
	if (other:IsPlayer() and table.HasValue(self.Seats, other:GetVehicle())) then return end
	if (IsValid(other:GetParent()) and other:GetParent():GetClass() == self:GetClass()) then return end

	local front = self:GetFront()
	local moveFwdAmt = (front - other:GetPos()):Dot(self:GetAngles():Right())
	local velocity = self:GetAngles():Right() * 5000
	other:GetPhysicsObject():SetVelocity(velocity)
	other:SetPos(other:GetPos() + self:GetAngles():Right() * moveFwdAmt)
	other:GetPhysicsObject():EnableMotion(true) -- Bus stops for nobody

	local d = DamageInfo()
	d:SetDamage((velocity - other:GetVelocity()):Length() )
	d:SetAttacker(self)
	d:SetDamageType(DMG_CRUSH)
	d:SetDamageForce(velocity * 10000) -- Just fuck them up

	other:TakeDamageInfo( d )
end

function ENT:GetProgress()
	local t = CurTime() - (self.StartTime or 0)

	return t, t / self.TravelTime
end

function ENT:PhysicsStationary(phys, deltatime)
	self.ShadowControl.pos = self.GoalPos
	self.ShadowControl.angle = self.StartAngles
end

function ENT:PhysicsArriving(phys, deltatime)
	local _, perc = self:GetProgress()
	local p = math.EaseInOut(math.Clamp(perc, 0, 1), 0, 2)
	local rotAng = 0

	self.ShadowControl.pos = LerpVector(p, self.StartPos, self.GoalPos)
	self.ShadowControl.angle = Angle(self.StartAngles)
	self.ShadowControl.angle:RotateAroundAxis(self.StartAngles:Forward(), rotAng)
end

function ENT:PhysicsLeaving(phys, deltatime)
	local t, perc = self:GetProgress()
	local dist = (self.StartPos - self.GoalPos):Length()
	local pos = 0.5 * (self.BusLeaveAccel) * math.pow(t, 2) -- (1/2)at^2 = position
	local rotAng = 0

	self.ShadowControl.pos = LerpVector(pos/dist, self.StartPos, self.GoalPos)
	self.ShadowControl.angle = Angle(self.StartAngles)
	self.ShadowControl.angle:RotateAroundAxis(self.StartAngles:Forward(), rotAng)
end

function ENT:PhysicsLeavingPortal(phys, deltatime)
	local t, perc = self:GetProgress()
	local rotAng = 0
	local pos = t * self.JazzSpeed

	self.ShadowControl.pos = self.StartPos + self.MoveForward * pos
	self.ShadowControl.angle = Angle(self.StartAngles)
	self.ShadowControl.angle:RotateAroundAxis(self.StartAngles:Forward(), rotAng)
end

function ENT:PhysicsSimulate( phys, deltatime )
	if self.MoveState == MOVE_STATIONARY then
		self:PhysicsStationary(phys, deltatime)
	elseif self.MoveState == MOVE_ARRIVING then
		self:PhysicsArriving(phys, deltatime)
	elseif self.MoveState == MOVE_LEAVING then
		self:PhysicsLeaving(phys, deltatime)
	elseif self.MoveState == MOVE_LEAVING_PORTAL then
		self:PhysicsLeavingPortal(phys, deltatime)
	end

	phys:ComputeShadowControl( self.ShadowControl )
end

function ENT:Think()
	if self.MoveState == MOVE_ARRIVING then
		local t, perc = self:GetProgress()
		if perc > 1 && !self:GetPhysicsObject():IsAsleep() then
			self:GetPhysicsObject():Sleep()
			self:GetPhysicsObject():EnableMotion(false)
			self:SetPos(self.GoalPos)
			self.MoveState = MOVE_STATIONARY

			self.BrakeSound:FadeOut(0.2)

			self.RadioMusic:Play()
		end
	end

	if IsValid(self.ExitPortal) then
		local leaving		= self.MoveState == MOVE_LEAVING
		local leavingPortal = self.MoveState == MOVE_LEAVING_PORTAL

		-- Switch to 'portal' travel model if we hit a portal
		if leaving and self.ExitPortal:ShouldBreak() then
			self.MoveState = MOVE_LEAVING_PORTAL
			self.StartTime = CurTime()
			self.MoveForward = (self.GoalPos - self.StartPos):GetNormal()
			self.StartPos = self:GetPos()
		end

		-- Stop moving the bus entirely when the rear of the bus gets inside the portal
		if (leaving or leavingPortal) and self.ExitPortal:DistanceToVoid(self:GetRear()) > 0 then
			self.MoveState = MOVE_STATIONARY
			self.GoalPos = self:GetPos()
		end
	end


	-- Changelevel at the end
	if self.ChangelevelTime and CurTime() > self.ChangelevelTime then
		--if self:GetNumOccupants() >= player.GetCount() then
			mapcontrol.Launch(mapcontrol.GetHubMap())
		--end
	end
end

function ENT:OnRemove()
	self:StopSound("jazz_bus_accelerate")
	self:StopSound("jazz_bus_accelerate2")
	self:StopSound("jazz_bus_idle")

	for _, v in pairs(self.Seats) do
		if IsValid(v) then v:Remove() end
	end

	self.RadioMusic:Stop()
	if IsValid(self.Radio) then self.Radio:Remove() end
end
