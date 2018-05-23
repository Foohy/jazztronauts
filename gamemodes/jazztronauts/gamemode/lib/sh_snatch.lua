if SERVER then

	AddCSLuaFile()
	util.AddNetworkString("remove_prop_scene")
	util.PrecacheModel( "models/hunter/blocks/cube025x025x025.mdl" )

end

module( "snatch", package.seeall )

removed_brushes = removed_brushes or {}

-- Voidmesh stuff, rendered separately in jazzvoid module
max_map_verts = 2048
map_meshes = map_meshes or {}
current_mesh = current_mesh or { num = 1, mesh = nil, vertices = {} }

void_mat = nil

local SV_SendPropSceneToClients = nil
local SV_HandleEntityDestruction = nil

local CL_CopyPropToClient = nil
local CL_CopyRagdollPose = nil

local meta = {}
meta.__index = meta

local map = bsp.GetCurrent( nil, SERVER )

print("NOW WE LOAD LUMPS")

local function findPropProxy( id )

	for k,v in pairs( ents.FindByClass( "jazz_static_proxy") ) do
		if v:GetID() == id then return v end
	end

end

/*
	BIG FAT #TODO: TO BOTH FOOHY AND ZAK
	THIS IS TEMPORARY. FIX THIS. BAD DESIGN ALERT.
*/
local function onSnatchInfoReady()

	if SERVER then

		for k,v in pairs( map.props or {} ) do
			local exist = findPropProxy( v.id )
			if not exist then

				local ent = ents.Create("jazz_static_proxy")
				if not IsValid( ent ) then continue end

				ent:SetID( v.id )
				ent:SetPos( v.origin )
				ent:SetAngles( v.angles )
				ent:SetModel( Model( v.model ) )
				ent:Spawn()

			end
		end

	end

	hook.Call("JazzSnatchMapReady", GAMEMODE)
end
if SERVER then

	map:LoadLumps({
		bsp.LUMP_BRUSHES,
		bsp.LUMP_GAME_LUMP,
	}, onSnatchInfoReady)

else

	map:LoadLumps({
		bsp.LUMP_BRUSHES,
		bsp.LUMP_FACES,
		bsp.LUMP_TEXINFO,
	}, onSnatchInfoReady)

end


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

function TakeItAll()

	if map:IsLoading() then print("STILL LOADING") return end

	local t = 0.1

	for k,v in pairs( map:GetBrushes() ) do

		v:CreateWindings()

		local center = (v.min + v.max) / 2

		timer.Simple( t, function()

			New():StartWorld( center, player.GetAll()[1] )

		end)

		t = t + .04

	end

end

function meta:StartWorld( position, owner, brushid )

	if not SERVER then return end

	self.real = Entity(0)
	self.owner = owner
	self.position = position
	self.is_prop = false
	self.is_world = true

	if map:IsLoading() then print("STILL LOADING") return end

	if not brushid then
		for k,v in pairs( map:GetBrushes() ) do
			if bit.band(v.contents, CONTENTS_SOLID) != CONTENTS_SOLID then continue end
			if v:ContainsPoint( position ) and not removed_brushes[k] then
				brushid = k
				break
			end

		end
	end

	if not brushid or removed_brushes[brushid] == true then return end
	removed_brushes[brushid] = true

	self.brush = brushid

	//print("***SNATCH BRUSH: " .. brushid .. " ***")
	SV_SendPropSceneToClients( self )

end

local function emptySide(side)
	return !side.texinfo or side.texinfo.texdata.material == "TOOLS/TOOLSNODRAW"
end

