if SERVER then

	AddCSLuaFile()
	util.AddNetworkString("remove_prop_scene")
	util.PrecacheModel( "models/hunter/blocks/cube025x025x025.mdl" )

end

module( "snatch", package.seeall )

local debug_resnatch = false

removed_brushes = removed_brushes or {}
local waitingBrushes = {}

removed_displacements = removed_displacements or {}
local waitingDisplacements = {}

removed_staticprops = removed_staticprops or {}
local waitingProps = {}

-- Networked table of removed brushes
if SERVER then
	nettable.Create("snatch_removed_brushes", nettable.TRANSMIT_ONCE)
	nettable.Set("snatch_removed_brushes", removed_brushes)

	nettable.Create("snatch_removed_displacements", nettable.TRANSMIT_ONCE)
	nettable.Set("snatch_removed_displacements", removed_displacements)

	nettable.Create("snatch_removed_staticprops", nettable.TRANSMIT_ONCE)
	nettable.Set("snatch_removed_staticprops", removed_staticprops)
end

-- Voidmesh stuff, rendered separately in jazzvoid module
MAX_MAP_VERTS = 2048
map_meshes = map_meshes or {}
current_mesh = current_mesh or { num = 1, mesh = nil, vertices = {} }

void_mat = nil

local SV_SendPropSceneToClients = nil
local SV_HandleEntityDestruction = nil

local CL_CopyPropToClient = nil
local CL_CopyRagdollPose = nil

local meta = {}
meta.__index = meta

local map = bsp2.GetCurrent()

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

	hook.Call("JazzSnatchMapReady", GAMEMODE)
end

-- Add loading state info to map loading
local loadTask = map:GetLoadTask()
if loadTask then
	function loadTask:chunk(name, count)
		loadicon.PushLoadState("LOADING: " .. string.upper(name))
	end

	function loadTask:chunkdone(name, count, tab)
		loadicon.PopLoadState()
	end
end

hook.Add( "CurrentBSPReady", "snatchReady", onSnatchInfoReady )

function IsBrushStolen(brushid)
	return removed_brushes[brushid] != nil
end

function IsDisplacementStolen(dispid)
	return removed_displacements[dispid] != nil
end

