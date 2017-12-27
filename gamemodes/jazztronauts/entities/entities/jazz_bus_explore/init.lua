AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include("shared.lua")

ENT.ShadowControl = {}
ENT.ShadowControl.secondstoarrive  = 0.0000001
ENT.ShadowControl.pos              = Vector(0, 0, 0)
ENT.ShadowControl.angle            = Angle(0, 0, 0)
ENT.ShadowControl.maxspeed         = 1000000000000
ENT.ShadowControl.maxangular       = 1000000
ENT.ShadowControl.maxspeeddamp     = 10000
ENT.ShadowControl.maxangulardamp   = 1000000
ENT.ShadowControl.dampfactor       = 1
ENT.ShadowControl.teleportdistance = 10
ENT.ShadowControl.deltatime        = 0

-- Different movement states the bus can be in
-- Wink wink nudge nudge zak's state machine library
local MOVE_STATIONARY 	= 1
local MOVE_ARRIVING 	= 2
local MOVE_LEAVING 		= 3

ENT.PrelimSounds = 
{
	"ambient/machines/wall_move1.wav",
	"ambient/machines/wall_move4.wav",
	"ambient/machines/thumper_startup1.wav"
}

ENT.TravelTime = 1.5

util.AddNetworkString("jazz_bus_arriveeffects")


function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetTrigger(true) -- So we get 'touch' callbacks that fuck shit up


	-- Setup seat offsets
	for i=1, 8 do
		self:AttachSeat(Vector(40, i * 45 - 150, 80), Angle(0, 180, 0))
		self:AttachSeat(Vector(-40, i * 45 - 150, 80), Angle(0, 180, 0))
	end
	local spawnPos = self:GetPos()
	self.StartPos = spawnPos + self:GetAngles():Right() * -2000 + Vector(0, 0, 40)
	self.GoalPos = self:GetFront()
	self.StartAngles = self:GetAngles()
	self.MoveState = MOVE_STATIONARY

	-- Start us off right at the start
	self:SetPos(self.StartPos)

	-- Setup shadow controller
	self:StartMotionController()

	-- Play an ominous sound that something's coming
	sound.Play(table.Random(self.PrelimSounds), spawnPos, 85, 100, 1)


	-- Let it sink in
	timer.Simple(2.8, function()
		if IsValid(self) then self:Arrive() end
	end )

	if SERVER then
		hook.Add("PlayerEnteredVehicle", self, function(self, ply, veh, role) 
			self:CheckLaunch()
		end)
	end
end

function ENT:CheckLaunch()
	if self:GetNumOccupants() >= player.GetCount() then
		self:EmitSound( "jazz_bus_idle", 90, 150 )
		util.ScreenShake(self:GetPos(), 10, 5, 1, 1000)

		timer.Simple(1, function()
			if IsValid(self) then
				self.IsLaunching = true
				self:Leave()
			end
		end )
	end
end

function ENT:Arrive()
	local phys = self:GetPhysicsObject()
	if phys then
		phys:EnableGravity( true )
		phys:EnableMotion( true )
		phys:Wake()
	end

	self.StartTime = CurTime()
	self.MoveState = MOVE_ARRIVING
end

function ENT:Leave()
	if self.MoveState == MOVE_LEAVING then return end 

	self:EmitSound("jazz_bus_accelerate2")

	self.StartTime = CurTime()
	self.StartPos = self:GetPos()
	self.GoalPos = self.GoalPos + self:GetAngles():Right() * 2000

	self.MoveState = MOVE_LEAVING
	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():Wake()
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

	self.Seats = self.Seats or {}
	table.insert(self.Seats, ent)
end

function ENT:GetNumOccupants()
	if !self.Seats then return 0 end
	local count = 0
	for _, v in pairs(self.Seats) do
		if IsValid(v) and IsValid(v:GetDriver()) then
			count = count + 1
		end
	end

	return count
end

function ENT:Touch(other)
	local t, perc = self:GetProgress()
	if perc > 1 then return end 
	if !IsValid(other:GetPhysicsObject()) then return end
	if (other:GetClass() == self:GetClass()) then return end
	if (other:IsPlayer() and table.HasValue(self.Seats, other:GetVehicle())) then return end

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
	local t, perc = self:GetProgress()
	local p = math.pow(perc, 0.1)
	local rotAng = 0

	local percC = math.Clamp(p, 0, 1)
	self.ShadowControl.pos = LerpVector(percC, self.StartPos, self.GoalPos)
	self.ShadowControl.angle = Angle(self.StartAngles)
	self.ShadowControl.angle:RotateAroundAxis(self.StartAngles:Forward(), rotAng)
end

function ENT:PhysicsLeaving(phys, deltatime)
	local t, perc = self:GetProgress()
	local dist = (self.StartPos - self.GoalPos):Length()
	local pos = 0.5 * (500) * math.pow(t, 2) -- (1/2)at^2 = position
	local rotAng = 0

	self.ShadowControl.pos = LerpVector(pos/dist, self.StartPos, self.GoalPos)
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
		end
	end

	if self.MoveState == MOVE_LEAVING and IsValid(self.ExitPortal) then 
		if self.ExitPortal:DistanceToVoid(self:GetRear()) > 0 then 
			self.MoveState = MOVE_STATIONARY
			self.GoalPos = self:GetPos()
		end
	end
end

function ENT:OnRemove()
	self:StopSound("jazz_bus_accelerate")
	self:StopSound("jazz_bus_accelerate2")
	self:StopSound("jazz_bus_idle")
end