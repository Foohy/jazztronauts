AddCSLuaFile()

LUMP_ENTITIES					= 0
LUMP_PLANES						= 1
LUMP_TEXDATA					= 2
LUMP_VERTEXES					= 3
LUMP_VISIBILITY					= 4
LUMP_NODES						= 5
LUMP_TEXINFO					= 6
LUMP_FACES						= 7
LUMP_LIGHTING					= 8
LUMP_OCCLUSION					= 9
LUMP_LEAFS						= 10
LUMP_FACEIDS					= 11
LUMP_EDGES						= 12
LUMP_SURFEDGES					= 13
LUMP_MODELS						= 14
LUMP_WORLDLIGHTS				= 15
LUMP_LEAFFACES					= 16
LUMP_LEAFBRUSHES				= 17
LUMP_BRUSHES					= 18
LUMP_BRUSHSIDES					= 19
LUMP_AREAS						= 20
LUMP_AREAPORTALS				= 21
LUMP_UNUSED0					= 22
LUMP_UNUSED1					= 23
LUMP_UNUSED2					= 24
LUMP_UNUSED3					= 25
LUMP_DISPINFO					= 26
LUMP_ORIGINALFACES				= 27
LUMP_PHYSDISP					= 28
LUMP_PHYSCOLLIDE				= 29
LUMP_VERTNORMALS				= 30
LUMP_VERTNORMALINDICES			= 31
LUMP_DISP_LIGHTMAP_ALPHAS		= 32
LUMP_DISP_VERTS					= 33
LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS = 34
LUMP_GAME_LUMP					= 35
LUMP_LEAFWATERDATA				= 36
LUMP_PRIMITIVES					= 37
LUMP_PRIMVERTS					= 38
LUMP_PRIMINDICES				= 39
LUMP_PAKFILE					= 40
LUMP_CLIPPORTALVERTS			= 41
LUMP_CUBEMAPS					= 42
LUMP_TEXDATA_STRING_DATA		= 43
LUMP_TEXDATA_STRING_TABLE		= 44
LUMP_OVERLAYS					= 45
LUMP_LEAFMINDISTTOWATER			= 46
LUMP_FACE_MACRO_TEXTURE_INFO	= 47
LUMP_DISP_TRIS					= 48
LUMP_PHYSCOLLIDESURFACE			= 49
LUMP_WATEROVERLAYS			  = 50
LUMP_LEAF_AMBIENT_INDEX_HDR		= 51
LUMP_LEAF_AMBIENT_INDEX		 = 52
LUMP_LIGHTING_HDR				= 53
LUMP_WORLDLIGHTS_HDR			= 54
LUMP_LEAF_AMBIENT_LIGHTING_HDR	= 55
LUMP_LEAF_AMBIENT_LIGHTING		= 56
LUMP_XZIPPAKFILE				= 57
LUMP_FACES_HDR					= 58
LUMP_MAP_FLAGS				  = 59
LUMP_OVERLAY_FADES				= 60

