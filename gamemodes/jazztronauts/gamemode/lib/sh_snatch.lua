if SERVER then

	AddCSLuaFile()
	util.AddNetworkString("remove_prop_scene")
	util.PrecacheModel( "models/hunter/blocks/cube025x025x025.mdl" )

end

module( "snatch", package.seeall )
void_mat = void_mat or nil
local convar_drawprops = nil
local convar_drawonce = nil
if CLIENT then
	local refractParams = {
		//["$basetexture"] = "_rt_FullFrameFB",
		["$basetexture"] = "concrete/concretefloor001a",
		["$normalmap"] = "sunabouzu/JazzShell_dudv",
		//["$normalmap"] = "sunabouzu/jazzSpecks_n", //concrete/concretefloor001a_normal, "effects/fisheyelense_normal", "glass/reflectiveglass002_normal"
		["$refracttint"] = "[1 1 1]",
		["$additive"] = 0,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 0,
		["$refractamount"] = 0.03,
		["$bluramount"] = 2,
		["$model"] = 1,
	}
	local refract = CreateMaterial("RefractBrushModel" .. FrameNumber(), "Refract", refractParams)
	void_mat = refract

	-- Performance convars
	convar_drawprops = CreateClientConVar("jazz_void_drawprops", "1", true, false, "Render additional props/effects in the jazz void.")
	convar_drawonce = CreateClientConVar("jazz_void_drawonce", "0", true, false, "Don't render the void for water reflections, mirrors, or additional scenes. Will introduce rendering artifacts in water/mirrors, but is much faster.")
end

removed_brushes = removed_brushes or {}

-- Voidmesh stuff
max_map_verts = 2048
map_meshes = map_meshes or {}
current_mesh = current_mesh or { num = 1, mesh = nil, vertices = {} }

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
	self:SetMode(2)

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
	actual:SetModelScale( 0 )
	--actual:GetPhysicsObject():Wake()
	--actual:GetPhysicsObject():AddVelocity( Vector(0,0,100) )
	actual.brush = brush
	actual.RenderOverride = function( self )

		if self.hide then return end

		//actual:DrawModel()

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
	self:SetMode(1)

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

if SERVER then return end -- cool guy zone, kep out

local surfaceMaterial = Material("sunabouzu/JazzShell") //glass/reflectiveglass002 brick/brick_model
local sizeX = ScrW() -- Size of the void rendertarget. Expose scale?
local sizeY = ScrH()
local rt = irt.New("jazz_snatch_voidbg", sizeX, sizeY)

//rt:SetAlphaBits( 8 )
rt:EnableDepth( true, true )
local rtTex = rt:GetTarget()

function GetVoidTexture()
	return rt:GetTarget()
end

function GetVoidOverlay()
	return void_mat, surfaceMaterial
end

local function SharedRandomVec(seed)
	return Vector(
		util.SharedRandom("x", 0, 1, seed),
		util.SharedRandom("y", 0, 1, seed),
		util.SharedRandom("z", 0, 1, seed))
end

local function ModVec(vec, mod)
	vec.x = vec.x % mod
	vec.y = vec.y % mod
	vec.z = vec.z % mod
	return vec
end

local function MapVec(vec, func)
	vec.x = func(vec.x)
	vec.y = func(vec.y)
	vec.z = func(vec.z)
	return vec
end

