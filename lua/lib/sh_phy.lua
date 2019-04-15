AddCSLuaFile()

if SERVER then return end

PHY = {}

PHY.IVP_COMPACT_SURFACE_ID = 0x53505649

PHY.PhyHeader_t = Struct({
	INT32.size,
	INT32.id,
	INT32.solidCount,
	INT32.checkSum,
})

PHY.CompactSurfaceHeader_t = Struct({
	INT32.size,
	CHAR.vphysicsid[4],
	INT16.version,
	INT16.modelType,
	INT32.surfaceSize,
	VECTOR.dragAxisAreas,
	INT32.axisMapSize,
})

PHY.IVPCompactSurface_t = Struct({
	VECTOR.mass_center,
	VECTOR.rotation_intertia,
	FLOAT.upper_limit_radius,
	INT32.size_and_max_surface_deviation,
	INT32.offset_ledgetree_root,
	INT32.dummy[3],
})

PHY.IVPCompactPolyPoint_t = VECTOR4
PHY.IVPCompactEdge_t = Struct({
	UINT32.indices, --start_point_index:16, opposite_index:15, is_virtual:1
})

PHY.IVPCompactTriangle_t = Struct({
	UINT32.indices, --tri_index:12, pierce_index:12, material_index:7, is_virtual:1
	PHY.IVPCompactEdge_t.c_three_edges[3],
})

PHY.IVPCompactLedge_t = Struct({
	INT32.c_point_offset,
	INT32.ledgetree_node_offset,
	UINT32.data,  --has_chilren_flag:2, is_compact_flag:2, dummy:4, size_div_16:24
	INT16.n_triangles,
	INT16.unknown,
})

PHY.IVPCompactLedgeTreeNode_t = Struct({
	INT32.offset_right_node,
	INT32.offset_compact_ledge,
	VECTOR.center,
	FLOAT.radius,
	UINT8.box_sizes[3],
	UINT8.free_0,
})

PHY.LegacySurfaceHeader_t = Struct({
	INT32.size,
	VECTOR.mass_center,
	VECTOR.rotation_inertia,
	FLOAT.upper_limit_radius,
	INT32.max_deviation,
	INT32.byte_size,
	INT32.offset_ledgetree_root,
	INT32.dummy[3],
})

assert( PHY.IVPCompactLedge_t.sizeof == 16 )
assert( PHY.IVPCompactTriangle_t.sizeof == 16 )

--19