BSP = {}
BSP.LumpNames = {
	"ENTITIES",
	"PLANES",
	"TEXDATA",
	"VERTEXES",
	"VISIBILITY",
	"NODES",
	"TEXINFO",
	"FACES",
	"LIGHTING",
	"OCCLUSION",
	"LEAFS",
	"FACEIDS",
	"EDGES",
	"SURFEDGES",
	"MODELS",
	"WORLDLIGHTS",
	"LEAFFACES",
	"LEAFBRUSHES",
	"BRUSHES",
	"BRUSHSIDES",
	"AREAS",
	"AREAPORTALS",
	"UNUSED0",
	"UNUSED1",
	"UNUSED2",
	"UNUSED3",
	"DISPINFO",
	"ORIGINALFACES",
	"PHYSDISP",
	"PHYSCOLLIDE",
	"VERTNORMALS",
	"VERTNORMALINDICES",
	"DISP_LIGHTMAP_ALPHAS",
	"DISP_VERTS",
	"DISP_LIGHTMAP_SAMPLE_POSITIONS",
	"GAME_LUMP",
	"LEAFWATERDATA",
	"PRIMITIVES",
	"PRIMVERTS",
	"PRIMINDICES",
	"PAKFILE",
	"CLIPPORTALVERTS",
	"CUBEMAPS",
	"TEXDATA_STRING_DATA",
	"TEXDATA_STRING_TABLE",
	"OVERLAYS",
	"LEAFMINDISTTOWATER",
	"FACE_MACRO_TEXTURE_INFO",
	"DISP_TRIS",
	"PHYSCOLLIDESURFACE",
	"WATEROVERLAYS",
	"LEAF_AMBIENT_INDEX_HDR",
	"LEAF_AMBIENT_INDEX",
	"LIGHTING_HDR",
	"WORLDLIGHTS_HDR",
	"LEAF_AMBIENT_LIGHTING_HDR",
	"LEAF_AMBIENT_LIGHTING",
	"XZIPPAKFILE",
	"FACES_HDR",
	"MAP_FLAGS",
	"OVERLAY_FADES",
}

BSP.Lump_t = Struct({
	INT32.offset,
	INT32.length,
	INT32.version,
	CHAR.fourcc[4],
})

BSP.Header_t = Struct({
	INT32.ident,
	INT32.version,
	BSP.Lump_t.lumps[64],
	INT32.revision,
})

BSP.Vertex_t = VECTOR

BSP.TexMatrix_t = StructDecl(
	function(f) return TexMatrix( VECTOR4.read(f), VECTOR4.read(f) ) end,
	function(f, v) VECTOR4.write(f, v.s) VECTOR4.write(f, v.t) end,
	VECTOR4.sizeof * 2
)

BSP.Plane_t = StructDecl(
	function(f) return Plane( VECTOR.read(f), FLOAT.read(f), INT32.read(f) ) end,
	function(f, v) VECTOR.write(f, v.normal) FLOAT.write(f, v.dist) INT32.write(f, v.type or 0) end,
	20
)

BSP.Edge_t = Struct({
	UINT16.v[2]
}, { returns = "v" })

BSP.SurfEdge_t = INT32

BSP.ColorRGBExp32_t = Struct({
	UINT8.r,
	UINT8.g,
	UINT8.b,
	INT8.exponent,
})

BSP.CompressedLightCube_t = Struct({
	BSP.ColorRGBExp32_t.m_Color[6],
})

BSP.Face_t = Struct({
	UINT16.planenum,
	UINT8.side,
	UINT8.onNode,
	INT32.firstedge,
	INT16.numedges,
	INT16.texinfo,
	INT16.dispinfo,
	INT16.surfaceFogVolumeID,
	UINT8.styles[4],
	INT32.lightofs,
	FLOAT.area,
	INT32.lightmaptextureminsinluxels[2],
	INT32.lightmaptexturesizeinluxels[2],
	INT32.origFace,
	UINT16.numPrims,
	UINT16.firstPrimID,
	UINT32.smoothingGroups,
})

BSP.Brush_t = Struct({
	INT32.firstside,
	INT32.numsides,
	INT32.contents,
})

BSP.BrushSide_t = Struct({
	UINT16.planenum,
	INT16.texinfo,
	INT16.dispinfo,
	INT16.bevel,
})

BSP.Node_t = Struct({
	INT32.planenum,
	INT32.children[2],
	INT16.mins[3],
	INT16.maxs[3],
	UINT16.firstface,
	UINT16.numfaces,
	INT16.area,
	INT16.padding,
})

BSP.Leaf_t = Struct({
	INT32.contents,
	INT16.cluster,
	INT16.areaflags,
	INT16.mins[3],
	INT16.maxs[3],
	UINT16.firstleafface,
	UINT16.numleaffaces,
	UINT16.firstleafbrush,
	UINT16.numleafbrushes,
	INT16.leafWaterDataID,
	INT16.padding,
})

