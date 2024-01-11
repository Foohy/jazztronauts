AddCSLuaFile()


if SERVER then
	util.PrecacheModel( "models/hunter/blocks/cube025x025x025.mdl" )
	return
end

-- FAST READER
local str_byte, ldexp = string.byte, math.ldexp
local lshift, rshift, band, bor, bnot = bit.lshift, bit.rshift, bit.band, bit.bor, bit.bnot
local m_ptr, m_size, m_data, m_stack

local function init_fast_read(file_handle)
	m_ptr, m_stack = 1, {}
	m_size = file_handle:Size()
	m_data = file_handle:Read( m_size )
end

local function finish_fast_read(file_handle)
	file_handle:Close()
end

local function skip_data( n ) m_ptr = m_ptr + n end
local function seek_data( pos ) m_ptr = pos + 1 end
local function tell_data() return m_ptr - 1 end
local function array_of( f, count )
	local t = {} for i=1, count do t[#t+1] = f() end 
	return t
end

local function float32()
	local a,b,c,d = str_byte(m_data, m_ptr, m_ptr + 4) m_ptr = m_ptr + 4
	local fr = bor( lshift( band(c, 0x7F), 16), lshift(b, 8), a )
	local exp = bor( band( d, 0x7F ) * 2, rshift( c, 7 ) )
	if exp == 0 then return 0 end
	return ldexp( ( ldexp(fr, -23) + 1 ) * (d > 127 and -1 or 1), exp - 127 )
end

local function uint32()
    local a,b,c,d = str_byte(m_data, m_ptr, m_ptr + 4) m_ptr = m_ptr + 4
    local n = bor( lshift(d,24), lshift(c,16), lshift(b, 8), a )
    if n < 0 then n = (0x1p32) - 1 - bnot(n) end
    return n
end

local function uint16()
    local a,b = str_byte(m_data, m_ptr, m_ptr + 2) m_ptr = m_ptr + 2
    return bor( lshift(b, 8), a )
end

local function uint8()
    local a = str_byte(m_data, m_ptr, m_ptr) m_ptr = m_ptr + 1
    return a
end

local function int32()
    local a,b,c,d = str_byte(m_data, m_ptr, m_ptr + 4) m_ptr = m_ptr + 4
    local n = bor( lshift(d,24), lshift(c,16), lshift(b, 8), a )
    return n
end

local function int16()
    local a,b = str_byte(m_data, m_ptr, m_ptr + 2) m_ptr = m_ptr + 2
    local n = bor( lshift(b, 8), a )
    if band( b, 0x80 ) ~= 0 then n = -(0x1p16) + n end
    return n
end

local function int8()
    local a = str_byte(m_data, m_ptr, m_ptr) m_ptr = m_ptr + 1
    if band( a, 0x80 ) ~= 0 then a = -(0x100) + a end
    return a
end

local function push_data(addr) m_stack[#m_stack+1] = tell_data() seek_data(addr) end
local function pop_data() seek_data(m_stack[#m_stack]) m_stack[#m_stack] = nil end
local function indirect_array( dtype )
    return { num = int32(), offset = int32(), dtype = dtype, }
end

local function load_indirect_array( tbl, base, field, aux, ... )
    local arr = aux or tbl[field]
    local num, offset, dtype = arr.num, arr.offset, arr.dtype
	if not offset then return end
    arr.num, arr.offset, arr.dtype = nil, nil, nil

    if offset == 0 and num ~= 0 then return end
    if num == 0 then return end

    push_data(base + offset)
    for i=1, num do arr[#arr+1] = dtype(...) end
    pop_data()
end
-- END FAST READER

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

local __mdl_version = nil -- currently loading version
local MAX_NUM_LODS = 8
local MAX_NUM_BONES_PER_VERT = 3

local STRIP_IS_TRILIST = 1
local STRIP_IS_TRISTRIP = 2
local VTX_VERSION = 7

local array = Struct({
	INT32.num,
	INT32.index,
})

--VVD
local function vvd_vertex() --48 bytes

	skip_data(16) -- skip weights, we don't use them
	return {
		--[[weights = {
			weight = array_of( float32, MAX_NUM_BONES_PER_VERT ),
			bone = array_of( uint8, MAX_NUM_BONES_PER_VERT ),
			numBones = uint8(),
		},]]
		position = Vector(float32(), float32(), float32()),
		normal = Vector(float32(), float32(), float32()),
		texcoord = {x = float32(), y = float32()},
	}
end

--VTX
local function vtx_bonestatechange()

    return {
        hardwareID = int32(),
        newBoneID = int32(),
    }

end

local function vtx_vertex()

    return {
        boneWeightIndex = array_of(uint8, 3),
        numBones = uint8(),
        origMeshVertID = uint16(),
        boneID = array_of(int8, 3),
    }

end

local function vtx_strip()

    local base = tell_data()
    local strip = {
        numIndices = int32(),
        indexOffset = int32(),
        numVerts = int32(),
        vertOffset = int32(),
        numBones = int16(),
        flags = uint8(),
        boneStateChanges = indirect_array(vtx_bonestatechange),
    }

    assert(strip.flags <= 3, "Invalid flags on strip")
    load_indirect_array(strip, base, "boneStateChanges")

    if band(strip.flags, STRIP_IS_TRILIST) ~= 0 then
        strip.isTriList = true
    elseif band(strip.flags, STRIP_IS_TRISTRIP) ~= 0 then
        strip.isTriStrip = true
        error("Tri Strip not supported!")
    end
    strip.flags = nil

    return strip

end

local function vtx_stripgroup()

    local base = tell_data()
    local group = {
        vertices = indirect_array(vtx_vertex),
        indices = indirect_array(uint16),
        strips = indirect_array(vtx_strip),
        flags = uint8(),
    }

    group.flags = nil

    load_indirect_array(group, base, "vertices")
    load_indirect_array(group, base, "indices")
    load_indirect_array(group, base, "strips")

    local vertices = group.vertices
    local indices = group.indices
    if __mdl_version >= 49 then uint32() uint32() end

    return group

end

local function vtx_mesh()

    local base = tell_data()
    local mesh = {
        stripgroups = indirect_array(vtx_stripgroup),
        flags = uint8(),
    }
    load_indirect_array(mesh, base, "stripgroups")
    return mesh

end

local function vtx_modellod()

    local base = tell_data()
    local lod = {
        meshes = indirect_array(vtx_mesh),
        switchPoint = float32(),
    }
    load_indirect_array(lod, base, "meshes")
    return lod

end

local function vtx_model()

    local base = tell_data()
    local model = {
        lods = indirect_array(vtx_modellod),
    }
    load_indirect_array(model, base, "lods")
    return model

end

local function vtx_bodypart()

    local base = tell_data()
    local part = {
        models = indirect_array(vtx_model),
    }
    load_indirect_array(part, base, "models")
    return part

end

local function vtx_header()

    local base = tell_data()
    local header = {
        version = int32(),
        vertCacheSize = int32(),
        maxBonesPerStrip = uint16(),
        maxBonesPerTri = uint16(),
        maxBonesPerVert = int32(),
        checksum = int32(),
        numLODs = int32(),
        materialReplacementListOffset = int32(),
        bodyParts = indirect_array( vtx_bodypart ),
    }

    assert(header.version == VTX_VERSION, "Version mismatch: " .. (header.version) .. " != " .. VTX_VERSION)
    load_indirect_array(header, 0, "bodyParts")
    return header

end

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

	print("LOADING MDL: " .. tostring(mdl_path))
	
	local t0 = SysTime()

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
			l.vertexindex = l.vertexindex / 48 -- vvd_vertex
		end )

		for _, model in pairs( part.models ) do
			model.meshes = LoadStructArray2( f_mdl, model.meshes, mdl_mesh, function( l, at )
				OffsetArray( l.flexes, at )
			end )

			task.YieldPer(yield_rate, "progress")
		end
	end

	__mdl_version = header.version

	f_mdl:Close()

	print("FINISHED LOADING MDL: " .. tostring(mdl_path) .. " (" .. (SysTime() - t0) * 1000 .. " ms)")

	return {
		header = header,
		bodyparts = bodyparts,
	}

end

local function LoadVTX( mdl_path, fast )

	print("LOADING VTX: " .. tostring(mdl_path))

	local t0 = SysTime()

	local yield_rate = fast and 500 or 100
	local base = mdl_path:sub(1, -4)

	local f_vtx = file.Open( base .. "dx90.vtx", "rb", "GAME" )
	if not f_vtx then return nil end

	print("***MDL VERSION***: " .. __mdl_version)

	init_fast_read(f_vtx)
	local header = vtx_header()
	print("FINISHED LOADING VTX: " .. tostring(mdl_path) .. " (" .. (SysTime() - t0) * 1000 .. " ms)")
	finish_fast_read(f_vtx)

	return {
		header = header,
		bodyparts = header.bodyParts,
	}

end

local function LoadVVD( mdl_path, fast )

	print("LOADING VVD: " .. tostring(mdl_path))

	local t0 = SysTime()

	local base = mdl_path:sub(1, -4)
	local yield_rate_v = fast and 200 or 100
	local yield_rate_f = fast and 1000 or 400

	local f_vvd = file.Open( base .. "vvd", "rb", "GAME" )
	if not f_vvd then ErrorNoHalt("VVD NOT FOUND: " .. tostring(mdl_path)) return nil end

	local t1 = SysTime()

	init_fast_read(f_vvd)

	print("---Read took : " .. (SysTime() - t1) * 1000 .. "ms " .. m_size .. " bytes")

	local header = {
		id = int32(),
		version = int32(),
		checksum = int32(),
		numLODs = int32(),
		numLODVertices = array_of( int32, MAX_NUM_LODS ),
		numFixups = int32(),
		fixupTableStart = int32(),
		vertexDataStart = int32(),
		tangentDataStart = int32(),
	}

	PrintTable(header)

	local fixups = {}
	local vertices = {}
	local tangents = {}

	print("LOAD " .. header.numLODVertices[1] .. " verts...")

	local t1 = SysTime()

	seek_data(header.vertexDataStart)
	for i=1, header.numLODVertices[1] do

		vertices[#vertices+1] = vvd_vertex()
		--task.YieldPer(yield_rate_v, "progress")

	end

	print("---Verts took : " .. (SysTime() - t1) * 1000 .. "ms")

	print("LOAD " .. header.numLODVertices[1] .. " tangents...")

	local t1 = SysTime()

	seek_data(header.tangentDataStart)
	for i=1, header.numLODVertices[1] do

		tangents[#tangents+1] = Vector4( float32(), float32(), float32(), float32() )
		--task.YieldPer(yield_rate_v, "progress")

	end

	print("---Tangents took : " .. (SysTime() - t1) * 1000 .. "ms")

	if header.numFixups > 0 then

		local corrected = {}
		local target = 0
		for i=1, #vertices do corrected[i] = vertices[i] end

		print("LOAD " .. header.numFixups .. " fixups...")

		seek_data(header.fixupTableStart)
		for i=1, header.numFixups do

			local lod = int32()
			local sourceID = int32()
			local numVertices = int32()
			if lod < 0 then continue end
			for i=1, numVertices do
				--task.YieldPer(yield_rate_f, "progress")
				corrected[ i + target ] = vertices[ i + sourceID ]
			end

			target = target + numVertices

		end

		vertices = corrected

	end

	finish_fast_read(f_vvd)

	print("FINISHED LOADING VVD: " .. tostring(mdl_path) .. " (" .. (SysTime() - t0) * 1000 .. " ms)")

	return {
		header = header,
		vertices = vertices,
		tangents = tangents,
		fixups = fixups,
	}

end

local white_color = Color(255,255,255,255)
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

	--print( tostring( min ) )
	--print( tostring( max ) )

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

	--print( #vvd.vertices .. " in " .. #bins .. " bins")

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

	--print("TOOK: " .. ( SysTime() - start ) )

end


--if true then return end

local function CreateMesh( vvd, vtx, mdl )

	local tris = {}
	local LOD = 1

	for i, body in pairs( vtx.bodyparts ) do local m_bodypart = mdl.bodyparts[i]
	for j, model in pairs( body.models ) do local m_model = m_bodypart.models[j]
	for k, msh in pairs( model.lods[ LOD ].meshes ) do local m_mesh = m_model.meshes[k]
	for l, group in pairs( msh.stripgroups ) do
	for m, strip in pairs( group.strips ) do

	for x=0, strip.numIndices-3, 3 do

		local idx = x + strip.indexOffset

		local i0 = group.vertices[ group.indices[idx+1] + 1 ].origMeshVertID + 1
		local i1 = group.vertices[ group.indices[idx+2] + 1 ].origMeshVertID + 1
		local i2 = group.vertices[ group.indices[idx+3] + 1 ].origMeshVertID + 1

		local v0 = vvd.vertices[ i0 + m_mesh.vertexoffset + m_model.vertexindex ]
		local v1 = vvd.vertices[ i1 + m_mesh.vertexoffset + m_model.vertexindex ]
		local v2 = vvd.vertices[ i2 + m_mesh.vertexoffset + m_model.vertexindex ]

		local index = 0 --v0.weights.bone[1] --math.floor( v0.texcoord.x * 10 + v0.texcoord.y * 10 ) --math.floor(x/24)
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

	task.Yield("section", "MDL")
	local mdl = LoadMDL( model, fast )
	if not mdl then return end

	task.Yield("section", "VTX")
	local vtx = LoadVTX( model, fast )
	if not vtx then return end

	task.Yield("section", "VVD")
	local vvd = LoadVVD( model, fast )
	if not vvd then return end

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

if CLIENT then
	local vvd, vtx, mdl = LoadModel( "models/props_sharkbay/boat_hull_v2.mdl" )
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