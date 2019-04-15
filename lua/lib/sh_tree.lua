if SERVER then AddCSLuaFile("sh_tree.lua") end
if SERVER then return end

if true then return end

local boxes = {}

local axis = {
	Vector(1,0,0),
	Vector(0,1,0),
	Vector(0,0,1),
	Vector(-1,0,0),
	Vector(0,-1,0),
	Vector(0,0,-1)
}

local function rv() return math.floor( math.random(-1000,1000) / 10 ) * 10 end

for i=1, 100 do

	local p = Vector(rv(), rv(), rv())
	local v0 = p + Vector( math.random(10,160), math.random(10,160), math.random(10,160) )
	local v1 = p - Vector( math.random(10,160), math.random(10,160), math.random(10,160) )
	OrderVectors( v0, v1 )
	table.insert( boxes, { v0, v1, HSVToColor((i/30)*180, 1, 1) } )

end

local vecs = {}
local function gvec(i,x,y,z)
	vecs[i] = vecs[i] or Vector()
	vecs[i].x = x
	vecs[i].y = y
	vecs[i].z = z
	return vecs[i]
end

local quads = {}
local function quad(i)
	if not quads[i] then
		quads[i] = poly.Winding()
		quads[i].points = { 0,0,0,0 }
	end
	return quads[i]
end

local function BoxPolygons( polylist, box, i )

	local v111 = gvec( i*8 + 0, box[1].x, box[1].y, box[1].z )
	local v112 = gvec( i*8 + 1, box[1].x, box[1].y, box[2].z )
	local v121 = gvec( i*8 + 2, box[1].x, box[2].y, box[1].z )
	local v122 = gvec( i*8 + 3, box[1].x, box[2].y, box[2].z )
	local v211 = gvec( i*8 + 4, box[2].x, box[1].y, box[1].z )
	local v212 = gvec( i*8 + 5, box[2].x, box[1].y, box[2].z )
	local v221 = gvec( i*8 + 6, box[2].x, box[2].y, box[1].z )
	local v222 = gvec( i*8 + 7, box[2].x, box[2].y, box[2].z )

	local w = quad( i*6 + 0 )
	w.points[1] = v111
	w.points[2] = v112
	w.points[3] = v122
	w.points[4] = v121
	w.box = i
	w.plane = Plane( axis[1], box[1][1] )
	table.insert( polylist, w )

	local w = quad( i*6 + 1 )
	w.points[1] = v111
	w.points[2] = v211
	w.points[3] = v212
	w.points[4] = v112
	w.box = i
	w.plane = Plane( axis[2], box[1][2] )
	table.insert( polylist, w )

	local w = quad( i*6 + 2 )
	w.points[1] = v111
	w.points[2] = v121
	w.points[3] = v221
	w.points[4] = v211
	w.box = i
	w.plane = Plane( axis[3], box[1][3] )
	table.insert( polylist, w )

	local w = quad( i*6 + 3 )
	w.points[1] = v221
	w.points[2] = v222
	w.points[3] = v212
	w.points[4] = v211
	w.box = i
	w.plane = Plane( axis[4], -box[2][1] )
	table.insert( polylist, w )

	local w = quad( i*6 + 4 )
	w.points[1] = v122
	w.points[2] = v222
	w.points[3] = v221
	w.points[4] = v121
	w.box = i
	w.plane = Plane( axis[5], -box[2][2] )
	table.insert( polylist, w )

	local w = quad( i*6 + 5 )
	w.points[1] = v212
	w.points[2] = v222
	w.points[3] = v122
	w.points[4] = v112
	w.box = i
	w.plane = Plane( axis[6], -box[2][3] )
	table.insert( polylist, w )

end

local function Polygons( boxlist )

	local polygons = {}
	for i=1, #boxlist do
		BoxPolygons( polygons, boxlist[i], i )
	end
	return polygons

end

function ProcessPolygons( polygons )

	local p = polygons[#polygons]
	table.remove(polygons, #polygons)

	local n = {
		polylist = { p },
		split = p.plane,
		left = nil,
		right = nil,
	}

	if #polygons == 0 then return n end

	local lp = nil
	local rp = nil
	for _, p in pairs( polygons ) do
		local s = p:PlaneSide( n.split )
		if s == poly.SIDE_BACK then
			lp = lp or {}
			table.insert( lp, p )
		elseif s == poly.SIDE_FRONT then
			rp = rp or {}
			table.insert( rp, p )
		elseif s == poly.SIDE_ON then
			table.insert( n.polylist, p )
		elseif s == poly.SIDE_CROSS then

			local front, back = p:Split( n.split )
			if back then lp = lp or {} table.insert( lp, back ) back.plane = p.plane back.box = p.box end
			if front then rp = rp or {} table.insert( rp, front ) front.plane = p.plane front.box = p.box end
		end
	end

	n.left = lp and ProcessPolygons( lp )
	n.right = rp and ProcessPolygons( rp )

	return n

end

local drawcount = 0

local function DrawPolygons( l )
	render.SetColorMaterial()

	for k,v in pairs(l) do
		--v:Render( v.box == 1 and Color(255,drawcount,drawcount) or Color(drawcount,255,drawcount) )

		if #v.points == 4 then
			local d,c,b,a = unpack(v.points)
			render.DrawQuad( a,b,c,d, boxes[v.box][3]  )
			--render.DrawLine( a, b, boxes[v.box][3] )
			--render.DrawLine( b, c, boxes[v.box][3] )
			--render.DrawLine( c, d, boxes[v.box][3] )
			--render.DrawLine( d, a, boxes[v.box][3] )
		end

		drawcount = drawcount + 1
	end

end

local function DrawNode( p, node )

	if node == nil then return end
	if node.left == nil and node.right == nil then
		DrawPolygons( node.polylist )
		return
	end

	local d = p:Dot( node.split.normal ) - node.split.dist

	if d > 0 then DrawNode( p, node.left ) else DrawNode( p, node.right ) end
	DrawPolygons( node.polylist )
	if d <= 0 then DrawNode( p, node.left ) else DrawNode( p, node.right ) end

end

--PrintTable( tree )

hook.Add( "HUDPaint", "dbgtree", function()

	if true then return end

	cam.Start3D()
	local tree = ProcessPolygons( Polygons( boxes ) )
	drawcount = 0
	DrawNode( LocalPlayer():EyePos(), tree )
	cam.End3D()

end)

hook.Add( "PostDrawOpaqueRenderables", "dbgtree", function( bdepth, bsky )

end)