BSP.LeafV0_t = Struct({
	INT32.contents,
	INT16.cluster,
	INT16.areaflags,
	INT16.mins[3],
	INT16.maxs[3],
	UINT16.firstleafface,
	UINT16.numleaffaces,
	UINT16.firstleafbrush,
	UINT16.numleafbrushes,
	INT16.leafWaterDataID,
	BSP.CompressedLightCube_t.m_AmbientLighting,
	UINT16.padding,
})

BSP.TexInfo_t = Struct({
	BSP.TexMatrix_t.textureVecs,
	BSP.TexMatrix_t.lightmapVecs,
	INT32.flags,
	INT32.texdata,
})

BSP.TexData_t = Struct({
	VECTOR.reflectivity,
	INT32.nameStringTableID,
	INT32.width,
	INT32.height,
	INT32.view_width,
	INT32.view_height,
})

BSP.Model_t = Struct({
	VECTOR.mins,
	VECTOR.maxs,
	VECTOR.origin,
	INT32.headnode,
	INT32.firstface,
	INT32.numfaces,
})

BSP.Vis_t = Struct({
	INT32.numclusters,
	INT32.byteofs[2]["numclusters"],
}, { returns = "byteofs" })

BSP.Area_t = Struct({
	INT32.numareaportals,
	INT32.firstareaportal,
})

BSP.AreaPortal_t = Struct({
	UINT16.m_PortalKey,
	UINT16.otherarea,
	UINT16.m_FirstClipPortalVert,
	UINT16.m_nClipPortalVerts,
	INT32.planenum
})

BSP.LeafWaterData_t = Struct({
	FLOAT.surfaceZ,
	FLOAT.minZ,
	UINT16.surfaceTexInfoID,
	UINT16.padding,
})

BSP.DispSubNeighbor_t = Struct({
	UINT16.m_iNeighbor,
	UINT8.m_NeighborOrientation,
	UINT8.m_Span,
	UINT8.m_NeighborSpan,
	UINT8.padding[1],
})

BSP.DispNeighbor_t = Struct({
	BSP.DispSubNeighbor_t.m_SubNeighbors[2],
})

BSP.DispCornerNeighbors_t = Struct({
	UINT16.m_Neighbors[4],
	UINT8.m_nNeighbors,
	UINT8.padding[1],
})

BSP.DispInfo_t = Struct({
	VECTOR.startPosition,
	INT32.DispVertStart,
	INT32.DispTriStart,
	INT32.power,
	INT32.minTess,
	FLOAT.smoothingAngle,
	INT32.contents,
	UINT16.MapFace,
	INT32.LightmapAlphaStart,
	INT32.LightmapSamplePositionStart,
	BSP.DispNeighbor_t.EdgeNeighbors[4],
	BSP.DispCornerNeighbors_t.CornerNeighbors[4],
	UINT32.AllowedVerts[10],
	UINT8.padding[2],
})

BSP.DispVert_t = Struct({
	VECTOR.vec,
	FLOAT.dist,
	FLOAT.alpha,
})

BSP.DISPTRI_TAG_SURFACE = 0x1
BSP.DISPTRI_TAG_WALKABLE = 0x2
BSP.DISPTRI_TAG_BUILDABLE = 0x4
BSP.DISPTRI_FLAG_SURFPROP1 = 0x8
BSP.DISPTRI_FLAG_SURFPROP2 = 0x10

BSP.DispTri_t = Struct({
	UINT16.tags,
})

BSP.WorldLight_t = Struct({
	VECTOR.origin,
	VECTOR.intensity,
	VECTOR.normal,
	INT32.cluster,
	INT32.type,
	INT32.style,
	FLOAT.stopdot,
	FLOAT.stopdot2,
	FLOAT.exponent,
	FLOAT.radius,
	FLOAT.constant_attn,
	FLOAT.linear_attn,
	FLOAT.quadratic_attn,
	INT32.flags,
	INT32.texinfo,
	INT32.owner,
})

