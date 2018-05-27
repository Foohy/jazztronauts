AddCSLuaFile()

module( "bsp2", package.seeall )


local processes = {}

local function AddProcess( name, f )
	table.insert( processes, {
		name = name,
		func = f,
	})
end

AddProcess( "Linking", function( data )

	local edges = data[LUMP_EDGES]
	for k, surfedge in pairs( ( edges and data[LUMP_SURFEDGES] ) or {} ) do
		data[LUMP_SURFEDGES][k] = surfedge > 0 and edges[surfedge+1] or { edges[-surfedge+1][2], edges[-surfedge+1][1] }
		task.YieldPer(10000, "progress")
	end

	for k, texdata in pairs( data[LUMP_TEXDATA] or {} ) do
		texdata.material = data[LUMP_TEXDATA_STRING_DATA] and data[LUMP_TEXDATA_STRING_DATA][texdata.nameStringTableID+1]
		texdata.nameStringTableID = nil
		task.YieldPer(10000, "progress")
	end

	for k, texinfo in pairs( data[LUMP_TEXINFO] or {} ) do
		texinfo.texdata = data[LUMP_TEXDATA] and data[LUMP_TEXDATA][texinfo.texdata+1]
		task.YieldPer(10000, "progress")
	end

	local facelist = data[LUMP_FACES] or data[LUMP_ORIGINALFACES]

	for k, node in pairs( data[LUMP_NODES] or {} ) do
		node.plane = data[LUMP_PLANES] and data[LUMP_PLANES][node.planenum+1]
		node.planenum = nil

		for i = 1, 2 do
			node.children[i] = node.children[i] >= 0 and data[LUMP_NODES][ node.children[i]+1 ] or data[LUMP_LEAFS][ -(node.children[i]+1)+1 ]
		end
		node.mins = Vector(node.mins[1], node.mins[2], node.mins[3])
		node.maxs = Vector(node.maxs[1], node.maxs[2], node.maxs[3])

		node.faces = {}
		for i = node.firstface+1, node.firstface + node.numfaces do
			table.insert( node.faces, facelist and facelist[i] )
			task.YieldPer(10000, "progress")
		end
	end

	for k, leafface in pairs( data[LUMP_LEAFFACES] or {} ) do
		data[LUMP_LEAFFACES][k] = facelist and facelist[leafface+1]
		task.YieldPer(10000, "progress")
	end

	for k, leafbrush in pairs( data[LUMP_LEAFBRUSHES] or {} ) do
		data[LUMP_LEAFBRUSHES][k] = data[LUMP_BRUSHES] and data[LUMP_BRUSHES][leafbrush+1]
		task.YieldPer(10000, "progress")
	end

	for k, leaf in pairs( data[LUMP_LEAFS] or {} ) do
		leaf.faces = {}
		for i = leaf.firstleafface+1, leaf.firstleafface + leaf.numleaffaces do
			table.insert( leaf.faces, data[LUMP_LEAFFACES] and data[LUMP_LEAFFACES][i] )
			task.YieldPer(10000, "progress")
		end

		leaf.brushes = {}
		for i = leaf.firstleafbrush+1, leaf.firstleafbrush + leaf.numleafbrushes do
			table.insert( leaf.brushes, data[LUMP_LEAFBRUSHES] and data[LUMP_LEAFBRUSHES][i] )
			task.YieldPer(10000, "progress")
		end

		leaf.mins = Vector(leaf.mins[1], leaf.mins[2], leaf.mins[3])
		leaf.maxs = Vector(leaf.maxs[1], leaf.maxs[2], leaf.maxs[3])
	end

	for k, side in pairs( data[LUMP_BRUSHSIDES] or {} ) do
		side.plane = data[LUMP_PLANES] and data[LUMP_PLANES][side.planenum+1]
		side.planenum = nil

		side.texinfo = data[LUMP_TEXINFO] and data[LUMP_TEXINFO][side.texinfo+1]
		side.dispinfo = data[LUMP_DISPINFO] and data[LUMP_DISPINFO][side.dispinfo+1]
	end

	for k, brush in pairs( ( data[LUMP_BRUSHSIDES] and data[LUMP_BRUSHES] ) or {} ) do
		brush.sides = {}
		for i = brush.firstside+1, brush.firstside + brush.numsides do
			table.insert( brush.sides, data[LUMP_BRUSHSIDES][i] )
			task.YieldPer(10000, "progress")
		end
		brush.firstside = nil
		brush.numsides = nil
	end

	for _, lump in pairs( { data[LUMP_FACES], data[LUMP_ORIGINALFACES] }) do
	for k, face in pairs( lump ) do
		face.plane = data[LUMP_PLANES] and data[LUMP_PLANES][face.planenum+1]
		face.planenum = nil
		face.edges = {}
		for i = face.firstedge+1, face.firstedge + face.numedges do
			table.insert( face.edges, data[LUMP_SURFEDGES] and data[LUMP_SURFEDGES][i] )
			task.YieldPer(10000, "progress")
		end

		face.texinfo = data[LUMP_TEXINFO] and data[LUMP_TEXINFO][face.texinfo+1]
		face.dispinfo = data[LUMP_DISPINFO] and data[LUMP_DISPINFO][face.dispinfo+1]
		face.origFace = data[LUMP_ORIGINALFACES] and data[LUMP_ORIGINALFACES][face.origFace+1]
		face.primitives = {}
		for i = face.firstPrimID+1, face.firstPrimID + face.numPrims do
			table.insert( face.edges, data[LUMP_PRIMITIVES] and data[LUMP_PRIMITIVES][i] )
			task.YieldPer(10000, "progress")
		end		
	end
	end

	for k, model in pairs( data[LUMP_MODELS] or {} ) do
		model.headnode = data[LUMP_NODES] and data[LUMP_NODES][model.headnode+1]
		model.faces = {}
		for i = model.firstface+1, model.firstface + model.numfaces do
			table.insert( model.faces, facelist and facelist[i] )
			task.YieldPer(10000, "progress")
		end
	end

	data.planes = data[LUMP_PLANES]
	data.verts = data[LUMP_VERTEXES]
	data.brushes = data[LUMP_BRUSHES]
	data.edges = data[LUMP_SURFEDGES]
	data.faces = data[LUMP_FACES]
	data.nodes = data[LUMP_NODES]
	data.leafs = data[LUMP_LEAFS]
	data.models = data[LUMP_MODELS]
	data.props = data[LUMP_GAME_LUMP] and data[LUMP_GAME_LUMP].props

end )

