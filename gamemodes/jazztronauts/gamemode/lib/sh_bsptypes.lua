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
LUMP_WATEROVERLAYS              = 50
LUMP_LEAF_AMBIENT_INDEX_HDR		= 51
LUMP_LEAF_AMBIENT_INDEX         = 52
LUMP_LIGHTING_HDR				= 53
LUMP_WORLDLIGHTS_HDR			= 54
LUMP_LEAF_AMBIENT_LIGHTING_HDR	= 55
LUMP_LEAF_AMBIENT_LIGHTING		= 56
LUMP_XZIPPAKFILE				= 57
LUMP_FACES_HDR					= 58
LUMP_MAP_FLAGS                  = 59
LUMP_OVERLAY_FADES				= 60

BSP = {}
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
})

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

print("OVERLAY SIZE: " .. tostring(BSP.Overlay_t.sizeof))

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

	VECTOR.lightingorigin,
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

	VECTOR.lightingorigin,
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

	VECTOR.lightingorigin,
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

	VECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT8.mincpulevel,
	UINT8.maxcpulevel,
	UINT8.mingpulevel,
	UINT8.maxgpulevel,

	INT32.color,
})

local function ReadLumpStruct( f, lump, struct )
	local size = lump.length / struct.sizeof
	
	print("LUMP: " .. tostring(struct))

	assert( math.floor(size) == size )
	f:Seek( lump.offset )

	return struct[ size ].read( f )
end

local function StructLump( lump, struct )

	return function( f, header )
		return ReadLumpStruct( f, header.lumps[lump+1], struct )
	end

end

BSP.Readers = {}
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
BSP.Readers[LUMP_PHYSDISP] = nil
BSP.Readers[LUMP_PHYSCOLLIDE] = nil
BSP.Readers[LUMP_VERTNORMALS] = StructLump( LUMP_VERTNORMALS, VECTOR )
BSP.Readers[LUMP_VERTNORMALINDICES] = StructLump( LUMP_VERTNORMALINDICES, UINT16 )
BSP.Readers[LUMP_DISP_LIGHTMAP_ALPHAS] = nil
BSP.Readers[LUMP_DISP_VERTS] = StructLump( LUMP_DISP_VERTS, BSP.DispVert_t )
BSP.Readers[LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS] = nil

BSP.Readers[LUMP_GAME_LUMP] = function( f, header )
	f:Seek( header.lumps[LUMP_GAME_LUMP+1].offset )
	local out = {}
	local lumps = BSP.GameLumpHeader_t.read( f )
	local proplump = lumps["prps"]

	if proplump then
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
			out.props = {}
		end
	end
	return out
end

BSP.Readers[LUMP_LEAFWATERDATA] = StructLump( LUMP_LEAFWATERDATA, BSP.LeafWaterData_t )
BSP.Readers[LUMP_PRIMITIVES] = nil
BSP.Readers[LUMP_PRIMVERTS] = nil
BSP.Readers[LUMP_PRIMINDICES] = nil
BSP.Readers[LUMP_PAKFILE] = nil
BSP.Readers[LUMP_CLIPPORTALVERTS] = nil
BSP.Readers[LUMP_CUBEMAPS] = StructLump( LUMP_CUBEMAPS, BSP.CubemapSample_t )

BSP.Readers[LUMP_TEXDATA_STRING_DATA] = function( f, header )
	local lump = header.lumps[LUMP_TEXDATA_STRING_DATA+1]
	local eof = lump.offset + lump.length
	local str = ""
	local i = 0
	local names = {}

	f:Seek( lump.offset )
	while f:Tell() < eof do
		local ch = CHAR.read(f)
		if ch == '\0' then
			table.insert( names, str )
			str = ""
		else
			str = str .. ch
		end
		i = i + 1
		if i % 1000 == 1 then task.Yield("progress", i) end
	end
	return names
end

BSP.Readers[LUMP_TEXDATA_STRING_TABLE] = nil --we don't ever need to load this
BSP.Readers[LUMP_OVERLAYS] = StructLump( LUMP_OVERLAYS, BSP.Overlay_t )
BSP.Readers[LUMP_LEAFMINDISTTOWATER] = nil
BSP.Readers[LUMP_FACE_MACRO_TEXTURE_INFO] = nil
BSP.Readers[LUMP_DISP_TRIS] = nil
BSP.Readers[LUMP_PHYSCOLLIDESURFACE] = nil
BSP.Readers[LUMP_WATEROVERLAYS] = nil
BSP.Readers[LUMP_LEAF_AMBIENT_INDEX_HDR] = nil
BSP.Readers[LUMP_LEAF_AMBIENT_INDEX] = nil
BSP.Readers[LUMP_LIGHTING_HDR] = nil
BSP.Readers[LUMP_WORLDLIGHTS_HDR] = nil
BSP.Readers[LUMP_LEAF_AMBIENT_LIGHTING_HDR] = nil
BSP.Readers[LUMP_LEAF_AMBIENT_LIGHTING] = nil
BSP.Readers[LUMP_XZIPPAKFILE] = nil
BSP.Readers[LUMP_FACES_HDR] = nil	
BSP.Readers[LUMP_MAP_FLAGS] = nil          
BSP.Readers[LUMP_OVERLAY_FADES] = nil		

if true then return end

if CLIENT then

	local f = file.Open( "maps/jazz_bar.bsp", "rb", "GAME" )
	local header = BSP.Header_t.read(f)

	local function load()

		BSP.Readers[LUMP_PLANES]( f, header )
		BSP.Readers[LUMP_TEXDATA]( f, header )
		BSP.Readers[LUMP_VERTEXES]( f, header )
		BSP.Readers[LUMP_NODES]( f, header )
		BSP.Readers[LUMP_LEAFS]( f, header )
		BSP.Readers[LUMP_BRUSHES]( f, header )
		BSP.Readers[LUMP_BRUSHSIDES]( f, header )
		BSP.Readers[LUMP_MODELS]( f, header )
		BSP.Readers[LUMP_FACES]( f, header )
		BSP.Readers[LUMP_TEXINFO]( f, header )
		BSP.Readers[LUMP_TEXDATA_STRING_DATA]( f, header )
		BSP.Readers[LUMP_EDGES]( f, header )
		BSP.Readers[LUMP_SURFEDGES]( f, header )
		BSP.Readers[LUMP_GAME_LUMP]( f, header )
		BSP.Readers[LUMP_OVERLAYS]( f, header )

	end

	local t = task.New( load, 1 )
	function t:chunk( name, count )
		Msg("LOADING: " .. string.upper(name) .. " : " .. count )
	end

	function t:progress()
		Msg(".")
	end

	function t:chunkdone( name, count, tab )
		Msg("DONE\n")
	end

end