-- Render the entire void scene
local propProximityFade = 200
local range = 4000.0
local hRangeVec = Vector(range/2, range/2, range/2)
local function renderVoid(eyePos, eyeAng, fov)

	local oldW, oldH = ScrW(), ScrH()
	render.Clear( 0, 0, 0, 0, true, true )
	render.SetViewPort( 0, 0, sizeX, sizeY )

	render.SuppressEngineLighting(true)

	-- Skybox pass
	cam.Start3D(Vector(), eyeAng, fov, 0, 0, sizeX, sizeY)
		-- Render the sky first, don't write to depth so everything draws over it
		render.OverrideDepthEnable(true, false)
			local tunnel = ManagedCSEnt("jazz_snatchvoid_tunnel", "models/props/jazz_dome.mdl")
			tunnel:SetNoDraw(true)
			tunnel:SetPos(Vector())
			tunnel:SetupBones()

			-- Draw the background with like a million different materials because
			-- fuck it they're all additive and look pretty
			tunnel:SetMaterial("sunabouzu/JazzLake01")
			tunnel:DrawModel()

			tunnel:SetMaterial("sunabouzu/JazzSwirl01")
			tunnel:DrawModel()

			tunnel:SetMaterial("sunabouzu/JazzSwirl02")
			tunnel:DrawModel()

			tunnel:SetMaterial("sunabouzu/JazzSwirl03")
			tunnel:DrawModel()

		render.OverrideDepthEnable(true, true)
	cam.End3D()

	-- Random props pass
	if convar_drawprops:GetBool() then
	cam.Start3D(eyePos, eyeAng, fov, 0, 0, sizeX, sizeY)
		local skull = ManagedCSEnt("jazz_snatchvoid_skull", "models/krio/jazzcat1.mdl")
		skull:SetNoDraw(true)
		skull:SetModelScale(4)

		for i=1, 10 do
			local plyPos = LocalPlayer():EyePos()

			-- Create a "treadmill" so they don't move until they get far away, then wrap around
			local modvec = ModVec(plyPos + SharedRandomVec(i) * range, range)
			local p = plyPos - modvec + hRangeVec

			skull:SetPos(p)

			-- Face the player
			local ang = (skull:GetPos() - plyPos):Angle()
			skull:SetAngles(ang)
			skull:SetupBones()

			-- Calculate the 'distance' from the center by where they are in the offset
			local d = MapVec(math.pi * modvec / range, math.sin)

			-- Fade out if it's super close
			local dfade = MapVec( modvec - hRangeVec, math.abs) / propProximityFade

			-- Apply blending and draw
			local distFade = math.max(0, 2.0 - dfade:Length())
			local alpha = math.min(d.x, d.y, d.z) - distFade
			if alpha >= 0 then
				render.SetBlend(alpha)
				skull:DrawModel()
			end
	
		end
		render.SetBlend(1) -- Finished, reset blend
		render.ClearDepth()

	
		render.OverrideDepthEnable(false)
		hook.Call("JazzDrawVoid", GAMEMODE)

	cam.End3D()	
	end
	render.OverrideDepthEnable(false)
	render.SuppressEngineLighting(false)

	render.SetViewPort( 0, 0, oldW, oldH )
end

-- Render the brush lines, keeping performant by only rendering a few at a time over the span of many frames
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

function UpdateVoidTexture(origin, angles, fov)
	rt:Render(renderVoid, origin, angles, fov)
end

-- Draw the spooky jazz world to its own texture
hook.Add("RenderScene", "snatch_void_inside", function(origin, angles, fov)
	-- If draw once is enabled, draw it once here when the scene begins
	if convar_drawonce:GetBool() then
		UpdateVoidTexture(origin, angles, fov)
	end

	-- Also make sure this is always set
	if void_mat:GetTexture("$basetexture"):GetName() != rtTex:GetName() then
		print("Setting void basetexture")
		void_mat:SetTexture("$basetexture", rtTex)
	end
end )

-- Keep track of if we're currently rendering 3D sky so we don't draw extra
-- The 'sky' arg in PostDrawOpaqueRenderables returns true on maps without a skybox, 
-- so we keep track of it ourselves
local isInSky = false
hook.Add("PreDrawSkyBox", "JazzDisableSkyDraw", function()
	isInSky = true
end )
hook.Add("PostDrawSkyBox", "JazzDisableSkyDraw", function()
	isInSky = false
end)

-- Render the inside of the jazz void with the default void material
-- This void material has a rendertarget basetexture we update each frame
hook.Add( "PostDrawOpaqueRenderables", "snatch_void", function(depth, sky) 
	if isInSky then return end
	
	-- Re-render this for every new scene if not drawing once
	if not convar_drawonce:GetBool() then
		UpdateVoidTexture(EyePos(), EyeAngles(), nil)
	end

	//render.UpdateScreenEffectTexture()
	render.SetMaterial(void_mat)
	render.SuppressEngineLighting(true)

	-- Draw all map meshes
	for _, v in pairs(map_meshes) do
		v:Get():Draw()
	end

	-- Draw again with overlay
	render.SetMaterial(surfaceMaterial)

	for _, v in pairs(map_meshes) do
		v:Get():Draw()
	end

	render.SuppressEngineLighting(false)

	//renderBrushLines()

end )

hook.Add( "PreDrawEffects", "snatch_void_lines", function()
	//renderBrushLines()
end)
