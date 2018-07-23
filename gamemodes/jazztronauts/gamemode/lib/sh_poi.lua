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

local function ClipPortal( portal, node, depth )
	depth = depth or 0

	local front = node.children[1]
	local back = node.children[2]
	local function checkLeaf(l)
		return bit.band(l.contents, CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_DETAIL + CONTENTS_PLAYERCLIP) == 0
	end

	task.YieldPer(800, "progress")

	local side = portal:PlaneSide( node.plane )
	if side == poly.SIDE_ON then

		local frontlist = {}
		local backlist = {}

		if front.is_leaf then
			if checkLeaf( front ) then
				portal.leafs[#portal.leafs+1] = front
				frontlist = {portal}
			end
		else
			for _, v in pairs( ClipPortal( portal, front, depth + 1 ) ) do
				frontlist[#frontlist+1] = v
			end
		end

		for _, p in pairs( frontlist ) do

			if back.is_leaf then
				if checkLeaf( back ) then
					p.leafs[#p.leafs+1] = back
					backlist[#backlist+1] = p
				end
			else
				for _, v in pairs( ClipPortal( p, back, depth + 1 ) ) do 
					backlist[#backlist+1] = v 
				end
			end

		end

		return backlist


	elseif side == poly.SIDE_FRONT then

		if front.is_leaf then
			if checkLeaf( front ) then
				portal.leafs[#portal.leafs+1] = front
				return {portal}
			end
			return {}
		else
			return ClipPortal( portal, front, depth + 1 )
		end

	elseif side == poly.SIDE_BACK then

		if back.is_leaf then
			if checkLeaf( back ) then
				portal.leafs[#portal.leafs+1] = back
				return {portal}
			end
			return {}
		else
			return ClipPortal( portal, back, depth + 1 )
		end

	else

		local wfront, wback = portal:Split( node.plane, nil, true )
		wfront.leafs = CopyLeafList(portal)
		wback.leafs = CopyLeafList(portal)

		local res = {}
		if front.is_leaf then
			if checkLeaf( front ) then
				wfront.leafs[#wfront.leafs+1] = front
				res = {wfront}
			end
		else
			res = ClipPortal( wfront, front, depth + 1 )
		end

		if back.is_leaf then
			if checkLeaf( back ) then
				wback.leafs[#wback.leafs+1] = back
				res[#res+1] = wback
			end
		else
			for _, p in pairs( ClipPortal( wback, back, depth + 1 ) ) do
				res[#res+1] = p
			end
		end
		return res

	end

end

function BuildPortals()

	task.Sleep(1)
	MsgC(Color(50,190,255), "Building Portals")

	for k,v in pairs( map.leafs ) do
		v.portals = {}
	end

	for _, node in pairs( map.nodes ) do

		local portal = poly.BaseWinding(node.plane)
		portal.leafs = {}

		for _, v in pairs( ClipPortal( portal, map.models[1].headnode ) ) do
			if #v.leafs >= 2 then
				for _, l in pairs( v.leafs ) do
					table.insert( l.portals, v )
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

hook.Add("PostDrawOpaqueRenderables", "poi", function( depth, sky )

	--if sky then return end

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