BSP.CubemapSample_t = Struct({
	INT32.origin[3],
	INT32.size,
})

BSP.Overlay_t = Struct({
	INT32.Id,
	INT16.TexInfo,
	UINT16.FaceCountAndRenderOrder,
	INT32.Ofaces[64],
	FLOAT.U[2],
	FLOAT.V[2],
	VECTOR.UVPoints[4],
	VECTOR.Origin,
	VECTOR.BasisNormal,
})

BSP.LeafAmbientLighting_t = Struct({
	BSP.CompressedLightCube_t.cube,
	UINT8.x,
	UINT8.y,
	UINT8.z,
	UINT8.pad,
})

BSP.LeafAmbientIndex_t = Struct({
	UINT16.ambientSampleCount,
	UINT16.firstAmbientSample,
})

BSP.OccluderData_t = Struct({
	INT32.flags,
	INT32.firstpoly,
	INT32.polycount,
	VECTOR.mins,
	VECTOR.maxs,
	INT32.area,
})

BSP.OccluderPolyData_t = Struct({
	INT32.firstvertexindex,
	INT32.vertexcount,
	INT32.planenum,
})

BSP.Occluder_t = Struct({
	INT32.count,
	BSP.OccluderData_t.data["count"],
	INT32.polyDataCount,
	BSP.OccluderPolyData_t.polyData["polyDataCount"],
	INT32.vertexIndexCount,
	INT32.vertexIndices["vertexIndexCount"],
})

BSP.GameLump_t = Struct({
	CHAR.id[4],
	UINT16.flags,
	UINT16.version,
	INT32.fileofs,
	INT32.filelen,
}, { key = "id" })

BSP.GameLumpHeader_t = Struct({
	INT32.lumpCount,
	BSP.GameLump_t.gamelump["lumpCount"],
}, { returns = "gamelump" })

BSP.StaticPropDictLump_t = Struct({
	INT32.dictEntries,
	CHAR.name[128]["dictEntries"],
}, { returns = "name" })

BSP.StaticPropLeafLump_t = Struct({
	INT32.leafEntries,
	UINT16.leaf["leafEntries"],
}, { returns = "leaf" })

BSP.StaticPropLump_t = {}
BSP.StaticPropLump_t[4] = Struct({
	VECTOR.origin,
	QANGLE.angles,

	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	VECTOR.lightingorigin,
})

BSP.StaticPropLump_t[5] = Struct({
	VECTOR.origin,
	QANGLE.angles,

	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	IVECTOR.lightingorigin,
	FLOAT.forcedfadescale,
})

BSP.StaticPropLump_t[6] = Struct({
	VECTOR.origin,
	QANGLE.angles,

	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	IVECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT16.mindxlevel,
	UINT16.maxdxlevel,
})

BSP.StaticPropLump_t[7] = Struct({
	VECTOR.origin,
	QANGLE.angles,

	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	IVECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT16.mindxlevel,
	UINT16.maxdxlevel,

	INT32.color,
})

BSP.StaticPropLump_t[8] = Struct({
	VECTOR.origin,
	QANGLE.angles,

	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	IVECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT8.mincpulevel,
	UINT8.maxcpulevel,
	UINT8.mingpulevel,
	UINT8.maxgpulevel,

	INT32.color,
})

BSP.StaticPropLump_t[9] = Struct({
	VECTOR.origin,
	QANGLE.angles,

	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	IVECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT8.mincpulevel,
	UINT8.maxcpulevel,
	UINT8.mingpulevel,
	UINT8.maxgpulevel,

	INT32.color
})

BSP.StaticPropLump_t[10] = Struct({
	VECTOR.origin,
	QANGLE.angles,

	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	IVECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT8.mincpulevel,
	UINT8.maxcpulevel,
	UINT8.mingpulevel,
	UINT8.maxgpulevel,

	INT32.color,
	FLOAT.unknown
})

