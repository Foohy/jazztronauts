
module( "propfeed", package.seeall )

surface.CreateFont( "PropFeed_Name", {
	font = "KG Shake it Off Chunky",
	extended = false,
	size = ScreenScale(12),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "PropFeed_Generic1", {
	font = "KG Shake it Off Chunky",
	extended = false,
	size = ScreenScale(10),
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "PropFeed_Numeric", {
	font = "KG Shake it Off Chunky",
	extended = false,
	size = ScreenScale(30),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local mat_color = Material( "color" )
local color_bgpanel1 = Color(47,39,51)
local color_bgpanel2 = Color(37,33,39)
local color_grad1 = Color(247,180,0)
local color_grad2 = Color(255,253,206)
local color_grad3 = Color(255,219,57)
local color_text_name1 = Color(228,183,86)
local color_text_name2 = Color(216,43,43)
local color_text_prop1 = Color(109,220,75)
local color_text_prop2 = Color(163,6,6)
local color_text_miamount_ssion1 = Color(190,166,115)
local color_text_miamount_ssion2 = Color(228,183,86)
local color_text_generic1 = Color(219,198,185)
local color_text_generic2 = Color(68,54,45)

local stops = {
	{-180, color_grad1},
	{-140, color_grad3},
	{-100, color_grad2},
	{-70, color_grad3},
	{-20, color_grad1},
	{0, color_grad1},
	{30, color_grad3},
	{100, color_grad2},
	{-180+400, color_grad1},
	{-140+400, color_grad3},
	{-100+400, color_grad2},
	{-70+400, color_grad3},
	{-20+400, color_grad1},
	{0+400, color_grad1},
	{30+400, color_grad3},
	{100+400, color_grad2},
}

local generic_gradient_rect = Rect(0,0,200,35):ScreenScale()
local m = CacheGradient( "stage0", generic_gradient_rect, -45, stops, 0, nil )
local text_irt = irt.New( "text_render", generic_gradient_rect:GetSize())
text_irt:SetAlphaBits(8)

function comma_value(amount)

	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	
	return formatted

end

local alpha_stops = {
	{40, Color(255,255,255,255)},
	{95, Color(255,255,255,90)},
	{150, Color(255,255,255,30)},
	{190, Color(255,255,255,0)}
}

local color_stops1 = {
	{40, MulAlpha(color_bgpanel1,1)},
	{92, MulAlpha(color_bgpanel1,.92)},
	{128, MulAlpha(color_bgpanel1,.78)},
	{170, MulAlpha(color_bgpanel1,.4)},
	{190, MulAlpha(color_bgpanel1,0)}
}

local blast_gradient = CacheGradient( "blast", generic_gradient_rect, 0, alpha_stops, 0 )

local function DrawPropEntry(item,x,y, dt, wanted, custom)

	if item == nil then
		item = {
			model = "some model",
			ply = LocalPlayer(),
			first_time = 0,
			time = 0,
			duration = 9999,
			worth = 0,
		}
	end

	wanted = wanted or item.wanted
	custom = custom or item.custom
	local name = "prop_name"
	local elapsed = item.elapsed
	local local_elapsed = CurTime() - item.time
	local dtx = 1 - dt
	local scroll = CurTime() - item.first_time
	local shift = -(math.max(dt, .5) - .5) * 1000
	local flash = (1 - math.min(local_elapsed * 4, 1) )

	local shake = (math.random(-10,10) * .75) * flash
	local zip = math.min(elapsed*5,1)
	local settle = math.min(elapsed*2, 1)
	x = x + shake

	local shake2 = (math.random(-10,10) * .5) * (1-settle*settle)
	y = y + shake2

	local rect = Rect(x,y,generic_gradient_rect.w,generic_gradient_rect.h)

	rect.h = rect.h * math.pow((1-math.cos(zip * math.pi/2)), 2)

	LinearGradientCached( "blast", Rect(rect):Inset(- ScreenScale(2)), Color(255,255,100 + flash * 155, flash * 255 ) )


	local a = CacheGradient( "stage0", Rect(0,0,200,35):ScreenScale(), -45 + math.sin(CurTime() * 4) * 20, stops, -math.fmod(scroll * 400, 400), nil )
	local b = CacheGradient( "stage1", Rect(0,0,200,35):ScreenScale(), -45 + math.cos(CurTime() * 4) * 20, stops, math.fmod(scroll * 400, 400) - 400, a )

	rect.h = rect.h * (1 - (math.max(dt, .8) - .8) * 5)

	if wanted then
		LinearGradient( rect, 0, alpha_stops, 0, b )
	else
		LinearGradient( rect, 0, color_stops1, 0 )
	end

	local left_align = ScreenScale(30)
	local top_align = ScreenScale(1)
	local text_alpha = 1

	
	if local_elapsed > item.duration - 1.2 then
		text_alpha = math.max( 1 - (local_elapsed - (item.duration - 1.2 ) ) * 5, 0 )
	end

	local tx = x + left_align
	surface.SetFont("PropFeed_Name")
	surface.SetTextColor( MulAlpha(wanted and color_text_generic2 or color_text_name1, text_alpha) )
	surface.SetTextPos( x+left_align,y+top_align )
	surface.DrawText( item.ply:Nick() )
	tx = tx + surface.GetTextSize( item.ply:Nick() ) + ScreenScale(2)

	surface.SetFont("PropFeed_Generic1")
	surface.SetTextColor( MulAlpha(wanted and color_text_generic2 or color_text_generic1, text_alpha) )
	surface.SetTextPos( tx,y+top_align+ScreenScale(2) )
	surface.DrawText( "FOUND" )
	tx = tx + surface.GetTextSize( "FOUND" ) + ScreenScale(2)

	surface.SetFont("PropFeed_Name")
	surface.SetTextColor( MulAlpha(wanted and color_text_prop2 or (custom and color_text_prop1 or color_text_name1), text_alpha) )
	surface.SetTextPos( tx,y+top_align )
	surface.DrawText( name )

	local count_text = "$" .. comma_value(item.worth)
	if item.count > 0 then
		count_text = count_text .. " x " .. item.count
		if item.count >= 25 then count_text = count_text .. "!!!" end
	end

	local amount_ss = ScreenScale(8)
	if not wanted then
		text_irt:Render( function()

			local oldx, oldy = rect.x, rect.y

			rect.x = 0
			rect.y = 0
			local oldW, oldH = ScrW(), ScrH()
			render.Clear( 255,0,0,0 )
			render.SetViewPort( rect:Unpack() )

			cam.Start2D()

			render.OverrideAlphaWriteEnable( true, true )
			render.OverrideColorWriteEnable( true, false )

			surface.SetFont("PropFeed_Numeric")
			surface.SetTextColor( MulAlpha(color_text_generic2, text_alpha) )
			surface.SetTextPos( left_align,amount_ss )
			surface.DrawText( count_text )

			render.OverrideAlphaWriteEnable( false )
			render.OverrideColorWriteEnable( false )

			LinearGradient( rect, 0, alpha_stops, 0, b )

			cam.End2D()
			render.SetViewPort( 0, 0, oldW, oldH )

			rect.x = oldx
			rect.y = oldy

		end )

		local mat = text_irt:GetUnlitMaterial(true,false,true,true)

		surface.SetMaterial( mat )
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(rect:Unpack())

	else
		surface.SetFont("PropFeed_Numeric")
		surface.SetTextColor( MulAlpha(color_text_generic2, text_alpha) )
		surface.SetTextPos( x+left_align,y+amount_ss )
		surface.DrawText( "$" .. comma_value(item.worth) .. "!!" )
	end

	LinearGradientCached( "blast", rect, Color(255,255,100 + flash * 155, flash * 120 ) )

	local sub = Rect( rect )
	sub:Inset( 4 )
	sub.w = sub.h

	if item.ent then
		item.ent:Identity()
		item.ent:Rotate( Angle(elapsed * 80,elapsed * 120,elapsed * 30) )
		item.ent:Translate( item.center * -1 )
		item.scene:Render( sub )
	end

	return rect.y + rect.h + 10

end

surface.CreateFont( "CountFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local feed = {}

local nextPropModel = 0
local function AddPropToFeed( model, skin, ply, cnt )

	local camera = Camera( Vector(-200,0,0), Angle(0,0,0), 8 )
	local scene = Scene( camera )
	local ent = scene:AddModel( "prop_feed_model" .. nextPropModel, model)
	nextPropModel = nextPropModel + 1

	ent:SetupBones()
	ent:SetSkin( skin )
	local min, max = ent:GetModelBounds()

	scene:SetBoxLight( 1, 255,255,255 )
	scene:SetBoxLight( 2, 0,0,255 )

	local zsize = max.z - min.z
	local ysize = max.y - min.y
	local dist = 0 --(zsize / 2) / math.sin( (90 * DEG_2_RAD) / 2 )
	local tan = math.tan( (8 * DEG_2_RAD) / 2 )
	local expand = math.sqrt(2)

	for i=1, 3 do
		dist = math.max( max[i] - min[i] , dist )
	end

	--camera.pos.z = (min.z + max.z) / 2
	camera.pos.x = ( ( -dist / 2 ) / tan ) * expand

	print(dist)

	table.insert( feed,
	{
		elapsed = 0,
		center = (min + max) / 2,
		ent = ent,
		camera = camera,
		scene = scene,
		time = CurTime(),
		first_time = CurTime(),
		duration = 5,
		model = model,
		skin = skin,
		ply = ply,
		count = 1,
		worth = math.random(1,10) * 100,
		wanted = math.random(1,10) == 5,
		custom = math.random(1,10) == 5,
	})

	if feed[#feed].custom then feed[#feed].wanted = false end
	if feed[#feed].wanted then feed[#feed].worth = math.random(1,10) * 10000 end

end

local function FindEntry( ply, model, skin )

	for k,v in pairs( feed ) do
		if v.ply == ply and v.model == model and v.skin == skin then
			return v
		end
	end

end

net.Receive("propcollect", function()
	local model = net.ReadString()
	local skin = net.ReadUInt( 16 )
	local count = net.ReadUInt( 16 )
	local ply = net.ReadEntity()

	local exist = FindEntry( ply, model, skin )
	if exist then
		exist.time = CurTime()
		exist.count = exist.count + 1
		return
	end

	AddPropToFeed(model, skin, ply, count)
end)

function Paint()

	--[[local y = DrawPropEntry(nil, 10,10, 0)
	y = DrawPropEntry(nil, 10,y, 0, false, true)
	DrawPropEntry(nil, 10,y, 0, true)]]

	local x = 10
	local y = 10
	local display = Rect("screen")

	for i = #feed, 1, -1 do

		local item = feed[i]
		local elapsed = item.elapsed
		local dt = (CurTime() - item.time) / item.duration
		if dt < 1 then

			y = DrawPropEntry(item, x, y, dt)

			--[[local scale = math.min((1-dt) * 4, 1)
			local scale2 = math.min((1-dt) * 32, 1)
			local rect = Rect(0,0,64,64):ScreenScale()

			scale = scale * scale

			rect.h = rect.h * scale
			rect:Dock( display, DOCK_LEFT + DOCK_TOP )
			rect.y = rect.y + y
			rect:Inset( 10 )

			surface.SetDrawColor( 200,200,200,220 )
			surface.DrawRect( rect:Unpack() )

			local sub = Rect( rect )
			sub:Inset( 4 )

			item.ent:Identity()
			item.ent:Rotate( Angle(elapsed * 80,elapsed * 120,elapsed * 30) )
			item.ent:Translate( item.center * -1 )
			item.scene:Render( sub )

			local texty = (rect.y + rect.h / 2) - 10 * table.Count( item.count )
			for k,v in pairs( item.count ) do

				local nick = k:Nick()
				surface.SetFont( "CountFont" )
				surface.SetTextColor(0,0,0,255 * scale)
				surface.SetTextPos( rect.x + rect.w + 9, texty - 1 )
				surface.DrawText( nick .. ": " .. tostring( v ) .. "x" )

				surface.SetTextColor(255,255,255,255 * scale)
				surface.SetTextPos( rect.x + rect.w + 10, texty )
				surface.DrawText( nick .. ": " .. tostring( v ) .. "x" )
				texty = texty + 20

			end

			y = y + rect.h + ScreenScale(10)]]

			item.elapsed = item.elapsed + FrameTime()

		else
			table.remove( feed, i )
		end

	end

end