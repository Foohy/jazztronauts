-- Taken from cinema because I wrote it there originally anyway so sue me

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.DoorOpen = Sound("doors/door1_move.wav")
ENT.DoorClose = Sound("doors/door_wood_close1.wav")
--ENT.DoorLocked = --Sound("d")

local outputs = 
{
	"OnTeleport",
	"OnUnlock",
	"OnUse",
	"OnUseLocked",
}

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)	
	self:DrawShadow( false )

	local phys = self:GetPhysicsObject()
	
	if IsValid(phys) then
		phys:SetMaterial("gmod_silent")
	end

	self:ResetSequence(self:LookupSequence("idle"))
	self:SetLocked(self.StartLocked or false)
end

function ENT:Use(activator, caller)
	if self.IsLocked then 
		self:TriggerOutput("OnUseLocked", activator)
		if self.DoorLocked then
			self:EmitSound(self.DoorLocked)
		end
		return 
	end

	self:TriggerOutput("OnUse", activator)

	if IsValid(activator) && !activator.Teleporting then
		self:StartLoading( activator )

		local sequence = self:LookupSequence("open")

		if (self:GetSequence() != sequence ) then
			self:ResetSequence(sequence)
			self:SetPlaybackRate(1.0)

			local door = self:GetLinkedDoor()
			if IsValid( door ) then
				door:ResetSequence( sequence )
				door:SetPlaybackRate( 1.0 )
			end

			self:EmitSound( self.DoorOpen )
		end
	end
end

function ENT:SetLocked(locked)
	if self.IsLocked == locked then return end

	self.IsLocked = locked
	if not self.IsLocked then
		self:TriggerOutput("OnUnlock", self)
	end
end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "Lock" then self:SetLocked(true) return true end
	if name == "Unlock" then self:SetLocked(false) return true end
	if name == "Teleport" then self:Use(activator, caller) return true end

	return false
end


function ENT:GetLinkedDoor()
	if IsValid( self.TeleportEnt ) then
		local near = ents.FindInSphere( self.TeleportEnt:GetPos(), 50 )
		for _, v in pairs( near ) do
			if IsValid( v ) && v:GetClass() == self:GetClass() then
				return v
			end
		end
	end

	return nil
end

function ENT:GetTeleportEntity()

	-- Attempt to find entity
	if !IsValid(self.TeleportEnt) then
		if self.TeleportName then
			local entities = ents.FindByName(self.TeleportName)
			if IsValid(entities[1]) then
				self.TeleportEnt = entities[1]
			end
		else
			print("ERROR: Invalid door teleport configuration.")
			print(self)
		end
	end
	
	return self.TeleportEnt

end

function ENT:StartLoading( ply )
	umsg.Start( "jazz_door_load", ply )
		umsg.Entity( self )
	umsg.End()

	ply.Teleporting = true
	ply:Freeze( true )

	timer.Simple( self.FadeTime + self.DelayTime, function()

		if IsValid( ply ) then
			//Teleport the player
			ply.Teleporting = false
			ply:Freeze( false )

			ply:EmitSound(self.DoorClose)

			local ent = self:GetTeleportEntity()
			if IsValid(ent) then
				ply:SetPos( ent:GetPos() )
				ply:SetEyeAngles( ent:GetAngles() )
			end
		end

	end )
	self.TeleportAt = CurTime() + self.FadeTime + self.DelayTime
	self.ShouldTeleport = true
end

function ENT:Think()
	if self.ShouldTeleport && CurTime() > self.TeleportAt then
		//shut the frickity front door
		local sequence = self:LookupSequence("idle")
		self:SetSequence(sequence)

		local door = self:GetLinkedDoor()
		if IsValid( door ) then
			door:SetSequence( sequence )
		end

		self:EmitSound( self.DoorClose )

		self.ShouldTeleport = false
		self.TeleportPly = nil
	end

	self:NextThink(CurTime())  
	return true
end



function ENT:KeyValue(key, value)
	local isEmpty = !value || string.len(value) <= 0
	
	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
	
	if !isEmpty then

		if key == "teleportentity" then
			self.TeleportName = value
		elseif key == "opendoorsound" then
			self.DoorOpen = Sound( value )
		elseif key == "closedoorsound" then
			self.DoorClose = Sound( value )
		elseif key == "model" then
			self:SetModel(Model(value))
		elseif key == "startlocked" then
			self.StartLocked = tobool(value)
		end
	end
end