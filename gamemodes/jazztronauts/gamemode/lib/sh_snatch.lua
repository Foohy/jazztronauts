if SERVER then

	AddCSLuaFile()
	util.AddNetworkString("remove_prop_scene")

end

module( "snatch", package.seeall )

local SV_SendPropSceneToClients = nil
local SV_HandleEntityDestruction = nil

local CL_CopyPropToClient = nil
local CL_CopyRagdollPose = nil

local meta = {}
meta.__index = meta

function meta:Init( data )

	if data then

		for k,v in pairs( data ) do self[k] = v end

	end

	self.time = self.time or CurTime()
	return self

end

function meta:SetMode( mode )

	self.mode = mode

end

function meta:StartProp( prop, kill, delay )

	if not SERVER then return end

	self.real = prop

	if not IsValid( self.real ) then return false end
	if self.real.doing_removal then return false end

	self.real.doing_removal = true

	SV_SendPropSceneToClients( self )
	SV_HandleEntityDestruction( self.real, kill, delay )

	return true

end

function meta:RunProp( prop )

	if SERVER then return end

	self.real = prop

	if not IsValid( self.real ) then return nil end

	self.fake, self.is_ragdoll = CL_CopyPropToClient( self.real, self )
	self.is_prop = true

	--Draw the fake entity
	self.fake:SetNoDraw( false )

	--Don't draw the real entity
	self.real:SetNoDraw( true )
	self.real:DestroyShadow()

	hook.Call( "HandlePropSnatch", GAMEMODE, self )

end

function meta:Finish()

	local fake = self:GetEntity()

	if not self.is_ragdoll then
		--DO NOT EVER DO THIS ON A RAGDOLL, IT CRASHES HARD
		fake:PhysicsDestroy()
	else

		--CSEnts linger for a bit before being garbage collected,
		--freeze the ragdoll so it doesn't make any noise.
		for i=0, fake:GetPhysicsObjectCount()-1 do

			local phys = fake:GetPhysicsObjectNum(i)
			phys:EnableMotion(false)

		end

	end

	--We're done with the CSEnt, so don't draw it
	fake:SetNoDraw( true )

end

function meta:GetStartTime() return self.time end
function meta:GetRealEntity() return self.real end
function meta:GetEntity() return self.fake end
function meta:GetMode() return self.mode end

function New( data )

	return setmetatable( {}, meta ):Init( data )

end


if SERVER then

	SV_HandleEntityDestruction = function( ent, owner, kill, delay )

		timer.Simple(delay or .02, function()

			if ( ent:IsPlayer() or ent:IsNPC() ) and kill then

				if not string.find( ent:GetClass(), "strider" ) then
					if ent:IsPlayer() then
						ent:KillSilent()
					else
						ent:TakeDamage(10000, owner, self)
					end
				else
					ent:TakeDamage(2, owner, self)
				end

			end

			if not ent:IsPlayer() then
				print("REMOVED: " .. tostring( ent ))
				ent:Remove()
			else
				print("I GUESS WE DIDN'T REMOVE: " .. tostring( ent ))
				ent.doing_removal = false
			end
			
		end )

		if not ent:IsPlayer() then

			local phys = ent:GetPhysicsObject()

			--Disable physics as much as possible
			if phys:IsValid() then

				phys:EnableCollisions(false)
				phys:EnableMotion(false)

			end

		end

	end

	SV_SendPropSceneToClients = function( scene, ply )

		local ent = scene:GetRealEntity()
		local phys = ent:GetPhysicsObject()

		--Send prop info to client
		net.Start( "remove_prop_scene" )
		net.WriteUInt( scene.mode or 1, 8 )
		net.WriteEntity( ent )
		net.WriteFloat( scene.time )
		net.WriteVector( phys:IsValid() and phys:GetVelocity() or Vector(0,0,0) )
		net.WriteVector( phys:IsValid() and phys:GetAngleVelocity() or Vector(0,0,0) )
		net.Send( ply or player.GetAll() )

	end

elseif CLIENT then

	local function CL_ShouldMakeRagdoll( ent )

		--This one doesn't work for some reason
		if string.find( ent:GetClass(), "npc_clawscanner" ) then return false end

		--Check if modelinfo string contains the phrase "ragdollconstraint"
		return string.find( util.GetModelInfo( ent:GetModel() ).KeyValues or "", "ragdollconstraint" ) ~= nil

	end

	CL_CopyRagdollPose = function( from, to, data )

		from:SetupBones()

		for i=0, to:GetPhysicsObjectCount()-1 do

			local boneid = from:TranslatePhysBoneToBone( i )
			if boneid > -1 then

				local mtx = from:GetBoneMatrix( boneid )
				local phys = to:GetPhysicsObjectNum( i )
				if phys then

					phys:SetPos( mtx:GetTranslation(), true )
					phys:SetAngles( mtx:GetAngles() )
					phys:Wake()
					phys:SetVelocity( data.vel )
					phys:AddAngleVelocity( data.avel )

				end

			end

		end

	end

	local nextEntityID = 0
	CL_CopyPropToClient = function( ent, data )

		--Check if a ragdoll should be made
		local should_ragdoll = CL_ShouldMakeRagdoll( ent )

		--Create clientside entity
		local cl = ManagedCSEnt( "scene_entity_" .. tostring(nextEntityID), ent:GetModel(), should_ragdoll )
		nextEntityID = nextEntityID + 1

		--Copy basic parameters
		cl:SetPos( ent:GetPos() )
		cl:SetAngles( ent:GetAngles() )
		cl:SetSkin( ent:GetSkin() )
		cl:CreateShadow()

		if not data then

			data = {
				vel = ent:GetPhysicsObject():GetVelocity(),
				aval = ent:GetPhysicsObject():GetAngleVelocity(),
			}

		end

		if should_ragdoll then

			--Copy ragdoll pose
			CL_CopyRagdollPose( ent, cl, data )

		else

			cl:PhysicsInit( SOLID_VPHYSICS )
			local phys = cl:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocity( data.vel )
				phys:AddAngleVelocity( data.avel )
			end			

		end

		return cl, should_ragdoll

	end


	local function CL_RecvPropSceneFromServer()

		--Read the net
		local mode = net.ReadUInt( 8 )
		local ent = net.ReadEntity()
		local time = net.ReadFloat()
		local vel = net.ReadVector()
		local avel = net.ReadVector()

		--Entity needs to exist
		if not ent:IsValid() then return end

		--Run scene on client
		New( {
			mode = mode,
			time = time,
			vel = vel,
			avel = avel,			
		} ):RunProp( ent )

	end
		
	net.Receive("remove_prop_scene", CL_RecvPropSceneFromServer)

end