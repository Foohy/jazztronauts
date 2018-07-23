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

	task.YieldPer(800, "progress")

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

	task.YieldPer(800, "progress")
	if node.is_leaf then return end
	list[#list+1] = node
	GetAllSubNodes( node.children[1], list )
	GetAllSubNodes( node.children[2], list )

end

function BuildPortals()

	task.Sleep(1)
	MsgC(Color(50,190,255), "Building Portals")

	for k,v in pairs( map.leafs ) do v.portals = {} end

	local nodes = {}
	GetAllSubNodes( map.models[1].headnode, nodes )

	for _, node in pairs( nodes ) do

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

	end

	MsgC(Color(50,190,255), "Done\n")

end

if true then return end

local portalvis = task.New( BuildPortals, 1 )

function portalvis:progress()
	MsgC(Color(50,190,255), ".")
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

print("***FINISHED PORTAL CLIP***")

local function RenderLeafPortals( leaf )

	for k,v in pairs( leaf.portals or {} ) do
		v:Render(Color(255,255,100))
	end

end

local non_sky_renders = false
hook.Add("PostDrawOpaqueRenderables", "poi", function( depth, sky )

	if not sky then non_sky_renders = true end
	if sky and non_sky_renders then return end

	if not portalvis:IsFinished() then return end

	local leaf = FindLeaf( EyePos() )

	--[[for k,v in pairs( leaf.portals ) do
		for _, l in pairs( v.leafs ) do
			RenderLeafPortals( l )
		end
	end]]

	for k,v in pairs( leaf.portals ) do
		v:Render(#v.leafs > 2 and Color(255,255,100) or Color(100,255,100))
	end

end)