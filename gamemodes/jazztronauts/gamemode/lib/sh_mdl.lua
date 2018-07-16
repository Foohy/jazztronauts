AddCSLuaFile()


if SERVER then 
	util.PrecacheModel( "models/hunter/blocks/cube025x025x025.mdl" )
	return
end


local colors = {
	Color(255,0,0),
	Color(255,128,0),
	Color(255,255,0),
	Color(128,255,0),
	Color(0,255,0),
	Color(0,255,128),
	Color(0,255,255),
	Color(0,128,255),
	Color(0,0,255),
	Color(128,0,255),
	Color(255,0,255),
	Color(255,0,128),
}

local MAX_NUM_LODS = 8
local MAX_NUM_BONES_PER_VERT = 3

local STRIP_IS_TRILIST = 1
local STRIP_IS_TRISTRIP = 2

local array = Struct({
	INT32.num,
	INT32.index,
})

--VVD
local vvd_boneweight = Struct({
	FLOAT.weight[ MAX_NUM_BONES_PER_VERT ],
	UINT8.bone[ MAX_NUM_BONES_PER_VERT ],
	UINT8.numBones
})

local vvd_vertex = Struct({
	vvd_boneweight.weights,
	VECTOR.position,
	VECTOR.normal,
	VECTOR2D.texcoord,
})

local vvd_header = Struct({
	INT32.id,
	INT32.version,
	INT32.checksum,
	INT32.numLODs,
	INT32.numLODVertices[ MAX_NUM_LODS ],
	INT32.numFixups,
	INT32.fixupTableStart,
	INT32.vertexDataStart,
	INT32.tangentDataStart,
})

local vvd_fixup = Struct({
	INT32.lod,
	INT32.sourceID,
	INT32.numVertices
})

--VTX
local vtx_header = Struct({
	INT32.version,

	INT32.vertCacheSize,
	UINT16.maxBonesPerStrip,
	UINT16.maxBonesPerTri,
	INT32.maxBonesPerVert,

	INT32.checksum,

	INT32.numLODs,
	INT32.materialReplacementListOffset,

	INT32.numBodyParts,
	INT32.bodyPartOffset,
})

local vtx_bodypartheader = Struct({
	INT32.numModels,
	INT32.modelOffset,
})

local vtx_modelheader = Struct({
	INT32.numLODs,
	INT32.lodOffset,
})

local vtx_modelLODheader = Struct({
	INT32.numMeshes,
	INT32.meshOffset,
	FLOAT.switchPoint,
})

local vtx_meshheader = Struct({
	INT32.numStripGroups,
	INT32.stripGroupHeaderOffset,
	UINT8.flags,
})

local vtx_stripgroupheader = Struct({
	INT32.numVerts,
	INT32.vertOffset,

	INT32.numIndices,
	INT32.indexOffset,

	INT32.numStrips,
	INT32.stripOffset,

	UINT8.flags,
})

local vtx_stripheader = Struct({
	INT32.numIndices,
	INT32.indexOffset,

	INT32.numVerts,
	INT32.vertOffset,

	INT16.numBones,

	UINT8.flags,

	INT32.numBoneStateChanges,
	INT32.boneStateChangeOffset,
})

local vtx_vertex = Struct({
	UINT8.boneWeightIndex[3],
	UINT8.numBones,

	UINT16.origMeshVertID,

	INT8.boneID[3]
})

--MDL
local mdl_header = Struct({
	INT32.id,
	INT32.version,
	
	INT32.checksum,

	CHAR.name[64],
	INT32.length,

	VECTOR.eyeposition,

	VECTOR.illumposition,

	VECTOR.hull_min,
	VECTOR.hull_max,

	VECTOR.view_bbmin,
	VECTOR.view_bbmax,

	INT32.flags,

	array.bones,
	array.bone_controllers,
	array.hitbox_sets,
	array.local_anims,
	array.local_sequences,

	INT32.activitylistversion,
	INT32.eventsindexed,

	array.textures,
	array.cd_textures,

	INT32.numskinref,
	INT32.numskinfamilies,
	INT32.skinindex,

	array.body_parts,
	array.local_attachments,

	INT32.numlocalnodes,
	INT32.localnodeindex,
	INT32.localnodenameindex,

	array.flexes,
	array.flex_controllers,
	array.flex_rules,
	array.ik_chains,
	array.mouths,
	array.local_pose_parameters,

	INT32.surfacepropindex,
	INT32.keyvalueindex,
	INT32.keyvaluesize,

	array.local_ik_autoplay_locks,

	INT32.mass,
	INT32.contents,

	array.include_models,

	INT32.szanimblockindex,

	array.anim_blocks,

	INT32.bonetablebynameindex,

	INT8.constdirectionallightdot,
	INT8.rootLOD,
	INT8.numAllowedRootLODs,
	INT8.unused,
	INT32.unused4,

	array.flex_controller_ui,

	FLOAT.flVertAnimFixedPointScale,

	INT32.unused3,
	INT32.studiohdr2index,
	INT32.unused2,
})

