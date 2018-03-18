-- Board that displays currently selected maps
AddCSLuaFile()
AddCSLuaFile("sh_honk.lua")
include("sh_honk.lua")

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
		hook.Add("JazzMapRandomized", self, function(self, newmap, wsid)
			if self.LastMap != newmap then -- Hotreload fix
				self.LastMap = newmap
				self:OnMapChanged(newmap, wsid)
			end
		end )

		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:OnMapChanged(newmap, wsid)
	local ang = self:GetAngles()
	local bus = ents.Create( "jazz_bus_hub" )
	local busOff = Vector(self.BusOffset)

	busOff:Rotate(ang)
	bus:SetPos(self:GetPos() + busOff)
	bus:SetAngles(ang)
	bus:SetMap(newmap, wsid)
	bus:Spawn()
end

function ENT:Use(activator, caller)
	-- Creating an entity directly from an ENT:Use() hook here apparently sets its position to NaN
	-- It's a bold move, but I'll fight fire with fire
	timer.Simple(0, function()
    	mapcontrol.RollMap()
	end )
end

if SERVER then return end

function ENT:Draw()
	self:DrawModel()
end
