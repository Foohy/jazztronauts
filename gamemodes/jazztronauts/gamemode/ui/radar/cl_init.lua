include("shared.lua")

module( "radar", package.seeall )

local settings = {
	width = 80,
	height = 80,
	dock = DOCK_TOP + DOCK_RIGHT,
	zoom = .05,
	grid_spacing_multiplier = 16,
}

local matrix = {
	1, 0, 0,
	0, 1, 0,
}

local inverse = {
	1, 0, 0,
	0, 1, 0,
}

function Transform(x,y)

	return x * matrix[1] + y * matrix[2] + matrix[3], x * matrix[4] + y * matrix[5] + matrix[6]

end

function Transform3D(vec)

	return Transform(vec.x, -vec.y)

end

function Transform3DV(vec, out)

	local x,y = Transform(vec.x, -vec.y)
	if out then
		out.x = x
		out.y = y
		out.z = 0
	end
	return out or Vector(x,y,0)

end

function InvTransform(x,y)

	return x * inverse[1] + y * inverse[2] + inverse[3], x * inverse[4] + y * inverse[5] + inverse[6]

end

local function Transform2(x0,y0,x1,y1)

	local a,b = Transform(x0,y0)
	local c,d = Transform(x1,y1)
	return a,b,c,d

end

local function UpdateMatrix(x,y,rotation,scale,offsetx,offsety)

	rotation = math.rad(rotation)
	local cos = math.cos(rotation)
	local sin = math.sin(rotation)

	matrix[1] = cos * scale
	matrix[2] = -sin * scale
	matrix[3] = -x * matrix[1] + y * matrix[2] + offsetx
	matrix[4] = sin * scale
	matrix[5] = cos * scale
	matrix[6] = -x * matrix[4] + y * matrix[5] + offsety

	inverse[1] = cos / scale
	inverse[2] = sin / scale
	inverse[3] = x - offsetx * inverse[1] - offsety * inverse[2]
	inverse[4] = -sin / scale
	inverse[5] = cos / scale
	inverse[6] = -y - offsetx * inverse[4] - offsety * inverse[5]

end

local root2 = math.sqrt(2)
local function DrawGrid(rect, spacing, numbers)

	spacing = math.max(spacing or 50, 10)

	local width, height = rect:GetSize()
	local diagonal = math.sqrt( width * height ) / settings.zoom
	local needed = math.floor( (1 / spacing) * (diagonal / root2) )

	local cx, cy = rect:GetCenter()
	local lx, ly = InvTransform( cx, cy )

	lx = math.floor( lx / spacing ) * spacing
	ly = math.floor( ly / spacing ) * spacing

	for i=-needed, needed+1 do

		surface.DrawLine( Transform2(i*spacing + lx, -50000, i*spacing + lx, 50000) )
		surface.DrawLine( Transform2(-50000, i*spacing + ly, 50000, i*spacing + ly) )

		if numbers then

			for j=-needed, needed+1 do

				surface.SetFont( "default" )
				surface.SetTextPos( Transform(i*spacing + lx, j*spacing + ly) )
				surface.DrawText( tostring(i*spacing + lx) .. ", " .. (j*spacing + ly) )

			end
		end

	end

end

local heat = {}
local heat_tilesize = 2048
local heat_stepsize = 256
local heat_key_width = 65536
local heat_key_width2 = heat_key_width * 2

local function HeatKey(pos)

	local kx = math.Round(pos.x / heat_stepsize)
	local ky = math.Round(pos.y / heat_stepsize) * heat_key_width

	return kx + ky

end

local function AddHeat(pos, add)

	local k = HeatKey(pos)
	heat[k] = math.min( (heat[k] or 0) + add, 1 )

end

--5x5 convolution blur kernel
local function ConvolvedHeatSample( k )

	local h0 = ( heat[ k ] or 0 ) * 16
	local h1 = ( heat[ k - 1 ] or 0 ) * 8
	local h2 = ( heat[ k + 1 ] or 0 ) * 8
	local h3 = ( heat[ k - heat_key_width ] or 0 ) * 8
	local h4 = ( heat[ k + heat_key_width ] or 0 ) * 8
	local h5 = ( heat[ k - heat_key_width - 1 ] or 0 ) * 4
	local h6 = ( heat[ k - heat_key_width + 1 ] or 0 ) * 4
	local h7 = ( heat[ k + heat_key_width - 1 ] or 0 ) * 4
	local h8 = ( heat[ k + heat_key_width + 1 ] or 0 ) * 4
	local h9 = ( heat[ k - 2 ] or 0 ) * 2
	local h10 = ( heat[ k + 2 ] or 0 ) * 2
	local h11 = ( heat[ k - heat_key_width2 ] or 0 ) * 2
	local h12 = ( heat[ k + heat_key_width2 ] or 0 ) * 2
	local h13 = ( heat[ k - heat_key_width - 2 ] or 0 )
	local h14 = ( heat[ k - heat_key_width + 2 ] or 0 )
	local h15 = ( heat[ k + heat_key_width - 2 ] or 0 )
	local h16 = ( heat[ k + heat_key_width + 2 ] or 0 )
	local h17 = ( heat[ k - heat_key_width2 - 1 ] or 0 )
	local h18 = ( heat[ k - heat_key_width2 + 1 ] or 0 )
	local h19 = ( heat[ k + heat_key_width2 - 1 ] or 0 )
	local h20 = ( heat[ k + heat_key_width2 + 1 ] or 0 )

	local r0 = h0+h1+h2+h3+h4
	local r1 = h5+h6+h7+h8+h9
	local r2 = h10+h11+h12+h13+h14
	local r3 = h15+h16+h17+h18+h19

	return (r0+r1+r2+r3+h20) * 0.0125