local mdl_bodypart = Struct({
	INT32.nameindex,
	INT32.nummodels,
	INT32.base,
	INT32.modelindex,
})

local mdl_model = Struct({
	CHAR.name[64],

	INT32.type,
	FLOAT.boundingradius,

	array.meshes,

	INT32.numvertices,
	INT32.vertexindex,
	INT32.tangentindex,

	array.attachments,
	array.eyeballs,

	INT32.pVertexData,
	INT32.pTangentData,

	INT32.unused[8],
})

local mdl_vertex_data = Struct({
	INT32.ptr,
	INT32.numLODVertices[ MAX_NUM_LODS ],
})

local mdl_mesh = Struct({
	INT32.material,

	INT32.modelindex,

	INT32.numvertices,
	INT32.vertexoffset,

	array.flexes,

	INT32.materialtype,
	INT32.materialparam,

	INT32.meshid,

	VECTOR.center,

	mdl_vertex_data.vertexdata,

	INT32.unused[8],
})

function PrintTable2( t, indent, done )

	done = done or {}
	indent = indent or 0
	local keys = table.GetKeys( t )

	table.sort( keys, function( a, b )
		if ( isnumber( a ) && isnumber( b ) ) then return a < b end
		return tostring( a ) < tostring( b )
	end )

	for i = 1, #keys do
		local key = keys[ i ]
		local value = t[ key ]
		Msg( string.rep( " ", indent ) )

		if  ( istable( value ) && !done[ value ] ) then

			done[ value ] = true
			Msg( tostring( key ) .. ":" .. "\n" )
			PrintTable2 ( value, indent + 2, done )
			done[ value ] = nil

		else

			Msg( tostring( key ) .. "\t=\t" )
			Msg( tostring( value ) .. "\n" )

		end

	end

end

local function OffsetArray( ar, to )

	ar.index = ar.index + to

end

local function LoadStructArray( f, num, index, struct, cb )

	local d = {}
	if num == 0 then return d end
	f:Seek( index )
	for i=1, num do
		local at = f:Tell()
		local data = struct.read( f )
		table.insert( d, data )
		if cb then cb( data, at ) end
	end
	return d

end

local function LoadStructArray2( f, ar, struct, cb )

	return LoadStructArray( f, ar.num, ar.index, struct, cb )

end

local function LoadMDL( mdl_path, fast )

	local base = mdl_path:sub(1, -4)
	local yield_rate = fast and 1000 or 200

	local f_mdl = file.Open( base .. "mdl", "rb", "GAME" )
	if not f_mdl then return nil end

	local header = mdl_header.read( f_mdl )
	local bodyparts = LoadStructArray2( f_mdl, header.body_parts, mdl_bodypart, function( l, at )
		l.nameindex = l.nameindex + at
		l.modelindex = l.modelindex + at
	end )

	for _, part in pairs( bodyparts ) do
		part.models = LoadStructArray( f_mdl, part.nummodels, part.modelindex, mdl_model, function( l, at )
			OffsetArray( l.meshes, at )
			OffsetArray( l.attachments, at )
			OffsetArray( l.eyeballs, at )
			l.vertexindex = l.vertexindex / vvd_vertex.sizeof
		end )

		for _, model in pairs( part.models ) do
			model.meshes = LoadStructArray2( f_mdl, model.meshes, mdl_mesh, function( l, at )
				OffsetArray( l.flexes, at )
			end )

			task.YieldPer(yield_rate, "progress")
		end
	end

	--PrintTable2( header )

	f_mdl:Close()

	return {
		header = header,
		bodyparts = bodyparts,
	}

end