AddProcess( "Converting Brushes", function( data )

	local out = {}
	for k, orig in pairs( data[LUMP_BRUSHES] or {} ) do

		local newbrush = brush.Brush()
		newbrush.contents = orig.contents

		for i, origside in pairs( orig.sides ) do
			local side = brush.Side( origside.plane.back )
			side.texinfo = origside.texinfo
			side.bevel = origside.bevel != 0
			newbrush:Add( side )
			task.YieldPer(10000, "progress")
		end

		newbrush.center = (newbrush.min + newbrush.max) / 2
		table.insert( out, newbrush )

	end

	data[LUMP_BRUSHES] = out
	data.brushes = out
	return out

end )

AddProcess( "Converting Entities", function( data )

	local function ProcessKeyValue(t, k, v)
		if k == "origin" then
			local x,y,z = string.match( tostring(v), "([%+%-]?%d*%.?%d+) ([%+%-]?%d*%.?%d+) ([%+%-]?%d*%.?%d+)" )
			if x and y and z then
				return Vector(x,y,z)
			else
				print("FAILED TO PARSE: " .. tostring(v))
				return Vector()
			end
		end
		if k == "angles" then
			local x,y,z = string.match( tostring(v), "([%+%-]?%d*%.?%d+) ([%+%-]?%d*%.?%d+) ([%+%-]?%d*%.?%d+)" )
			return Angle(x,y,z)
		end
		if k == "model" then
			if v[1] == "*" then
				local index = string.match( v, "(%d+)")
				local model = data.models[ index+1 ]
				if model then
					return model
				end
			end
		end
		if string.Left( k, 2 ) == "On" then
			t.outputs = t.outputs or {}
			table.insert( t.outputs, {k, v} )
			return nil
		end
		return v
	end

	local out = {}
	local kv = {}
	local obj = nil
	local buf = ""

	local str = data[LUMP_ENTITIES]
	local sm = statemachine.New()
	local sm2 = statemachine.New()

	local match = _T( function(ch, char) return ch == char end, 1 )
	local smstate = _T( function(ch, state) return sm._ == state end, 1 )

	sm.string.tick = function(ch) buf = buf .. ch end
	sm.string.exit = function(ch)
		table.insert( kv, buf )
		if #kv == 2 then obj[kv[1]] = ProcessKeyValue( obj, kv[1], kv[2] ) kv = {} end
		buf = ""
	end

	sm[sm.none .. sm.string] = match("\"")
	sm[sm.string .. sm.none] = match("\"")

	sm2.object.enter = function(ch) obj = {} end
	sm2.object.tick = function(ch) sm(ch) end
	sm2.object.exit = function(ch) table.insert( out, obj ) end
	sm2[sm2.none .. sm2.object] = match("{") - smstate( sm.string )
	sm2[sm2.object .. sm2.none] = match("}") - smstate( sm.string )

	for i=1, #str do 
		sm2(str[i]) 
		task.YieldPer(10000, "progress")
	end

	data[LUMP_ENTITIES] = out
	data.entities = out
	return out

end )