end

local function SampleColor(pos)

	local k = HeatKey(pos)
	local sum = ConvolvedHeatSample(k)
	--local sum = heat[ k ] or 0

	local c = HSVToColor( sum * sum * 40, 1, math.min( sum*2, 1 ) )

	return c.r, c.g, c.b,255

end

local _cvec = {}
local function CVec(id, x,y,z)

	local v = _cvec[id] or Vector(0,0,0)
	v.x = x or 0
	v.y = y or 0
	v.z = z or 0
	_cvec[id] = v
	return v

end

local mat = Material( "color" )
--local mat = Material( "editor/wireframe" )
local function DrawHeatTile(x, y)

	local size = heat_tilesize
	local step = heat_stepsize
	local strips = size / step
	local startx = x
	local starty = y
	local endx = startx + size
	local endy = starty + size

	render.SetMaterial( mat )

	for y = starty, endy, step do

		if y == endy then break end

		mesh.Begin(MATERIAL_TRIANGLE_STRIP, (strips+1) * 4)

		for x = startx, endx, step do

			if x == endx then break end

			local wv0 = CVec(1, x,y,0)
			local wv1 = CVec(2, x,y+step,0)
			local wv2 = CVec(3, x+step,y,0)
			local wv3 = CVec(4, x+step,y+step,0)

			local v0 = Transform3DV( wv0, CVec(5) )
			local v1 = Transform3DV( wv1, CVec(6) )
			local v2 = Transform3DV( wv2, CVec(7) )
			local v3 = Transform3DV( wv3, CVec(8) )

			local b,e = pcall( function()

				mesh.Position( v0 )
				mesh.Color( SampleColor(wv0) )
				mesh.AdvanceVertex()
				mesh.Position( v1 )
				mesh.Color( SampleColor(wv1) )
				mesh.AdvanceVertex()
				mesh.Position( v2 )
				mesh.Color( SampleColor(wv2) )
				mesh.AdvanceVertex()
				mesh.Position( v3 )
				mesh.Color( SampleColor(wv3) )
				mesh.AdvanceVertex()

			end)
			if not b then print(e) end

		end

		mesh.End()

	end

end

local function DrawHeatMap()

	local pos = LocalPlayer():GetPos()
	local cx = math.floor( pos.x / heat_tilesize ) * heat_tilesize
	local cy = math.floor( pos.y / heat_tilesize ) * heat_tilesize

	for y = -1, 1 do
		for x = -1, 1 do
			DrawHeatTile(cx + x * heat_tilesize,cy + y * heat_tilesize)
		end
	end

	--[[surface.SetDrawColor( 255,255,255,100 )
	for k,v in pairs( history ) do

		if v.point then
			local x,y = Transform3D( v.point )
			surface.DrawRect( Rect(Box( x,y,x,y ):Inset(-3)):Unpack() )
		else
			local x0,y0 = Transform3D( v.v0 )
			local x1,y1 = Transform3D( v.v1 )
			surface.DrawLine(x0,y0,x1,y1)
		end

	end]]

end

local function NearestFindPosKey(pos, maxdist)

	maxdist = maxdist or 999999

	local dsqr = maxdist * maxdist
	local key = nil
	for i=#history, 1, -1 do
		local v = history[i]
		local cmp = nil
		if v.point then
			cmp = (v.point - pos):LengthSqr()
		else
			cmp = math.min( (v.v0 - pos):LengthSqr(), (v.v1 - pos):LengthSqr() )
		end
		if cmp < dsqr then
			dsqr = cmp
			key = i
		end
	end
	return key

end