BSP.PhysModelHeader_t = Struct({
	INT32.modelIndex,
	INT32.dataSize,
	INT32.keydataSize,
	INT32.solidCount,
})

local function Chunk( lumpid, size, f, ... )

	local name = BSP.LumpNames[lumpid+1]
	task.Yield("chunk", name, size)
	local out = f(...)
	task.Yield("chunkdone", name, size, out)
	return out

end

local function ReadLumpStruct( f, lump, struct, lumpid )

	local size = lump.length / struct.sizeof
	assert( math.floor(size) == size )

	f:Seek( lump.offset )

	return Chunk( lumpid, size, struct[ size ].read, f )
end

local function StructLump( lump, struct )

	return function( f, header )
		return ReadLumpStruct( f, header.lumps[lump+1], struct, lump )
	end

end

local function NOT_IMPLEMENTED( lump )

	return function( f, header )
		print( "***WARNING: Lump not implemented yet: " .. BSP.LumpNames[lump+1] .. "***" )
		return Chunk( lump, 0, function() end )
	end

end

BSP.Readers = {}
BSP.Readers[LUMP_ENTITIES] = function( f, header )
	local lump = header.lumps[LUMP_ENTITIES+1]

	f:Seek( lump.offset )
	return Chunk( LUMP_ENTITIES, lump.length, function()
		return f:Read( lump.length )
	end)
end

BSP.Readers[LUMP_PLANES] = StructLump( LUMP_PLANES, BSP.Plane_t )
BSP.Readers[LUMP_TEXDATA] = StructLump( LUMP_TEXDATA, BSP.TexData_t )
BSP.Readers[LUMP_VERTEXES] = StructLump( LUMP_VERTEXES, BSP.Vertex_t )

BSP.Readers[LUMP_VISIBILITY] = function( f, header )
	f:Seek( header.lumps[LUMP_VISIBILITY+1].offset )
	return BSP.Vis_t.read( f )
end

BSP.Readers[LUMP_NODES] = StructLump( LUMP_NODES, BSP.Node_t )
BSP.Readers[LUMP_TEXINFO] = StructLump( LUMP_TEXINFO, BSP.TexInfo_t )
BSP.Readers[LUMP_FACES] = StructLump( LUMP_FACES, BSP.Face_t )
BSP.Readers[LUMP_LIGHTING] = StructLump( LUMP_LIGHTING, BSP.ColorRGBExp32_t )

BSP.Readers[LUMP_OCCLUSION] = function( f, header )
	f:Seek( header.lumps[LUMP_OCCLUSION+1].offset )
	return BSP.Occluder_t.read( f )
end

BSP.Readers[LUMP_LEAFS] = function( f, header )
	if header.lumps[LUMP_LEAFS+1].version == 0 then
		return StructLump( LUMP_LEAFS, BSP.LeafV0_t )( f, header )
	else
		return StructLump( LUMP_LEAFS, BSP.Leaf_t )( f, header )
	end
end

