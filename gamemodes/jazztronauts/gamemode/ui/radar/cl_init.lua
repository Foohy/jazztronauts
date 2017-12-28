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