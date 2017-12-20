-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model			= "models/props/cs_assault/streetsign01.mdl"

ENT.BusOffset = Vector(90, 230, 0)
function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end

	-- Hook into map change events
	if SERVER then
		hook.Add("JazzMapRandomized", "SpawnBusHook", function(newmap)
			self:OnMapChanged(newmap)
		end )
	end
end

function ENT:OnMapChanged(newmap)
	local ang = self:GetAngles() + Angle(0, -90, 0)

	local bus = ents.Create( "ent_bus_hub" )
	local busOff = Vector(self.BusOffset)

	busOff:Rotate(ang)
	bus:SetPos(self:GetPos() + busOff)
	bus:SetAngles(ang)
	bus:SetDestination(newmap)
	bus:Spawn()

	print(newmap)
end

if SERVER then return end

function ENT:Draw()
	self:DrawModel()
end