BSP.Readers[LUMP_FACEIDS] = StructLump( LUMP_FACEIDS, UINT16 )
BSP.Readers[LUMP_EDGES] = StructLump( LUMP_EDGES, BSP.Edge_t )
BSP.Readers[LUMP_SURFEDGES] = StructLump( LUMP_SURFEDGES, BSP.SurfEdge_t )
BSP.Readers[LUMP_MODELS] = StructLump( LUMP_MODELS, BSP.Model_t )
BSP.Readers[LUMP_WORLDLIGHTS] = StructLump( LUMP_WORLDLIGHTS, BSP.WorldLight_t )
BSP.Readers[LUMP_LEAFFACES] = StructLump( LUMP_LEAFFACES, UINT16 )
BSP.Readers[LUMP_LEAFBRUSHES] = StructLump( LUMP_LEAFBRUSHES, UINT16 )
BSP.Readers[LUMP_BRUSHES] = StructLump( LUMP_BRUSHES, BSP.Brush_t )
BSP.Readers[LUMP_BRUSHSIDES] = StructLump( LUMP_BRUSHSIDES, BSP.BrushSide_t )
BSP.Readers[LUMP_AREAS] = StructLump( LUMP_AREAS, BSP.Area_t )
BSP.Readers[LUMP_AREAPORTALS] = StructLump( LUMP_AREAPORTALS, BSP.AreaPortal_t )
BSP.Readers[LUMP_DISPINFO] = StructLump( LUMP_DISPINFO, BSP.DispInfo_t )
BSP.Readers[LUMP_ORIGINALFACES] = StructLump( LUMP_ORIGINALFACES, BSP.Face_t )
BSP.Readers[LUMP_PHYSDISP] = NOT_IMPLEMENTED( LUMP_PHYSDISP )

