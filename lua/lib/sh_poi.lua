AddCSLuaFile()

if SERVER then return end

print("POI")

local map = bsp2.GetCurrent()

local function tabulate( str, depth )
	for i=1, depth do
		str = "\t" .. str
	end
	return str
end

local function CopyLeafList( portal )

	local leafs = {}
	for k,v in pairs( portal.leafs ) do
		table.insert( leafs, v )
	end
	return leafs

end

local function ClipPortal( portal, node, list, depth )

	depth = depth or 0

	local function checkLeaf(l)
		return bit.band(l.contents, CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_DETAIL + CONTENTS_PLAYERCLIP) == 0
	end

	if node.is_leaf then
		if checkLeaf( node ) then
			portal.leafs[#portal.leafs+1] = node
			list[#list+1] = portal
		end
		return
	end

	local front = node.children[1]
	local back = node.children[2]

	local side = portal:PlaneSide( node.plane )
	if side == poly.SIDE_ON then

		local frontlist = {}

		ClipPortal( portal, front, frontlist, depth + 1 )
		for _, p in pairs( frontlist ) do
			ClipPortal( p, back, list, depth + 1 )
		end

	elseif side == poly.SIDE_FRONT then

		ClipPortal( portal, front, list, depth + 1 )

	elseif side == poly.SIDE_BACK then

		ClipPortal( portal, back, list, depth + 1 )

	else

		local pfront, pback = portal:Split( node.plane, nil, true )
		pfront.leafs = CopyLeafList(portal)
		pback.leafs = CopyLeafList(portal)

		ClipPortal( pfront, front, list, depth + 1 )
		ClipPortal( pback, back, list, depth + 1 )

	end

end

function GetAllSubNodes( node, list )

	task.YieldPer(800)
	if node.is_leaf then return end
	list[#list+1] = node
	GetAllSubNodes( node.children[1], list )
	GetAllSubNodes( node.children[2], list )

end

function BuildPortals()

	loadicon.PushLoadState("Portal Generation")
	if map:IsLoading() then
		task.Await( map:GetLoadTask() )
	end

	--if map.leafs[1].portals ~= nil then return true end

	--task.Sleep(1)
	MsgC(Color(50,190,255), "Building Portals")

	for k,v in pairs( map.leafs ) do v.portals = {} end

	local nodes = {}
	GetAllSubNodes( map.models[1].headnode, nodes )

	local count = #nodes
	for k, node in pairs( nodes ) do

		task.Yield("progress", k, count)

		local portal = poly.BaseWinding(node.plane)
		portal.leafs = {}

		local fragments = {}
		ClipPortal( portal, map.models[1].headnode, fragments )
		for _, v in pairs( fragments ) do
			if #v.leafs >= 2 then
				for _, l in pairs( v.leafs ) do
					l.portals[#l.portals+1] = v
				end
			end
		end

		--task.YieldPer(1000)

	end

	MsgC(Color(50,190,255), "Done\n")
	loadicon.PopLoadState()

end

if true then return end

local portalvis = task.New( BuildPortals, 1 )

function portalvis:progress(num, count)
	loadicon.SetLoadState( ("%i/%i"):format(num, count) )
end

local function FindLeaf( pos, node )

	node = node or map.models[1].headnode
	if node.is_leaf then return node end

	local d = node.plane.normal:Dot( pos ) - node.plane.dist

	if d > 0 then

		return FindLeaf( pos, node.children[1] )

	else

		return FindLeaf( pos, node.children[2] )

	end

end

local function AreLeafsAdjacent(a, b)

	for k,v in pairs( a.portals ) do
		if v.leafs[1] == b or v.leafs[2] == b then return true end
	end
	return false

end

local function AreLeafsConnected(a, b, visited)

	visited = visited or {}
	visited[a] = true

	if AreLeafsAdjacent(a,b) then return true end

	local connection = false

	for k,v in pairs( a.portals ) do

		for _, l in pairs( v.leafs ) do
			if l == a then continue end

			if not visited[l] then
				connection = connection or AreLeafsConnected(l, b, visited)
			end
		end

	end

	return connection

end

local function RenderLeafPortals( leaf )

	for k,v in pairs( leaf.portals or {} ) do
		v:Render(Color(255,255,100))
	end

end

--[[for k,v in pairs( ents.FindByClass("jazz_shard") ) do

	v.leaf = FindLeaf( v:GetPos() )

end]]

local non_sky_renders = false
hook.Add("PostDrawOpaqueRenderables", "render_leaf_test", function( depth, sky )

	--if not sky then non_sky_renders = true end
	--if sky and non_sky_renders then return end

	if not portalvis:IsFinished() then return end
	--print("DRAW DA LEAFS")

	local leaf = FindLeaf( LocalPlayer():GetPos() )

	--[[local count = 0
	for k,v in pairs( ents.FindByClass("jazz_shard") ) do

		if not AreLeafsConnected( v.leaf, leaf ) then
			count = count + 1
		end

	end
	print(count .. " shards are not obtainable by the player, they are in disconnected leafs!")]]


	--[[for k,v in pairs( leaf.portals ) do
		for _, l in pairs( v.leafs ) do
			RenderLeafPortals( l )
		end
	end]]

	for k,v in pairs( leaf.portals or {} ) do
		v:Render(#v.leafs > 2 and Color(255,255,100) or Color(100,255,100))
	end

end)