if SERVER then

	--[[

			for k,v in pairs( map.props or {} ) do
			local exist = findPropProxy( v.id )
			if not exist then

				local ent = ents.Create("jazz_static_proxy")
				if not IsValid( ent ) then print("!!!Failed to create proxy") continue end

				ent:SetID( v.id )
				ent:SetPos( v.origin )
				ent:SetAngles( v.angles )
				ent:SetModel( Model( v.model ) )
				ent:Spawn()

			end
		end
	]]

	function SpawnProxies()
		print("Server loaded map, creating proxies: " .. tostring(#(map.props or {})))

		for k,v in pairs( map.props or {} ) do
			local exist = findPropProxy( v.id )
			if not exist then

				local ent = ents.Create("jazz_static_proxy")
				if not IsValid( ent ) then print("!!!Failed to create proxy") continue end

				ent:SetID( v.id )
				ent:SetPos( v.origin )
				ent:SetAngles( v.angles )
				ent:SetModel( Model( v.model ) )
				ent:Spawn()

			end
		end
	end
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

	for k,v in pairs( map.brushes ) do

		--v:CreateWindings()

		local center = v.center

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
	self.is_displacement = false

	if map:IsLoading() then
		print("BRUSH UPDATE BUT NOT LOADED")
		return
	end

	if not brushid then
		for k,v in pairs( map.brushes ) do
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

	hook.Call("JazzBrushStolen", GAMEMODE, brushid)
end

function meta:StartDisplacement( position, owner, dispid )
	if not SERVER then return end

	self.real = Entity(0)
	self.owner = owner
	self.position = position
	self.is_prop = false
	self.is_world = true
	self.is_displacement = true

	if map:IsLoading() then
		print("BRUSH UPDATE BUT NOT LOADED")
		return
	end

	if not dispid or removed_displacements[dispid] == true then return end
	removed_displacements[dispid] = true

	self.brush = dispid

	-- print("***SNATCH DISPLACEMENT: " .. dispid .. " ***")
	SV_SendPropSceneToClients( self )

	hook.Call("JazzDisplacementStolen", GAMEMODE, dispid)
end


local function emptySide(side)
	return !side.texinfo or side.texinfo.texdata.material == "TOOLS/TOOLSNODRAW"
end

function meta:AppendBrushToMapMesh(brush)

	local new_vertices = {}

	-- Add vertices for every side
	local to_brush = brush.center

	for _, side in pairs(brush.sides) do
		if not side.winding or emptySide(side) then continue end

		local texinfo = side.texinfo
		local texdata = texinfo.texdata
		side.winding:Move( to_brush )
		side.winding:EmitMesh(texinfo.textureVecs, texinfo.lightmapVecs, texdata.width, texdata.height, -to_brush, new_vertices)
		side.winding:Move( -to_brush )

	end

	-- Add to optimized map mesh
	self:AppendVerticesToMapMesh(new_vertices)
end

function meta:AppendDisplacementToMapMesh(disp_id)

	local new_vertices = {}
	map:CreateDisplacementMesh(disp_id, 0.5, nil, new_vertices)
	
	-- Update with all of the meshes
	self:AppendVerticesToMapMesh(new_vertices)
end

function meta:AppendVerticesToMapMesh(new_verts)
	-- Update the current mesh
	current_mesh.mesh = ManagedMesh(void_mat)

	table.Add(current_mesh.vertices, new_verts)

	-- Update with all of the meshes
	current_mesh.mesh:BuildFromTriangles(current_mesh.vertices)
	map_meshes[current_mesh.num] = current_mesh.mesh

	-- Enforce a soft limit. If the mesh is now over the vert limit, spill over into a new mesh next time
	if #current_mesh.vertices > MAX_MAP_VERTS then
		print("Finished mesh: ", current_mesh.num, " (", #current_mesh.vertices, " vertices)")
		current_mesh.num = current_mesh.num + 1
		current_mesh.vertices = {}
	end
end

local vec_one = Vector(1, 1, 1)
local invcolor = 1/255
local lightmapTex = nil
if CLIENT then
	local lightmaprt = irt.New("jazz_snatch_lightmaptex", 64, 64)
	lightmapTex = lightmaprt:GetTarget()
	lightmaprt:Render(function() render.Clear(12, 12, 12, 255) end )
end
function meta:RunDisplacement(disp_id)
	if map:IsLoading() then
		print("disp_id " .. disp_id .. " stolen with no map loaded, saving for later")
		waitingDisplacements[brush_id] = true
		return
	end

	local disp_list = map.displacements
	local disp = disp_list[disp_id]--:Copy( true )

	if not disp then
		ErrorNoHalt( "Displacement not found: " .. tostring( disp_id ))
		return
	end


	table.insert( removed_displacements, disp )

	self:AppendDisplacementToMapMesh(disp_id)

	if self.mode then
		local material = Material( disp.face.texinfo.texdata.material )
		
		local current_disp_mesh, current_disp_center, current_disp_material = map:CreateDisplacementMesh( disp_id, 0.5, material )

		local entity = ManagedCSEnt( "dispproxy_" .. disp_id, "models/hunter/blocks/cube025x025x025.mdl", false )
		local actual = entity:Get()

		actual.mesh = test_mesh
		actual:SetPos( current_disp_center - EyeAngles():Forward() * 5 )

		actual:SetRenderBounds( disp.mins - current_disp_center, disp.maxs - current_disp_center )
		actual:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		actual.displacement = disp
		actual.RenderOverride = function( self )

			if self.hide then return end

			//actual:DrawModel()

			local mtx = Matrix()
			mtx:SetTranslation( actual:GetPos() )
			mtx:SetAngles( actual:GetAngles() )
			mtx:SetScale(vec_one * (actual:GetModelScale() or 1))

			cam.PushModelMatrix( mtx )
				render.SetLightmapTexture(lightmapTex)
				render.SetLightingOrigin( current_disp_center)
				render.SetMaterial(current_disp_material)
				
				current_disp_mesh:Draw()
			cam.PopModelMatrix()

		end

		self.handle = entity
		self.fake = actual
		self.real = actual

		//print("PROXY READY, SNATCH IT")

		hook.Call( "HandlePropSnatch", GAMEMODE, self )
	end
end

function meta:RunWorld( brush_id )

	if map:IsLoading() then
		print("brush_id " .. brush_id .. " stolen with no map loaded, saving for later")
		waitingBrushes[brush_id] = true
		return
	end

	local brush_list = map.brushes
	local brush = brush_list[brush_id]:Copy( true )

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

		if self.mode then
			side.winding:CreateMesh( material, texinfo.textureVecs, texinfo.lightmapVecs, texdata.width, texdata.height, -to_center )
		end
	end

	table.insert( removed_brushes, brush )

	-- Update the mesh that encompasses all of the void geometry
	self:AppendBrushToMapMesh(brush)

	//print("WINDINGS READY, CREATE BRUSH PROXY")
	if self.mode then
		local entity = ManagedCSEnt( "brushproxy_" .. brush_id, "models/hunter/blocks/cube025x025x025.mdl", false )
		local actual = entity:Get()

		actual.mesh = test_mesh
		actual:SetPos( brush.center - EyeAngles():Forward() * 5 )
		actual:SetRenderBounds( brush.min - brush.center, brush.max - brush.center )
		actual:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		actual.RenderOverride = function( self )

			if self.hide then return end

			//actual:DrawModel()

			local mtx = Matrix()
			mtx:SetTranslation( actual:GetPos() )
			mtx:SetAngles( actual:GetAngles() )
			mtx:SetScale(vec_one * (actual:GetModelScale() or 1))

			cam.PushModelMatrix( mtx )
			brush:Render()
			cam.PopModelMatrix()

		end

		self.handle = entity
		self.fake = actual
		self.real = actual

		//print("PROXY READY, SNATCH IT")

		hook.Call( "HandlePropSnatch", GAMEMODE, self )
	end

end

function meta:StartProp( prop, owner, kill, delay )

	if not SERVER then return end

	self.real = prop
	self.owner = owner

	if not IsValid( self.real ) then return false end
	if self.real.doing_removal then return false end

	self.position = self.real:GetPos()
	if not debug_resnatch then
		self.real.doing_removal = true
	end

	-- If proxy, save to list of stolen props
	if self.real.IsProxy then
		if not debug_resnatch then
			removed_staticprops[self.real:GetID()] = true
		end
		--delay = (delay or 0) + 60
	end

	SV_SendPropSceneToClients( self )

	if not debug_resnatch then
		SV_HandleEntityDestruction( self.real, owner, kill, delay )
	end

	hook.Call("JazzPropStolen", GAMEMODE, prop)

	return true

end

function meta:RunProp( prop )

	if SERVER then return end

	self.real = prop

	if not IsValid( self.real ) or not self.real:GetModel() then return nil end

	self.fake, self.is_ragdoll = CL_CopyPropToClient( self.real, self )
	self.is_prop = true

	--Draw the fake entity
	self.fake:SetNoDraw( false )

	--Don't draw the real entity
	self.real:SetNoDraw( true )
	self.real:DestroyShadow()

	hook.Call( "HandlePropSnatch", GAMEMODE, self )

end

local staticPropsInView = {}
local function ensureExpandedProp(propinfo)
	local prop = propinfo.csent

	-- Recreate static prop
	if not IsValid(prop) then
		prop = ClientsideModel(propinfo.mdl)
	end

	-- Set position to match where we want to test
	prop:SetPos( propinfo.mtx:GetTranslation())
	prop:SetAngles( propinfo.mtx:GetAngles() )
	prop.propinfo = propinfo

	-- Override rendering to render the expanded prop mesh later on
	function prop:RenderOverride()
		staticPropsInView[#staticPropsInView + 1] = self.propinfo
	end

	propinfo.csent = prop
end

expanded_models = expanded_models or {}
expanded_props = expanded_props or {}
local next_prop_proxy_id = 0
local load_locks = {}

function meta:RunStaticProp( propid, propproxy )
	if SERVER then return end

	-- Check if map is still loading
	if map:IsLoading() then
		print("prop id " .. propid .. " stolen with no map loaded, saving for later")
		waitingProps[propid] = true
		return
	end

	-- Make sure this is actually a valid static prop id
	local pdata = map.props[propid]
	if not pdata then
		ErrorNoHalt("Invalid static prop id " .. propid)
		return
	end

	local mdl = pdata.model

	if mdl == nil then return end

	local me = self
	local t = task.New( function()

		-- Grab prop data
		--MsgC(Color(100,255,100), "I want to load: " .. tostring(mdl) .. "\n")

		while load_locks[mdl] do
			MsgC(Color(100,255,100), "Load lock: " .. tostring(mdl) .. "\n")
			task.Sleep(.1)
		end

		--MsgC(Color(100,160,255), "I begin loading: " .. tostring(mdl) .. "\n")

		local b,e = pcall(function()
			if not expanded_models[mdl] or debug_resnatch then
				load_locks[mdl] = true
				expanded_models[mdl] = MakeExpandedModel(mdl, nil, true )
				load_locks[mdl] = false
			end
		end)

		if expanded_models[mdl] == nil then return end

		task.Yield("snatch")

	end, 4 )

	function t:progress()
		--Msg(".")
	end

	function t:section( sec )
		--MsgC(Color(255,100,255), "\n\nENTER SECTION: " .. tostring(sec) .. "\n\n")
	end

	function t:snatch()

		local mtx = Matrix()
		mtx:SetTranslation( pdata.origin )
		mtx:SetAngles( pdata.angles )

		me.time = CurTime()

		local propTbl = {
			mdl = mdl,
			mesh = expanded_models[mdl],
			mtx = mtx,
		}

		table.insert( expanded_props, propTbl)

		-- Create a clientside entity that draws the expanded prop
		ensureExpandedProp(propTbl)

		next_prop_proxy_id = next_prop_proxy_id + 1
		propproxy = ManagedCSEnt("cl_static_prop_proxy" .. mdl .. next_prop_proxy_id, mdl)

		if IsValid(propproxy) then
			propproxy:SetPos( pdata.origin )
			propproxy:SetAngles( pdata.angles )
			me.vel = Vector()
			me.avel = Vector()
			me:RunProp(propproxy)
		end

	end
	//hook.Call( "HandlePropSnatch", GAMEMODE, self )
end

function meta:Finish()

	local fake = self:GetEntity()
	if not IsValid(fake) then return end

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
	local ignorePickupClasses = {
		"jazz_static_proxy",
		"prop_physics",
		"prop_physics_multiplayer",
		"prop_dynamic",
		"prop_dynamic_override"
	}

	local function tryPickUp(ply, ent)
		if not IsValid(ply) or not IsValid(ent) then return end
		local class = ent:GetClass()
		if table.HasValue(ignorePickupClasses, class) then return end

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
				ent:TriggerOutput("OnOpen", owner)
				ent:TriggerOutput("OnFullyOpen", owner)
			end

			ent:Fire("Unlock", nil, 0, owner, owner)
			ent:Fire("Open", nil, 0, owner, owner)
			ent:Fire("Use", nil, 0, owner, owner)

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

		if scene.is_world then
			net.WriteBit( scene.is_displacement and 1 or 0 )	
		else
			net.WriteBit( scene.real.IsProxy and 1 or 0 )
		end
		net.WriteFloat( scene.time )
		net.WriteEntity( scene.owner )

		if not scene.is_world then

			net.WriteEntity( ent )

			-- Write static prop id for proxies
			if scene.real.IsProxy then
				net.WriteUInt(ent:GetID(), 16)
			else
				net.WriteVector( phys:IsValid() and phys:GetVelocity() or Vector(0,0,0) )
				net.WriteVector( phys:IsValid() and phys:GetAngleVelocity() or Vector(0,0,0) )
			end

		else

			net.WriteVector( scene.position )
			net.WriteInt( scene.brush, 32 )

		end

		net.Send( ply or player.GetAll() )

	end

elseif CLIENT then

	local function CL_ShouldMakeRagdoll( ent )
		if not IsValid(ent) then return false end

		--This one doesn't work for some reason
		if string.find( ent:GetClass(), "npc_clawscanner" ) then return false end

		--Check if modelinfo string contains the phrase "ragdollconstraint"
		return string.find( ( util.GetModelInfo( ent:GetModel() ) or {} ).KeyValues or "", "ragdollconstraint" ) ~= nil

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
		local is_proxy = false
		local is_displacement = false
		if is_world then
			is_displacement = net.ReadBit() == 1
		else
			is_proxy = net.ReadBit() == 1
		end
		local time = net.ReadFloat()
		local owner = net.ReadEntity()

		if is_world then
			local pos = net.ReadVector()
			local brush = net.ReadInt( 32 )

			if is_displacement then
				New( {
					mode = mode,
					time = time,
					pos = pos,
					owner = owner,
				} ):RunDisplacement( brush )
			else
				New( {
					mode = mode,
					time = time,
					pos = pos,
					owner = owner,
				} ):RunWorld( brush )
			end

		elseif is_proxy then
			local ent = net.ReadEntity()
			local propid = net.ReadUInt(16)

			New( {
				mode = mode,
				time = time,
				vel = Vector(),
				avel = Vector(),
				owner = owner,
				is_proxy = true
			} ):RunStaticProp(propid, ent )

		else //Good ol' fashion entity

			local ent = net.ReadEntity()
			local vel = net.ReadVector()
			local avel = net.ReadVector()

			if not IsValid(ent) then return end

			--Run scene on client
			New( {
				mode = mode,
				time = time,
				vel = vel,
				avel = avel,
				owner = owner,
				is_proxy = false
			} ):RunProp( ent )
		end
	end


	local function stealBrushes(brushes)
		local total = table.Count(brushes)
		local cur = 0
		for k, v in pairs(brushes) do
			cur = cur + 1
			if removed_brushes[k] then continue end

			-- Steal the brush, but don't bother with any effects
			New( {} ):RunWorld( k )
			task.YieldPer(5, "brushesprogress", cur, total)
		end
		task.Yield("brushesdone")
	end

	local function stealDisplacements(displacements)
		local total = table.Count(displacements)
		local cur = 0
		for k, v in pairs(displacements) do
			cur = cur + 1
			if removed_displacements[k] then continue end

			-- Steal the brush, but don't bother with any effects
			New( {} ):RunDisplacement( k )
			task.YieldPer(5, "dispsprogress", cur, total)
		end
		task.Yield("dispsdone")
	end

	local function stealStaticProps(propids)
		local total = table.Count(propids)
		local cur = 0
		for k, v in pairs(propids) do
			cur = cur + 1
			if removed_staticprops[k] then continue end

			-- Steal the prop, but don't bother with any effects
			New( {} ):RunStaticProp( k )

			task.YieldPer(5, "propsprogress", cur, total)
		end

		task.Yield("propsdone")
	end

	local function stealCurrentVoid(brushids, dispids, propids)
		local function stealVoid(brushids, dispids, propids)
			loadicon.PushLoadState("Loading stolen brushes")
			stealBrushes(brushids)

			loadicon.PushLoadState("Loading stolen displacements")
			stealDisplacements(dispids)

			loadicon.PushLoadState("Loading stolen static props")
			stealStaticProps(propids)
		end

		local loadPropsTask = task.New(stealVoid, 1, brushids, dispids, propids)
		function loadPropsTask:brushesprogress(num, total)
			local ldstr = string.format("LOADING: Stolen brushes: %d/%d (%d%%)", num, total, math.Round(num * 100 / total))
			loadicon.SetLoadState(ldstr)
		end

		function loadPropsTask:dispsprogress(num, total)
			local ldstr = string.format("LOADING: Stolen displacements: %d/%d (%d%%)", num, total, math.Round(num * 100 / total))
			loadicon.SetLoadState(ldstr)
		end

		function loadPropsTask:propsprogress(num, total)
			local ldstr = string.format("LOADING: Stolen static props: %d/%d (%d%%)", num, total, math.Round(num * 100 / total))
			loadicon.SetLoadState(ldstr)
		end

		function loadPropsTask:brushesdone()
			loadicon.PopLoadState()
		end

		function loadPropsTask:dispsdone()
			loadicon.PopLoadState()
		end

		function loadPropsTask:propsdone()
			loadicon.PopLoadState()
		end
	end

	local function precacheMapProps()

		local added = {}
		local to_load = {}
		for k,v in pairs(map.props or {}) do

			if not added[v.model] then
				added[v.model] = true
				table.insert(to_load, v.model)
			end

		end

		table.sort(to_load, function(a,b)
			return GetModelFootprint(a) > GetModelFootprint(b)
		end)

		local function run_async(mdl)

			local t = task.New( function()
				loadicon.PushLoadState("LOADING: " .. tostring(mdl))

				-- Grab prop data
				--MsgC(Color(100,255,100), "I want to load: " .. tostring(mdl) .. "\n")

				while load_locks[mdl] do
					--MsgC(Color(100,255,100), "Load lock: " .. tostring(mdl) .. "\n")
					task.Sleep(.1)
				end

				--MsgC(Color(100,160,255), "I begin loading: " .. tostring(mdl) .. "\n")

				local b,e = pcall(function()
					if not expanded_models[mdl] or debug_resnatch then
						load_locks[mdl] = true
						expanded_models[mdl] = MakeExpandedModel(mdl, nil, false )
						load_locks[mdl] = false
					end
				end)

				loadicon.PopLoadState()

				if expanded_models[mdl] == nil then return end

				task.Yield("snatch")

			end, 1 )

			function t:progress()
				--Msg(".")
			end

			function t:section( sec )
				--MsgC(Color(255,100,255), "\n\nENTER SECTION: " .. tostring(sec) .. "\n\n")
			end

			function t:OnFinished()
				if #to_load > 0 then
					local nextmdl = to_load[1]
					table.remove( to_load, 1 )
					run_async( nextmdl )
				end
			end

		end

		local first = to_load[1]
		table.remove( to_load, 1 )
		run_async( first )

	end

	local function stealBrushesInstant()
		-- Get all networked removed brushes and merge with client state
		local brushes = nettable.Get("snatch_removed_brushes")
		local allBrushes = {}
		table.Merge(allBrushes, brushes or {})
		table.Merge(allBrushes, waitingBrushes or {})

		-- Ditto with displacements
		local displacements = nettable.Get("snatch_removed_displacements")
		local allDisps = {}
		table.Merge(allDisps, displacements or {})
		table.Merge(allDisps, waitingDisplacements or {})

		-- Do the same with static props
		-- #TODO: Async load expanded brush models and wait on that
		local props = nettable.Get("snatch_removed_staticprops")
		local allProps = {}
		table.Merge(allProps, props or {})
		table.Merge(allProps, waitingProps or {})

		stealCurrentVoid(allBrushes, allDisps, allProps)

		if game.GetMap() != mapcontrol.GetHubMap() then
			precacheMapProps()
		end
	end

	--precacheMapProps()

	hook.Add("JazzSnatchMapReady", "snatchUpdateNetworkedBrushSpawn", function()	
		stealBrushesInstant()
	end )

	--precacheMapProps()

	-- Run only once when the client first joins and downloads the stolen brush list
	-- Almost always the map will still be loading, but it doesn't hurt being optimistic
	nettable.Hook("snatch_removed_brushes", "snatchUpdateWorldBrushBackup", function(changed, removed)
		if map:IsLoading() then return end

		stealBrushesInstant()
	end )


	-- Static props can sometimes disappear out from under us, so keep tabs on them
	local nextCheck = 0
	hook.Add("Think", "snatch_static_props_check", function()
		if CurTime() < nextCheck then return end
		nextCheck = CurTime() + 10

		for k, v in pairs(expanded_props) do
			ensureExpandedProp(v)
		end
	end)


	hook.Add("PostDrawTranslucentRenderables", "drawsnatchstaticprops2", function()
		if not jazzvoid.GetShouldRender() then return end

		local a,b = jazzvoid.GetVoidOverlay()

		-- Void render
		render.SetMaterial( a )
		for k,v in pairs( staticPropsInView ) do

			cam.PushModelMatrix( v.mtx )
			v.mesh:Draw()
			cam.PopModelMatrix()

		end

		-- Outline
		render.SetMaterial( b )
		for k,v in pairs( staticPropsInView ) do

			cam.PushModelMatrix( v.mtx )
			v.mesh:Draw()
			cam.PopModelMatrix()

		end

		table.Empty(staticPropsInView)

	end )


	net.Receive("remove_prop_scene", CL_RecvPropSceneFromServer)

end