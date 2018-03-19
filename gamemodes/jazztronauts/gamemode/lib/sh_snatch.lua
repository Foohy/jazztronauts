if SERVER then

	AddCSLuaFile()
	util.AddNetworkString("remove_prop_scene")
	util.PrecacheModel( "models/hunter/blocks/cube025x025x025.mdl" )

end

module( "snatch", package.seeall )
local void_mat = nil
if CLIENT then
	local refractParams = {
		//["$basetexture"] = "_rt_FullFrameFB",
		["$normalmap"] = "glass/reflectiveglass002_normal", //concrete/concretefloor001a_normal, "effects/fisheyelense_normal", "glass/reflectiveglass002_normal"
		["$refracttint"] = "[1 0.99 1]",
		["$additive"] = 0,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 0,
		["$refractamount"] = 0.301,
		["$model"] = 1,
	}
	local refract = CreateMaterial("RefractBrushModel" .. CurTime(), "Refract", refractParams)
	void_mat = refract
end

removed_brushes = removed_brushes or {}
map_mesh = map_mesh or nil
tricount = tricount or 0

local SV_SendPropSceneToClients = nil
local SV_HandleEntityDestruction = nil

local CL_CopyPropToClient = nil
local CL_CopyRagdollPose = nil

local meta = {}
meta.__index = meta

local map = bsp.GetCurrent()

print("NOW WE LOAD LUMPS")

if SERVER then

	map:LoadLumps({
		bsp.LUMP_BRUSHES,
	})

else

	map:LoadLumps({
		bsp.LUMP_BRUSHES,
		bsp.LUMP_FACES,
		bsp.LUMP_TEXINFO,
	})

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

		t = t + .1

	end

end

function meta:StartWorld( position, owner )

	if not SERVER then return end

	self.real = Entity(0)
	self.owner = owner
	self.position = position
	self.is_prop = false
	self.is_world = true

	if map:IsLoading() then print("STILL LOADING") return end

	local hit_brush = nil

	for k,v in pairs( map:GetBrushes() ) do
		if bit.band(v.contents, CONTENTS_SOLID) != CONTENTS_SOLID then continue end
		if v:ContainsPoint( position ) and not removed_brushes[k] then
			hit_brush = k
			break
		end

	end

	if not hit_brush or removed_brushes[hit_brush] == true then return end
	removed_brushes[hit_brush] = true

	self.brush = hit_brush

	print("***SNATCH BRUSH: " .. hit_brush .. " ***")
	SV_SendPropSceneToClients( self )

end

local idx = 0
function meta:UpdateVoidMesh()
	map_mesh = ManagedMesh( "propsnatcher_voidmesh" .. CurTime() .. "_" .. idx, void_mat)
	idx = idx + 1
	mesh.Begin( map_mesh:Get(), MATERIAL_TRIANGLES, tricount )

	for _, brush in ipairs(removed_brushes) do
		local to_brush = brush.center

		for _, side in pairs( brush.sides ) do
			if not side.winding then continue end

			local texinfo = side.texinfo
			local texdata = texinfo.texdata
			side.winding:Move( to_brush )
			side.winding:EmitMesh(texinfo.st, texinfo.lst, texdata.width, texdata.height )
			side.winding:Move( -to_brush )
		end
	end

	mesh.End()
end