local function HistoryPos(pos)

	local k = NearestFindPosKey(pos, 512)
	if k then
		local v = history[k]
		if not v.v0 then v.v0 = v.point v.v1 = v.point v.point = nil end
		local dir = v.v1 - v.v0
		local pv1 = Vector(v.v1)

		v.v1 = pos

		local break_off = false
		if dir:Dot(dir) > 0 then
			local newdir = (v.v1 - pv1)
			dir.z = 0
			newdir.z = 0

			dir:Normalize()
			newdir:Normalize()

			local adif = dir:Dot(newdir)
			if adif < math.cos( 25 * DEG_2_RAD ) then
				break_off = true
			end
		end

		local lensqr = (v.v0 - v.v1):LengthSqr()
		if break_off then --lensqr > 262144 or
			print("ADD: " .. #history)
			table.insert( history, {point = pos} )
		end
		return
	end

	table.insert( history, {point = pos} )

end

local function UpdateHistory()

	local ft = FrameTime()
	for k,v in pairs(player.GetAll()) do
		AddHeat( v:GetPos(), .25 * ft )
	end

	--[[for k,v in pairs(player.GetAll()) do
		HistoryPos( v:GetPos() )
	end]]

end

local colors = {
	Color(255,255,255),
	Color(255,80,80),
	Color(255,255,80),
	Color(80,255,80),
	Color(80,255,255),
	Color(80,80,255),
	Color(255,80,255),
}

local function PaintPlayers( rect )

	rect = Rect( rect:Inset(5) )

	local minx, miny = rect:GetMin()
	local maxx, maxy = rect:GetMax()

	for k,v in pairs( player.GetAll() ) do

		local x,y = Transform3D( v:GetPos() )
		local col = colors[((k-1) % #colors) + 1]

		x = math.Clamp(x, minx, maxx)
		y = math.Clamp(y, miny, maxy)

		surface.SetDrawColor( col.r,col.g,col.b,100 )
		surface.DrawRect( Rect(Box( x,y,x,y ):Inset(-3)):Unpack() )

		surface.SetFont( "default" )
		local tw, th = surface.GetTextSize( v:Nick() )
		if x + 8 + tw > maxx then
			x = x - tw - 16
		end

		surface.SetTextColor( col.r,col.g,col.b,100 )
		surface.SetTextPos( x+8,y-6 )
		surface.DrawText( v:Nick() )

	end

end

local function DoATeleport( where )
	net.Start( "teleportme" )
	net.WriteVector( where )
	net.SendToServer()
end

local show_rtest = false
local rtest = Vector(0,0,0)
local tpready = false
local mat = Material( "sprites/sent_ball" )
local function Render()

	if show_rtest then
		render.SetMaterial( mat )
		render.DrawQuadEasy( rtest, Vector( 1, 0, 0 ), 8, 1024, Color( 255, 255, 255, 200 ), 0 )
		render.DrawQuadEasy( rtest, Vector( 0, 1, 0 ), 8, 1024, Color( 255, 255, 255, 200 ), 0 )
		render.DrawQuadEasy( rtest, Vector( -1, 0, 0 ), 8, 1024, Color( 255, 255, 255, 200 ), 0 )
		render.DrawQuadEasy( rtest, Vector( 0, -1, 0 ), 8, 1024, Color( 255, 255, 255, 200 ), 0 )
		render.DrawQuadEasy( rtest, Vector( 0, 0, 1 ), 128, 128, Color( 255, 255, 255, 200 ), 0 )

		if input.IsMouseDown( MOUSE_RIGHT ) then
			if tpready then
				DoATeleport( rtest )
				tpready = false
			end
		else
			tpready = true
		end

	end

end
hook.Add("PostDrawOpaqueRenderables", "RadarTricks", Render)

function Paint()

	local screen = Rect("screen")
	local sub = Rect( 0, 0, settings.width, settings.height )

	UpdateHistory()

	sub:ScreenScale()
	sub:Inset(-12)
	sub:Dock( screen, settings.dock )
	sub:Inset(8)

	--move to make money unobscured
	if settings.dock == DOCK_TOP + DOCK_RIGHT then
		sub:Move( 0, 80 )
	end

	surface.SetDrawColor( 0,0,0,190 )
	surface.DrawRect(sub:Unpack())

	sub:Inset(4)

	local pos = LocalPlayer():GetPos()
	UpdateMatrix( pos.x, pos.y, EyeAngles().y - 90, settings.zoom, sub:GetCenter() )

	surface.SetDrawColor( 0,40,0,80 )
	surface.DrawRect( sub:Unpack() )

	render.SetScissorRect( Box(sub):Unpack(true) )

	--DrawHeatMap()

	surface.SetDrawColor( 20,180,20,20 )
	DrawGrid( sub, 32 * settings.grid_spacing_multiplier )

	surface.SetDrawColor( 20,180,20,40 )
	DrawGrid( sub, 128 * settings.grid_spacing_multiplier )

	surface.SetDrawColor( 80,255,20,40 )
	surface.SetTextColor( 120,255,80,50 )
	DrawGrid( sub, 512 * settings.grid_spacing_multiplier, false )

	PaintPlayers( sub )

	render.SetScissorRect( 0,0,0,0,false )


	local mx, my = gui.MousePos()

	show_rtest = false
	if sub:ContainsPoint( mx, my ) then

		show_rtest = true

		rtest.x, rtest.y = InvTransform( mx, my )
		rtest.y = -rtest.y
		rtest.z = LocalPlayer():GetPos().z + 32

		local hit = util.QuickTrace(rtest, Vector(0,0,1) * 99999, LocalPlayer())
		hit = util.QuickTrace(hit.HitPos, Vector(0,0,-1) * 99999, LocalPlayer())
		rtest = hit.HitPos + Vector(0,0,32)

	end

end