BSP.Readers[LUMP_PHYSCOLLIDE] = function( f, header )
	f:Seek( header.lumps[LUMP_PHYSCOLLIDE+1].offset )

	local eof = f:Tell() + header.lumps[LUMP_PHYSCOLLIDE+1].length
	local out = {}

	local stack = {}
	local function push( f, addr )
		print("**PUSHADDR: " .. tostring(addr))
		table.insert( stack, f:Tell() )
		f:Seek( addr )
	end

	local function pop( f )
		local addr = stack[#stack]
		f:Seek( addr )
		table.remove( stack, #stack )
		return addr
	end

	local function readTriangle( f )

		local tri = PHY.IVPCompactTriangle_t.read( f )
		tri.tri_index = bit.band( tri.indices, 0x00000FFF )
		tri.pierce_index = bit.rshift( bit.band( tri.indices, 0x00FFF000 ), 12 )
		tri.material_index = bit.rshift( bit.band( tri.indices, 0x7F000000 ), 24 )
		tri.is_virtual = bit.band( tri.indices, 0x10000000 ) ~= 0
		tri.indices = nil

		for j=1, 3 do
			local edge = tri.c_three_edges[j]
			edge.start_point_index = bit.band( edge.indices, 0x0000FFFF )
			edge.opposite_index = bit.rshift( bit.band( edge.indices, 0x7FFF0000 ), 16 )

			if bit.band( edge.opposite_index, 0x4000 ) ~= 0 then
				edge.opposite_index = 32767 - edge.opposite_index
			end

			edge.is_virtual = bit.band( edge.indices, 0x10000000 ) ~= 0
			edge.indices = nil
		end
		return tri

	end

	while true do
		local model = BSP.PhysModelHeader_t.read( f )
		local size = model.dataSize + model.keydataSize

		if size <= 0 then break end

		--PrintTable(model)

		local jump = f:Tell() + model.dataSize + model.keydataSize

			local surf = PHY.CompactSurfaceHeader_t.read( f )
			print("SURF")
			--PrintTable( surf )

			local cs_header_size = PHY.IVPCompactSurface_t.sizeof
			local surf2 = PHY.IVPCompactSurface_t.read(f)
			surf2.max_factor_surface_deviation = bit.band( surf2.size_and_max_surface_deviation, 0xFF )
			surf2.size = bit.rshift( bit.band( surf2.size_and_max_surface_deviation, 0xFFFFFF00 ), 8 )
			surf2.size_and_max_surface_deviation = nil
			surf2.ledge_list_size = surf2.offset_ledgetree_root - cs_header_size
			surf2.ledge_tree_size = surf2.size - surf2.ledge_list_size - cs_header_size

			surf2.ledge_tree_size = surf2.ledge_tree_size / PHY.IVPCompactLedgeTreeNode_t.sizeof
			--PrintTable( surf2 )
			PrintTable({
				model = model.modelIndex,
				size = surf2.size,
				ledge_list_size = surf2.ledge_list_size,
				ledge_tree_size = surf2.ledge_tree_size,
			})
			assert( surf2.dummy[3] == PHY.IVP_COMPACT_SURFACE_ID )

			local remain_size = surf2.ledge_list_size + 960

			for x=1, 50 do

				--print("LEDGE")
				local ledge_start = f:Tell()
				local ledge = PHY.IVPCompactLedge_t.read( f )

				ledge.has_children_flag = bit.band( ledge.data, 0x00000003 ) ~= 0
				ledge.is_compact_flag = bit.rshift( bit.band( ledge.data, 0x0000000C ), 2 ) ~= 0
				ledge.size = bit.rshift( bit.band( ledge.data, 0xFFFFFF00 ), 8 ) * 16
				ledge.n_points = (ledge.size / 16) - ledge.n_triangles - 1
				ledge.tris = {}
				ledge.points = {}
				PrintTable( {ledge} )
				for i=1, ledge.n_triangles do
					local tri = readTriangle( f )
					table.insert( ledge.tris, tri )
				end

				--[[push( f, ledge_start + ledge.c_point_offset )

				for i=1, ledge.n_points do
					local point = PHY.IVPCompactPolyPoint_t.read( f )
					table.insert( ledge.points, Vector(point.x, point.y, point.z) )
				end
				PrintTable( ledge )

				pop( f )]]

				remain_size = remain_size - ledge.size --( f:Tell() - ledge_start ) - ledge.n_points * PHY.IVPCompactPolyPoint_t.sizeof
				print( remain_size )

				--if remain_size <= 0 then break end

			end

			print( "LEFT: " .. jump - f:Tell() )

		f:Seek( jump )
		if f:Tell() >= eof then break end

		if true then break end

	end

	return out

end

BSP.Readers[LUMP_VERTNORMALS] = StructLump( LUMP_VERTNORMALS, VECTOR )
BSP.Readers[LUMP_VERTNORMALINDICES] = StructLump( LUMP_VERTNORMALINDICES, UINT16 )
BSP.Readers[LUMP_DISP_LIGHTMAP_ALPHAS] = NOT_IMPLEMENTED( LUMP_DISP_LIGHTMAP_ALPHAS )
BSP.Readers[LUMP_DISP_VERTS] = StructLump( LUMP_DISP_VERTS, BSP.DispVert_t )
BSP.Readers[LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS] = NOT_IMPLEMENTED( LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS )

BSP.Readers[LUMP_GAME_LUMP] = function( f, header )

	f:Seek( header.lumps[LUMP_GAME_LUMP+1].offset )

	local lumps = BSP.GameLumpHeader_t.read( f )
	local proplump = lumps["prps"]

	if not proplump then return {} end

	return Chunk( LUMP_GAME_LUMP, proplump.filelen, function()

		local out = {}
		local struct = BSP.StaticPropLump_t[ proplump.version ]
		if struct then

			f:Seek( proplump.fileofs )

			local dict = BSP.StaticPropDictLump_t.read( f )
			local leafs = BSP.StaticPropLeafLump_t.read( f )
			local props = Struct({ INT32.count, struct.props["count"] }, { returns = "props" }).read( f )

			for k, prop in pairs( props ) do
				prop.model = dict[ prop.proptype + 1 ]
				prop.leaf = leafs[ prop.firstleaf + 1 ]
				prop.id = k
			end
			out.props = props

		else
			ErrorNoHalt("Unable to load static prop lump for version: " ..  proplump.version)
			out.props = {}
		end
		return out

	end )
end

BSP.Readers[LUMP_LEAFWATERDATA] = StructLump( LUMP_LEAFWATERDATA, BSP.LeafWaterData_t )

BSP.Readers[LUMP_PRIMITIVES] = NOT_IMPLEMENTED( LUMP_PRIMITIVES )
BSP.Readers[LUMP_PRIMVERTS] = NOT_IMPLEMENTED( LUMP_PRIMVERTS )
BSP.Readers[LUMP_PRIMINDICES] = NOT_IMPLEMENTED( LUMP_PRIMINDICES )
BSP.Readers[LUMP_PAKFILE] = NOT_IMPLEMENTED( LUMP_PAKFILE )
BSP.Readers[LUMP_CLIPPORTALVERTS] = NOT_IMPLEMENTED( LUMP_CLIPPORTALVERTS )

BSP.Readers[LUMP_CUBEMAPS] = StructLump( LUMP_CUBEMAPS, BSP.CubemapSample_t )

BSP.Readers[LUMP_TEXDATA_STRING_DATA] = function( f, header )
	local lump = header.lumps[LUMP_TEXDATA_STRING_DATA+1]
	local eof = lump.offset + lump.length
	local str = ""
	local i = 0
	local names = {}

	f:Seek( lump.offset )

	return Chunk( LUMP_TEXDATA_STRING_DATA, lump.length, function()

		while f:Tell() < eof do
			local ch = CHAR.read(f)
			if ch == '\0' then
				table.insert( names, str )
				str = ""
			else
				str = str .. ch
			end
			i = i + 1
			if i % 4000 == 1 then task.Yield("progress", i) end
		end
		return names

	end )
end

BSP.Readers[LUMP_TEXDATA_STRING_TABLE] = NOT_IMPLEMENTED( LUMP_TEXDATA_STRING_TABLE ) --we don't ever need to load this

BSP.Readers[LUMP_OVERLAYS] = StructLump( LUMP_OVERLAYS, BSP.Overlay_t )

--Not implemented yet
BSP.Readers[LUMP_LEAFMINDISTTOWATER] = NOT_IMPLEMENTED( LUMP_LEAFMINDISTTOWATER )
BSP.Readers[LUMP_FACE_MACRO_TEXTURE_INFO] = NOT_IMPLEMENTED( LUMP_FACE_MACRO_TEXTURE_INFO )
BSP.Readers[LUMP_DISP_TRIS] = NOT_IMPLEMENTED( LUMP_DISP_TRIS )
BSP.Readers[LUMP_PHYSCOLLIDESURFACE] = NOT_IMPLEMENTED( LUMP_PHYSCOLLIDESURFACE )
BSP.Readers[LUMP_WATEROVERLAYS] = NOT_IMPLEMENTED( LUMP_WATEROVERLAYS )
BSP.Readers[LUMP_LEAF_AMBIENT_INDEX_HDR] = NOT_IMPLEMENTED( LUMP_LEAF_AMBIENT_INDEX_HDR )
BSP.Readers[LUMP_LEAF_AMBIENT_INDEX] = NOT_IMPLEMENTED( LUMP_LEAF_AMBIENT_INDEX )
BSP.Readers[LUMP_LIGHTING_HDR] = NOT_IMPLEMENTED( LUMP_LIGHTING_HDR )
BSP.Readers[LUMP_WORLDLIGHTS_HDR] = NOT_IMPLEMENTED( LUMP_WORLDLIGHTS_HDR )
BSP.Readers[LUMP_LEAF_AMBIENT_LIGHTING_HDR] = NOT_IMPLEMENTED( LUMP_LEAF_AMBIENT_LIGHTING_HDR )
BSP.Readers[LUMP_LEAF_AMBIENT_LIGHTING] = NOT_IMPLEMENTED( LUMP_LEAF_AMBIENT_LIGHTING )
BSP.Readers[LUMP_XZIPPAKFILE] = NOT_IMPLEMENTED( LUMP_XZIPPAKFILE )
BSP.Readers[LUMP_FACES_HDR] = NOT_IMPLEMENTED( LUMP_FACES_HDR )
BSP.Readers[LUMP_MAP_FLAGS] = NOT_IMPLEMENTED( LUMP_MAP_FLAGS )
BSP.Readers[LUMP_OVERLAY_FADES] = NOT_IMPLEMENTED( LUMP_OVERLAY_FADES )