next_brush_mesh_id = next_brush_mesh_id or 0
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
		side.plane.dist = side.plane.dist + extrude
	end

	local convex = {}

	brush:CreateWindings()

	-- Keep track of the total number of triangles in the mesh
	for k, side in pairs( brush.sides ) do
		if not side.winding then continue end
		tricount = tricount + #side.winding.points - 1
	end

	brush.center = (brush.min + brush.max) / 2
	local to_center = -brush.center


	print("TRANSLATE: " .. tostring( to_center ) )

	for _, side in pairs( brush.sides ) do
		if not side.winding then continue end
		side.winding:Move( to_center )

		local texinfo = side.texinfo
		local texdata = texinfo.texdata
		local material = Material( texdata.material )

		print( texdata.material )

		next_brush_mesh_id = next_brush_mesh_id + 1
		side.winding:CreateMesh( "brushpoly_" .. next_brush_mesh_id, material, texinfo.st, texinfo.lst, texdata.width, texdata.height )

		for _, point in pairs( side.winding.points ) do

			table.insert( convex, point )

		end

	end

	table.insert( removed_brushes, brush )
	
	-- Update the mesh that encompasses all of the void geometry
	self:UpdateVoidMesh()

	print("WINDINGS READY, CREATE BRUSH PROXY")

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
	--actual:SetModelScale( 0 )
	--actual:GetPhysicsObject():Wake()
	--actual:GetPhysicsObject():AddVelocity( Vector(0,0,100) )
	actual.brush = brush
	actual.RenderOverride = function( self )

		if self.hide then return end

		actual:DrawModel()

		local mtx = Matrix()
		mtx:SetTranslation( actual:GetPos() )
		mtx:SetAngles( actual:GetAngles() )

		cam.PushModelMatrix( mtx )
		self.brush:Render()
		cam.PopModelMatrix()

	end

	self.handle = entity
	self.fake = actual
	self.real = actual

	print("PROXY READY, SNATCH IT")

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
		local phys = nil

		if not scene.is_world then
			phys = ent:GetPhysicsObject()
		end

		--Send prop info to client
		net.Start( "remove_prop_scene" )
		net.WriteUInt( scene.mode or 1, 8 )
		net.WriteBit( scene.is_world and 1 or 0 )
		net.WriteFloat( scene.time )

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
			} ):RunProp( ent )

		else

			local pos = net.ReadVector()
			local brush = net.ReadInt( 32 )

			New( {
				mode = mode,
				time = time,
				pos = pos,
			} ):RunWorld( brush )

		end

	end
		
	net.Receive("remove_prop_scene", CL_RecvPropSceneFromServer)

end

local mat2 = Material("editor/wireframe")
local mat3 = Material("brick/brick_model") //glass/reflectiveglass002

local offset = 0
local maxlinecount = 25
local nextgrouptime = 0
local groupFadeTime = 0.25
local function renderBrushLines()
	if #removed_brushes == 0 then return end

	if RealTime() > nextgrouptime then 
		nextgrouptime = RealTime() + groupFadeTime

		offset = (offset + maxlinecount) % #removed_brushes
	end

	local mtx = Matrix()
	local p = (nextgrouptime - RealTime()) / groupFadeTime

	for i=1, math.min(maxlinecount, #removed_brushes) do
		local curidx = ((offset + i - 1) % #removed_brushes) + 1
		local v = removed_brushes[curidx]

		mtx:SetTranslation( v.center )

		cam.PushModelMatrix( mtx )
		v:Render(HSVToColor((CurTime() * 50 + curidx * 1) % 360, 1, p), true, nil, true)
		cam.PopModelMatrix()
	end
end

hook.Add( "PostDrawOpaqueRenderables", "snatch_void", function(depth, sky) 
	if sky then return end
	if map_mesh then
		//render.UpdateScreenEffectTexture()
		render.SetMaterial(void_mat)
		render.SuppressEngineLighting(true)
		map_mesh:Get():Draw()
		render.SuppressEngineLighting(false)

		renderBrushLines()
	end
end )
hook.Add( "PostDrawTranslucentRenderables", "snatch_void_test", function() 
if map_mesh then
	render.SuppressEngineLighting(true)
	render.SetMaterial(mat3)
	//map_mesh:Get():Draw()
	render.SuppressEngineLighting(false)
end
end )

hook.Add( "PreDrawEffects", "snatch_void_lines", function()
	//It's faster to render the lines here, but the colors don't 'mix' into the feedback loop
	//we'll get there when we get there
	//renderBrushLines()
end)

hook.Add( "PostDrawTranslucentRenderables", "snatch_void", function() 
	if true then return end -- Disabled just for now, we'll experiment more later
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilEnable(true)
	render.ClearStencil()

	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.OverrideColorWriteEnable( true, true )

	local mtx = Matrix()
	
	if map_mesh then
		//map_mesh:Get():Draw()
	end

	render.OverrideColorWriteEnable( false, false )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

	render.SetColorMaterial()

	cam.Start2D()

	local b,e = pcall( function()
		surface.SetMaterial(void_mat)
		surface.SetDrawColor( Color(0,80,120,255) )
		surface.DrawRect(0,0,ScrW(),ScrH())
	end)

	if not b then print(e) end

	cam.End2D()

	render.SetStencilEnable(false) 

end )