local function LoadVTX( mdl_path, fast )

	local yield_rate = fast and 500 or 100
	local base = mdl_path:sub(1, -4)

	local f_vtx = file.Open( base .. "dx90.vtx", "rb", "GAME" )
	if not f_vtx then return nil end

	local header = vtx_header.read( f_vtx )
	local bodyparts = {}

	f_vtx:Seek( header.bodyPartOffset )

	for i=1, header.numBodyParts do

		table.insert( bodyparts, vtx_bodypartheader.read( f_vtx ) )

	end

	for i, bodypart in pairs( bodyparts ) do

		local model_base = bodypart.modelOffset + header.bodyPartOffset + vtx_bodypartheader.sizeof * (i-1)

		bodypart.models = {}
		f_vtx:Seek( model_base )

		for x=1, bodypart.numModels do

			table.insert( bodypart.models, vtx_modelheader.read( f_vtx ) )

		end

		for j, model in pairs( bodypart.models ) do

			local lod_base = model_base + model.lodOffset + vtx_modelheader.sizeof * (j-1)

			model.lods = {}
			f_vtx:Seek( lod_base )

			for x=1, model.numLODs do

				table.insert( model.lods, vtx_modelLODheader.read( f_vtx ) )

			end

			for k, lod in pairs( model.lods ) do

				local mesh_base = lod_base + lod.meshOffset + vtx_modelLODheader.sizeof * (k-1)

				lod.meshes = {}
				f_vtx:Seek( mesh_base )

				for x=1, lod.numMeshes do

					table.insert( lod.meshes, vtx_meshheader.read( f_vtx ) )

				end

				for l, msh in pairs( lod.meshes ) do

					local group_base = mesh_base + msh.stripGroupHeaderOffset + vtx_meshheader.sizeof * (l-1)

					msh.groups = {}
					f_vtx:Seek( group_base )

					for x=1, msh.numStripGroups do

						table.insert( msh.groups, vtx_stripgroupheader.read( f_vtx ) )

					end

					for m, group in pairs( msh.groups ) do

						local head_base = group_base + vtx_stripgroupheader.sizeof * (m-1)
						local strip_base = head_base + group.stripOffset
						local index_base = head_base + group.indexOffset
						local vertex_base = head_base + group.vertOffset

						--print("LOAD GROUP: ", i, j, k, l, m, group.stripOffset, group.indexOffset, group.vertOffset, group.numStrips )

						group.strips = {}
						group.indices = {}
						group.vertices = {}

						f_vtx:Seek( strip_base )
						for x=1, group.numStrips do task.YieldPer(yield_rate, "progress") group.strips[#group.strips+1] = vtx_stripheader.read( f_vtx ) end

						f_vtx:Seek( index_base )
						for x=1, group.numIndices do task.YieldPer(yield_rate, "progress") group.indices[#group.indices+1] = UINT16.read( f_vtx ) end

						f_vtx:Seek( vertex_base )
						for x=1, group.numVerts do task.YieldPer(yield_rate, "progress") group.vertices[#group.vertices+1] = vtx_vertex.read( f_vtx ) end

					end

				end

			end

		end

	end

	--PrintTable2( bodyparts, 1 )

	f_vtx:Close()

	return {
		header = header,
		bodyparts = bodyparts,
	}

end

local function LoadVVD( mdl_path, fast )

	local base = mdl_path:sub(1, -4)
	local yield_rate_v = fast and 200 or 100
	local yield_rate_f = fast and 1000 or 400

	local f_vvd = file.Open( base .. "vvd", "rb", "GAME" )
	if not f_vvd then return nil end

	local header = vvd_header.read( f_vvd )
	local fixups = {}
	local vertices = {}
	local tangents = {}

	PrintTable( header )

	if header.numFixups > 0 then

		f_vvd:Seek( header.fixupTableStart )

		for i=1, header.numFixups do

			table.insert( fixups, vvd_fixup.read( f_vvd ) )
			task.YieldPer(yield_rate_f, "progress")

		end

		PrintTable( fixups )

	end

	f_vvd:Seek( header.vertexDataStart )

	for i=1, header.numLODVertices[1] do

		table.insert( vertices, vvd_vertex.read( f_vvd ) )
		task.YieldPer(yield_rate_v, "progress")

	end

	f_vvd:Seek( header.tangentDataStart )

	for i=1, header.numLODVertices[1] do

		table.insert( tangents, VECTOR4.read( f_vvd ) )
		task.YieldPer(yield_rate_v, "progress")

	end

	f_vvd:Close()


	if #fixups > 0 then

		local corrected = table.Copy( vertices )
		local target = 0
		for _, fixup in pairs( fixups ) do

			if fixup.lod < 0 then continue end

			for i=1, fixup.numVertices do
				task.YieldPer(yield_rate_f, "progress")
				corrected[ i + target ] = vertices[ i + fixup.sourceID ]
			end

			target = target + fixup.numVertices

		end

		vertices = corrected

	end

	return {
		header = header,
		vertices = vertices,
		tangents = tangents,
		fixups = fixups,
	}

end

local white_color = Color(255,255,255,255)

--PrintTable2(mdl.bodyparts)

local wire_boxes = {}
local debug_gridding = false
local debug_grid_time = 0

hook.Add( "PostDrawOpaqueRenderables", "dbgbox", function() 

	if not debug_gridding then return end
	local dt = (CurTime() - debug_grid_time) / 2
	local dtx = dt*dt

	if dt > 1 then return end

	for k,v in pairs( wire_boxes ) do
		render.DrawWireframeBox( v.pos, Angle(0,0,0), v.mins * (1-dtx), v.maxs * (1-dtx), Color(255,255,255,80), true )
	end

end )

local function UnifyNormals( vvd, mdl )

	local start = SysTime()

	local min = Vector( mdl.header.hull_min )
	local max = Vector( mdl.header.hull_max )
	local grid_res = 10

	min.x = math.floor( min.x / grid_res ) * grid_res
	min.y = math.floor( min.y / grid_res ) * grid_res
	min.z = math.floor( min.z / grid_res ) * grid_res

	max.x = math.ceil( max.x / grid_res ) * grid_res
	max.y = math.ceil( max.y / grid_res ) * grid_res
	max.z = math.ceil( max.z / grid_res ) * grid_res

	print( tostring( min ) )
	print( tostring( max ) )

	local grid_lookup = {}

	wire_boxes = {}
	debug_grid_time = CurTime()

	local function grid( pos )

		local x = math.Round( pos.x / grid_res ) * grid_res
		local y = math.Round( pos.y / grid_res ) * grid_res
		local z = math.Round( pos.z / grid_res ) * grid_res

		if debug_gridding and (not grid_lookup[x] or not grid_lookup[x][y] or not grid_lookup[x][y][z]) then
			table.insert( wire_boxes, { pos = Vector(x,y,z), mins = Vector(-5,-5,-5), maxs = Vector(5,5,5) })
		end

		local gx = grid_lookup[x] or {} grid_lookup[x] = gx
		local gy = gx[y] or {} gx[y] = gy
		local gz = gy[z] or {} gy[z] = gz

		return gz

	end

	local epsilon = .001
	local bins = {}
	local function insert( v )

		local binset = grid( v.position )

		for _, bin in pairs( binset ) do
			if v.position:DistToSqr( bin.pos ) < epsilon then
				table.insert( bin.verts, v )
				return bin
			end
		end
		local newbin = {
			pos = v.position,
			verts = { v },
		}
		table.insert( binset, newbin )
		table.insert( bins, newbin )
		return newbin

	end

	for _, vert in pairs( vvd.vertices ) do

		local bin = insert( vert )
		task.YieldPer(500, "progress")

	end

	print( #vvd.vertices .. " in " .. #bins .. " bins")

	for _, bin in pairs( bins ) do

		if #bin.verts < 2 then
			bin.verts[1].unified = bin.verts[1].normal
			continue 
		end

		local common = Vector()
		for i=1, #bin.verts do

			common:Add( bin.verts[i].normal )
			bin.verts[i].unified = common

			task.YieldPer(500, "progress")

		end

		common:Normalize()

	end

	print("TOOK: " .. ( SysTime() - start ) )

end


--if true then return end

local function CreateMesh( vvd, vtx, mdl )

	local tris = {}
	local LOD = 1

	for i, body in pairs( vtx.bodyparts ) do local m_bodypart = mdl.bodyparts[i]
	for j, model in pairs( body.models ) do local m_model = m_bodypart.models[j]
	for k, msh in pairs( model.lods[ LOD ].meshes ) do local m_mesh = m_model.meshes[k]
	for l, group in pairs( msh.groups ) do
	for m, strip in pairs( group.strips ) do

	for x=0, strip.numIndices-3, 3 do

		local idx = x + strip.indexOffset

		local i0 = group.vertices[ group.indices[idx+1] + 1 ].origMeshVertID + 1
		local i1 = group.vertices[ group.indices[idx+2] + 1 ].origMeshVertID + 1
		local i2 = group.vertices[ group.indices[idx+3] + 1 ].origMeshVertID + 1

		local v0 = vvd.vertices[ i0 + m_mesh.vertexoffset + m_model.vertexindex ]
		local v1 = vvd.vertices[ i1 + m_mesh.vertexoffset + m_model.vertexindex ]
		local v2 = vvd.vertices[ i2 + m_mesh.vertexoffset + m_model.vertexindex ]

		local index = v0.weights.bone[1] --math.floor( v0.texcoord.x * 10 + v0.texcoord.y * 10 ) --math.floor(x/24)
		local col = colors[ index % #colors + 1 ]

		local test = 14
			task.YieldPer(1000, "progress")

		--if v0.weights.bone[1] == test and v1.weights.bone[1] == test and v2.weights.bone[1] == test then

			--debugoverlay.Line( v0.position, v1.position, 5, col, false )
			--debugoverlay.Line( v1.position, v2.position, 5, col, false )
			--debugoverlay.Line( v2.position, v0.position, 5, col, false )

			table.insert( tris, {
				color = white_color,
				pos = Vector(v0.position + v0.unified),
				normal = v0.unified,
				u = v0.texcoord.x,
				v = v0.texcoord.y,
				tangent = Vector(1,0,0),
				binormal = Vector(0,1,0),
				userdata = {0,0,1,1},
			})

			table.insert( tris, {
				color = white_color,
				pos = Vector(v1.position + v1.unified),
				normal = v1.unified,
				u = v1.texcoord.x,
				v = v1.texcoord.y,
				tangent = Vector(1,0,0),
				binormal = Vector(0,1,0),
				userdata = {0,0,1,1},
			})

			table.insert( tris, {
				color = white_color,
				pos = Vector(v2.position + v2.unified),
				normal = v2.unified,
				u = v2.texcoord.x,
				v = v2.texcoord.y,
				tangent = Vector(1,0,0),
				binormal = Vector(0,1,0),
				userdata = {0,0,1,1},
			})

		--end

	end

	end
	end
	end
	end
	end

	return tris

end

local size_cache = {}
function GetModelFootprint( model )

	if model == nil then return 0 end

	model = model:sub(1, -4)

	if size_cache[model] then return size_cache[model] end

	local vtx = file.Open( model .. "vtx", "rb", "GAME" )
	local vvd = file.Open( model .. "vvd", "rb", "GAME" )

	local size = (vvd and vvd:Size() or 0) * 2 + (vtx and vtx:Size() or 0)

	if vtx then vtx:Close() end
	if vvd then vvd:Close() end

	size_cache[model] = size
	return size

end

local function LoadModel( model, fast )

	task.Yield("section", "VTX")
	local vtx = LoadVTX( model, fast )

	task.Yield("section", "VVD")
	local vvd = LoadVVD( model, fast )

	task.Yield("section", "MDL")
	local mdl = LoadMDL( model, fast )

	if not vtx then print("Failed to load .dx90.vtx for model: " .. tostring( model )) return end
	if not vvd then print("Failed to load .vvd for model: " .. tostring( model )) return end
	if not mdl then print("Failed to load .mdl for model: " .. tostring( model )) return end

	for _, vert in pairs( vvd.vertices ) do
		vert.unified = vert.normal
	end

	return vvd, vtx, mdl

end

function MakeExpandedModel( model, material, fast )

	local vvd, vtx, mdl = LoadModel( model, fast )
	if not vvd then return nil end

	task.Yield("section", "UNIFY")
	UnifyNormals( vvd, mdl )
	local mesh_tris = CreateMesh( vvd, vtx, mdl, fast )
	local mesh_material = CreateMaterial( "meshmaterial", "VertexLitGeneric", {
		["$basetexture"] = "color/white",
		["$model"] = 1,
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1
	} )

	task.Yield("section", "MESH")
	local test_mesh = nil
	if not test_mesh then
		test_mesh = ManagedMesh(mesh_material )
		test_mesh:BuildFromTriangles( mesh_tris )
	end

	return test_mesh

end

--[[local ent = MakeExpandedModel( "models/props_vehicles/truck001a.mdl"  )

--"models/props_vehicles/truck001a.mdl" 

hook.Add( "Think", "testexp", function()

	if LocalPlayer():KeyPressed( IN_ATTACK2 ) then

		local tr = util.TraceLine( {
			start = LocalPlayer():EyePos(),
			endpos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward()*1000,
			filter = LocalPlayer(),
			mask = MASK_ALL,
			collisiongroup = COLLISION_GROUP_INTERACTIVE,
		} )

		if IsValid( tr.Entity ) and tr.Entity:GetModel() then
			print( tr.Entity:GetModel() )

			if not tr.Entity.expanded then

				tr.Entity.expanded = MakeExpandedModel( tr.Entity:GetModel() )
				if not tr.Entity.expanded then return end

				local mtx = Matrix()
				mtx:SetTranslation( tr.Entity:GetPos() )
				mtx:SetAngles( tr.Entity:GetAngles() )

				for _, b in pairs( wire_boxes ) do
					b.pos = mtx * b.pos
				end

			end

			tr.Entity.expanded:SetPos( tr.Entity:GetPos() )
			tr.Entity.expanded:SetAngles( tr.Entity:GetAngles() )

		end

	end

end )]]