local meta = {}
meta.__index = meta

function meta:IsLoading()

	return self.__loading

end

local function LoadBSP( bsp, path, callback )

	local f = file.Open( "maps/" .. bsp .. ".bsp", "rb", path or "GAME" )
	local header = BSP.Header_t.read(f)
	local bspdata = setmetatable( { __loading = true }, meta )

	local function loadLump( lumpid )
		bspdata[lumpid] = BSP.Readers[lumpid]( f, header )
	end

	local function load()


		loadLump( LUMP_ENTITIES )				--All in-map entities
		loadLump( LUMP_PLANES )					--Plane equations for map geometry
		loadLump( LUMP_BRUSHES )				--Brushes
		loadLump( LUMP_BRUSHSIDES )				--Sides of brushes
		loadLump( LUMP_GAME_LUMP )				--Static props and detail props
		loadLump( LUMP_NODES )					--Spatial partitioning nodes
		loadLump( LUMP_LEAFS )					--Spatial partitioning leafs
		loadLump( LUMP_MODELS )					--Brush models (trigger_* / func_*)

		if CLIENT then

			loadLump( LUMP_VERTEXES )				--All vertices that make up map geometry
			loadLump( LUMP_EDGES )					--Edges between vertices in map geometry
			loadLump( LUMP_SURFEDGES )				--Indexing between vertices
			loadLump( LUMP_TEXDATA )				--Texture data (width / height / name)
			loadLump( LUMP_TEXINFO )				--Surface texture info
			loadLump( LUMP_TEXDATA_STRING_DATA )	--Names of textures
			--loadLump( LUMP_FACES )					--Poligonal faces
			loadLump( LUMP_ORIGINALFACES )			--Original poligonal faces before BSP splitting
			loadLump( LUMP_LEAFFACES )				--Indexing between leafs and faces
			loadLump( LUMP_LEAFBRUSHES )			--Indexing between leafs and bruches
			loadLump( LUMP_WORLDLIGHTS )			--Extended information for light_* entities
			loadLump( LUMP_CUBEMAPS )				--env_cubemap locations and sizes

		end


		if false then

			loadLump( LUMP_VISIBILITY )				--Visibility between leafs
			loadLump( LUMP_OVERLAYS )				--Overlays on surfaces
			loadLump( LUMP_AREAS )					--VVIS areas
			loadLump( LUMP_AREAPORTALS )			--VVIS areaportals
			loadLump( LUMP_DISPINFO )				--Displacement info
			loadLump( LUMP_DISP_VERTS )				--Displacement vertices
			loadLump( LUMP_OCCLUSION )				--Occlusion brushes
			loadLump( LUMP_FACEIDS )				--Hammer faceids
			loadLump( LUMP_VERTNORMALS )			--Vertex normals for smoothing groups in map
			loadLump( LUMP_VERTNORMALINDICES )		--Indexing between vertices and vertex normals
			loadLump( LUMP_LEAFWATERDATA )			--Surface-z and bottom-z for water brushes
			--loadLump( LUMP_LIGHTING )				--Lightmaps

		end

		for _, process in pairs( processes ) do
			task.Yield("chunk", process.name, 0)
			local b,e = pcall( process.func, bspdata )
			if not b then print(e) end
			task.Yield("chunkdone", process.name, 0, e)
		end

		bspdata.__loading = false
		if callback then 
			local b,e = pcall(callback, bspdata) 
			if not b then print(e) end
		end

		if CLIENT then

			--[[for k,v in pairs( bspdata.entities ) do
				if string.find( v.classname or "", "func_button" ) then
					print( v.classname )
					for i, j in pairs( v ) do
						if i ~= "classname" then
							print("\t" .. i .. " = " .. tostring( j ))

							if i == "model" and type(j) == "table" then
								print("\tMODEL:")
								--PrintTable(j)
							end
						end
					end
				end
			end]]

		end

	end

	local t = task.New( load, 1 )
	function t:chunk( name, count )
		Msg("LOADING: " .. string.upper(name) .. " : " .. count .. " " )
	end

	function t:progress()
		Msg(".")
	end

	function t:chunkdone( name, count, tab )
		Msg("DONE\n")
	end

	return bspdata

end

if SERVER then
	--LoadBSP(game.GetMap())
end

--_G["LOADED_BSP"] = nil
_G["LOADED_BSP"] = _G["LOADED_BSP"] or LoadBSP( game.GetMap(), nil, function()

	hook.Call( "CurrentBSPReady" )

end )

local current_map = _G["LOADED_BSP"]

function GetCurrent()

	return current_map

end