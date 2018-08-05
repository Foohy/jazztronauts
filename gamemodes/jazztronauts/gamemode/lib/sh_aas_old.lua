if SERVER then AddCSLuaFile("sh_aas.lua") end
if SERVER then return end

local bspdata = bsp.Get( "maps/" .. game.GetMap() .. ".bsp" )

local function BuildTree( node, windings, planes )

	local front = {}
	local back = {}
	for k,v in pairs( windings ) do
		local side = v:PlaneSide( node.plane )
		if side == poly.SIDE_ON then
			--print("ON")
			table.insert( front, v )
			table.insert( back, v )
		elseif side == poly.SIDE_BACK then
			table.insert( back, v )
		elseif side == poly.SIDE_FRONT then
			table.insert( front, v )
		elseif side == poly.SIDE_CROSS then
			local f, b = v:Split( node.plane )
			table.insert( front, f )
			table.insert( back, b )
		end
	end

	print("Tree ITER: " .. #front .. ", " .. #back .. ", " .. #windings )

	task.Yield()

	planes = table.Copy(planes)
	table.remove(planes, 1)

	if #planes == 0 then return end

	if #front > 0 then
		node.front = { plane = planes[1] }
		BuildTree( node.front, front, planes )
	end
	if #back > 0 then
		node.back =  { plane = planes[1].back }

		if #front == 0 then
			node.back.faces = back
			node.back.color = Color(math.random(0,255), math.random(0,255), math.random(0,255))
			return
		end

		BuildTree( node.back, back, planes )
	end

end

local function BuildTree2( node, inbrush, planes, lvl )

	lvl = lvl or 1
	print("ITER2: " .. lvl)

	planes = table.Copy(planes)
	table.remove(planes, 1)
	if #planes == 0 then

		node.brush = inbrush
		node.color = Color(255,0,0)

		return
	end

	local side = inbrush:PlaneSide( node.plane )
	local front, back = inbrush:Split( node.plane )

	if front then
		if not back then
			node.brush = front
			node.color = Color(255,0,0)
			return
		end

		node.front = { plane = planes[1] }
		BuildTree2( node.front, front, planes, lvl + 1 )
	end
	if back then
		node.back =  { plane = planes[1] }
		BuildTree2( node.back, back, planes, lvl + 1 )
	end

	task.Yield()

end

local g_stop = 0

local function IterateTree( node, ctrl )
	ctrl = ctrl or { stop = 0 }

	local pos = LocalPlayer():GetPos()
	local cl = node.plane.normal:Dot( pos ) - node.plane.dist

	if node.faces and #node.faces > 0 then
		if ctrl.stop == g_stop or true then
			for k,v in pairs(node.faces) do
				v:Render( node.color, false )
			end
		end
		ctrl.stop = ctrl.stop + 1
	end

	if node.front then
		IterateTree( node.front, ctrl )
	end

	if node.back then
		IterateTree( node.back, ctrl )
	end


end

local function IterateTree2( node, ctrl )
	ctrl = ctrl or { stop = 0 }

	local pos = LocalPlayer():GetPos()
	local cl = node.plane.normal:Dot( pos ) - node.plane.dist

	if node.brush then
		if ctrl.stop == g_stop or true then
			node.brush:Render( node.color, false )
		end
		ctrl.stop = ctrl.stop + 1
	end

	if node.front then
		IterateTree2( node.front, ctrl )
	end

	if node.back then
		IterateTree2( node.back, ctrl )
	end


end

local function AddUniquePlane( planes, plane )

	--[[for k,v in pairs( planes ) do
		if v.normal:Dot( plane.normal ) > .99 and math.abs( v.dist - plane.dist ) < 0.01 then
			return false
		end
	end]]

	table.insert( planes, plane )

end

local function MakePolygons( work, bsp )

	work.brushes = {}
	work.windings = {}


	local planes = {}

	--for _, origbrush in pairs( bsp.brushes ) do
	for i=1, 1 do
		origbrush = bsp.brushes[i]
		local newbrush = brush.Brush()

		for _, origside in pairs( origbrush.sides ) do
			local side = brush.Side( origside.plane.back )
			newbrush:Add( side )
		end
		newbrush:CreateWindings()

		for _, side in pairs(newbrush.sides) do
			table.insert( work.windings, poly.BaseWinding( side.winding:Plane() ) )
			--table.insert( planes, side.winding:Plane() )
			AddUniquePlane( planes, side.winding:Plane() )
		end

		table.insert( work.brushes, newbrush )
	end

	local node = {
		plane = planes[1]
	}

	local node2 = {
		plane = planes[1]
	}

	local rootBrush = brush.Brush():CreateFromAABB( Vector(-6000,-6000,-6000), Vector(6000,6000,6000) )

	--BuildTree( node, work.windings, planes )
	BuildTree2( node2, rootBrush, planes )

	work.tree = node
	work.tree2 = node2


	--[[local w = poly.BaseWinding( origbrush.sides[1].plane )
	w:Clip( origbrush.sides[3].plane.back )
	w:Clip( origbrush.sides[4].plane.back )

	table.insert( work.windings, w )]]

	task.Yield("windingsReady", work)

end

local function BuildReverseBSP( work, bsp )
	MakePolygons( work, bsp )
	print("Reverse BSP")
end

local function load()

	--print("Loading: " .. bsp:GetName())
	bspdata:LoadBrushes()

	local work = {}
	BuildReverseBSP( work, bspdata )

	return work

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

function t:windingsReady( work )

	print("Windings are ready, draw them")
	hook.Add( "PostDrawOpaqueRenderables", "DrawBrushWindings", function(depth, sky)

		--[[for k,v in pairs(work.windings) do
			v:Render( Color(255,0,255), false )
		end]]

		--IterateTree( work.tree )
		IterateTree2( work.tree2 )

	end )

end

hook.Add( "KeyPress", "AdvanceStop", function( ply, key )
	if ( key == IN_USE ) then
		g_stop = g_stop + 1
	end
end )