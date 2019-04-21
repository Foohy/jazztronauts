-- Taken from cinema because I wrote it there originally anyway so sue me

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.DoorOpen = Sound("doors/door1_move.wav") //just defaults
ENT.DoorClose = Sound("doors/door_wood_close1.wav") //just defaults

PrecacheParticleSystem("jazzCandle")

function ENT:Initialize()
	self:SetModel("models/props_c17/gravestone_coffinpiece002a.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow( false )

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMaterial("gmod_silent")
	end

	self:ResetSequence(self:LookupSequence("idle"))

	-- Only spawn if NG+ and game isn't ended
	if newgame.GetResetCount() == 0 or tobool(newgame.GetGlobal("ended")) then
		self:Remove()
	end

	-- If we have somewhere to go, spawn the voter machine
	if self:GetDestination() then
		local votium = ents.Create("jazz_vote_podiums")
		votium:SetPos(self:GetPos() + self:GetAngles():Up() * -10)
		votium:SetAngles(self:GetAngles())
		votium:SetKeyValue("PodiumRadius", 85)
		votium:Spawn()
		votium:Activate()
		votium:SetParent(self)
		votium:StoreActivatedCallback(function(who_found)
			self:OnChangeDestination()
		end )

		self.VotePodium = votium
	end
end


function ENT:OnChangeDestination()
	local dest = self:GetDestination()

	if dest == self.DEST_ENCOUNTER then
		newgame.SetGlobal("unlocked_encounter", true)
		mapcontrol.Launch(mapcontrol.GetEncounterMap())
	end/*
	elseif dest == self.DEST_ENDGAME then
		newgame.SetGlobal("ending", newgame.ENDING_ECLIPSE)
		mapcontrol.Launch(mapcontrol.GetEndMaps()[newgame.ENDING_ECLIPSE])
	end
	*/

end

function ENT:Use(activator, caller)
	self:TriggerOutput("OnUse", activator)
end


function ENT:Think()

end


function ENT:KeyValue(key, value)
	local isEmpty = !value || string.len(value) <= 0

	if key == "OnTeleport" || key == "OnUnlock" || key == "OnUse" then
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
		end
	end
end