local idx = 0
function meta:AppendBrushToMapMesh(brush)
	
	-- Update the current mesh
	current_mesh.mesh = ManagedMesh( "propsnatcher_voidmesh" .. CurTime() .. "_" .. idx, void_mat)
	idx = idx + 1

	-- Add vertices for every side
	local to_brush = brush.center
	for _, side in pairs(brush.sides) do
		if not side.winding or emptySide(side) then continue end

		local texinfo = side.texinfo
		local texdata = texinfo.texdata
		side.winding:Move( to_brush )
		side.winding:EmitMesh(texinfo.st, texinfo.lst, texdata.width, texdata.height, -to_brush, current_mesh.vertices)
		side.winding:Move( -to_brush )

	end

	-- Update with all of the meshes
	current_mesh.mesh:BuildFromTriangles(current_mesh.vertices)
	map_meshes[current_mesh.num] = current_mesh.mesh

	-- Enforce a soft limit. If the mesh is now over the vert limit, spill over into a new mesh next time
	if #current_mesh.vertices > max_map_verts then
		print("Finished mesh: ", current_mesh.num, " (", #current_mesh.vertices, " vertices)")
		current_mesh.num = current_mesh.num + 1
		current_mesh.vertices = {}
	end
end

next_brush_mesh_id = next_brush_mesh_id or 0
local vec_one = Vector(1, 1, 1)
function meta:RunWorld( brush_id )

	if map:IsLoading() then print("STILL LOADING") return end

	local brush_list = map:GetBrushes()
	local brush = brush_list[brush_id]:Copy()

	if not brush then
		ErrorNoHalt( "Brush not found: " .. tostring( brush_id ))
		return
	end

	-- extrude out from sides (TWEAK!!)
	local extrude = -1
	for k, side in pairs( brush.sides ) do
		//if emptySide(side) then continue end
		side.plane.dist = side.plane.dist + extrude
	end

	local convex = {}

	brush:CreateWindings()

	brush.center = (brush.min + brush.max) / 2
	local to_center = -brush.center

	//print("TRANSLATE: " .. tostring( to_center ) )

	for _, side in pairs( brush.sides ) do
		if not side.winding or not side.texinfo then continue end
		side.winding:Move( to_center )

		local texinfo = side.texinfo
		local texdata = texinfo.texdata
		local material = Material( texdata.material )

		//print( texdata.material )

		next_brush_mesh_id = next_brush_mesh_id + 1
		side.winding:CreateMesh( "brushpoly_" .. next_brush_mesh_id, material, texinfo.st, texinfo.lst, texdata.width, texdata.height, -to_center )

		for _, point in pairs( side.winding.points ) do

			table.insert( convex, point )

		end

	end

	table.insert( removed_brushes, brush )
	
	-- Update the mesh that encompasses all of the void geometry
	self:AppendBrushToMapMesh(brush)

	//print("WINDINGS READY, CREATE BRUSH PROXY")

	local entity = ManagedCSEnt( "brushproxy_" .. brush_id, "models/hunter/blocks/cube025x025x025.mdl", false )
	local actual = entity:Get()

	actual.mesh = test_mesh
	actual:SetPos( brush.center - EyeAngles():Forward() * 5 )
	--actual:PhysicsInitConvex( convex )
	--actual:PhysicsInit( SOLID_VPHYSICS )
	--actual:SetSolid( SOLID_VPHYSICS )
	--actual:SetMoveType( MOVETYPE_VPHYSICS )
	actual:SetRenderBounds( brush.min - brush.center, brush.max - brush.center )
	actual:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	//actual:SetModelScale( 0 )
	--actual:GetPhysicsObject():Wake()
	--actual:GetPhysicsObject():AddVelocity( Vector(0,0,100) )
	actual.brush = brush
	actual.RenderOverride = function( self )

		if self.hide then return end

		//actual:DrawModel()

		local mtx = Matrix()
		mtx:SetTranslation( actual:GetPos() )
		mtx:SetAngles( actual:GetAngles() )
		mtx:SetScale(vec_one * (actual:GetModelScale() or 1))

		cam.PushModelMatrix( mtx )
		self.brush:Render()
		cam.PopModelMatrix()

	end

	self.handle = entity
	self.fake = actual
	self.real = actual

	//print("PROXY READY, SNATCH IT")

	hook.Call( "HandlePropSnatch", GAMEMODE, self )

end

function meta:StartProp( prop, owner, kill, delay )

	if not SERVER then return end

	self.real = prop
	self.owner = owner

	if not IsValid( self.real ) then return false end
	if self.real.doing_removal then return false end

	self.position = self.real:GetPos()
	self.real.doing_removal = true

	SV_SendPropSceneToClients( self )
	SV_HandleEntityDestruction( self.real, owner, kill, delay )

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

	local function tryPickUp(ply, ent)
		if not IsValid(ply) or not IsValid(ent) then return end
		ent:SetPos(ply:GetPos())
	end

	-- Store outputs (manually) on props so we can manually invoke outputs
	local outputs = { "OnBreak", "OnPlayerUse" }
	hook.Add("EntityKeyValue", "JazzManuallyStoreOutputs", function(ent, key, value)
		if not table.HasValue(outputs, key) then
			return 
		end

		-- Install TriggerOutput and StoreOutput
		if not ent.TriggerOutput then
			local old = _G.ENT -- should be nil, but I ain't steppin on any toes
			_G.ENT = ent
			include("base/entities/entities/base_entity/outputs.lua")
			_G.ENT = old
		end

		ent:StoreOutput(key, value)
	end)

	SV_HandleEntityDestruction = function( ent, owner, kill, delay )

		timer.Simple(delay or .12, function()
			if not IsValid(ent) then return end

			-- If we stole a weapon, don't actually delete it if it's now equipped by a player
			if ent:IsWeapon() and IsValid(ent:GetParent()) and ent:GetParent():IsPlayer() then
				print("NOT REMOVING NOW-IN-USE WEAPON")
				return
			end

			-- Specific player/NPC logic to register as a kill
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
			ent:SetTrigger(true)
			ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

			-- For weapons, have the activator try to 'pick up' the weapon
			if not ent:IsNPC() then
				tryPickUp(owner, ent) -- Give the entity a chance to 'pick up' whatever it is
			end

			-- Try to trigger correspondong outputs if the map relied on the prop
			local name = ent:GetName()
			if ent.TriggerOutput then
				ent:TriggerOutput("OnBreak", owner)
				ent:TriggerOutput("OnPlayerUse", owner)
			end
		end

	end

	SV_SendPropSceneToClients = function( scene, ply )

		local ent = scene:GetRealEntity()
		local phys = nil

		if not scene.is_world then
			phys = ent:GetPhysicsObject()
		end

		--Send prop info to client
		net.Start( "remove_prop_scene" )
		net.WriteUInt( scene.mode or 1, 8 )
		net.WriteBit( scene.is_world and 1 or 0 )
		net.WriteFloat( scene.time )
		net.WriteEntity( scene.owner )

		if not scene.is_world then

			net.WriteEntity( ent )
			net.WriteVector( phys:IsValid() and phys:GetVelocity() or Vector(0,0,0) )
			net.WriteVector( phys:IsValid() and phys:GetAngleVelocity() or Vector(0,0,0) )

		else

			net.WriteVector( scene.position )
			net.WriteInt( scene.brush, 32 )

		end
	
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
		local is_world = net.ReadBit() == 1
		local time = net.ReadFloat()
		local owner = net.ReadEntity()

		if not is_world then

			local ent = net.ReadEntity()
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
				owner = owner,		
			} ):RunProp( ent )

		else

			local pos = net.ReadVector()
			local brush = net.ReadInt( 32 )

			New( {
				mode = mode,
				time = time,
				pos = pos,
				owner = owner,
			} ):RunWorld( brush )

		end

	end
		
	net.Receive("remove_prop_scene", CL_RecvPropSceneFromServer)

end