AddCSLuaFile()

if SERVER then return end

module( "eventfeed", package.seeall )

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
	size = ScreenScale(25),
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
local color_text_mission1 = Color(190,166,115)
local color_text_mission2 = Color(228,183,86)
local color_text_generic1 = Color(219,198,185)
local color_text_generic2 = Color(68,54,45)

local tick_manager = jtime.TickManager()

local hue_stops = {
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

local function GetHueGradientStops( hue )

	local color_grad1x = HSVToColor(hue, 1, .95)
	local color_grad2x = HSVToColor(hue, .2, 1)
	local color_grad3x = HSVToColor(hue, .65, 1)

	hue_stops[1][2] = color_grad1x
	hue_stops[2][2] = color_grad3x
	hue_stops[3][2] = color_grad2x
	hue_stops[4][2] = color_grad3x
	hue_stops[5][2] = color_grad1x
	hue_stops[6][2] = color_grad1x
	hue_stops[7][2] = color_grad3x
	hue_stops[8][2] = color_grad2x
	hue_stops[9][2] = color_grad1x
	hue_stops[10][2] = color_grad3x
	hue_stops[11][2] = color_grad2x
	hue_stops[12][2] = color_grad3x
	hue_stops[13][2] = color_grad1x
	hue_stops[14][2] = color_grad1x
	hue_stops[15][2] = color_grad3x
	hue_stops[16][2] = color_grad2x

	return hue_stops

end

local generic_gradient_rect = Rect(0,0,165,30):ScreenScale()
local m = CacheGradient( "stage0", generic_gradient_rect, -45, hue_stops, 0, nil )
local text_irt = irt.New( "text_render", generic_gradient_rect:GetSize())
text_irt:SetAlphaBits(8)

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
local notify_list = {}

local meta = {}
meta.__index = meta

local event_style0 = styler.New({
	["whole"] = styler.Font( "PropFeed_Generic1" ) + styler.Color( color_text_generic1 ),
	["whole_dark"] = styler.Font( "PropFeed_Generic1" ) + styler.Color( color_text_generic2 ),
	["param"] = styler.Color( color_text_name1 ),
	["name"] = styler.Font("PropFeed_Name"),
	["total"] = styler.Font( "PropFeed_Numeric" ),
	["count"] = styler.Font( "PropFeed_Name" ) + styler.Color( color_text_prop1 ),
	["prop"] = styler.Font( "PropFeed_Name" ),
	["red_name"] = styler.Font( "PropFeed_Name" ) + styler.Color( color_text_prop2 ),
	["green_name"] = styler.Font( "PropFeed_Name" ) + styler.Color( color_text_prop1 ),
})

local dark_style_override = {
	["whole"] = "whole_dark",
	["green_name"] = "red_name",
	["count"] = "red_name",
}


function meta:Init()

	self.style = event_style0
	self.title = nil
	self.body = nil
	self.modelicon = nil
	self.modelent = nil
	self.highlight = false
	self.gradient_hue = 46
	self.fx = {}
	return self

end

function meta:Ping( remain )

	if not self.time then return end

	self.ping_time:Time(0)

	if remain then
		self.ping_time:Bound( 1 + remain )
	end

	return self

end

function meta:SetHue( hue )

	self.gradient_hue = hue
	return self

end

function meta:Dispatch( remain, where )

	if self.time then return end

	self.time = jtime.Ticker( tick_manager )
	self.ping_time = jtime.Ticker( tick_manager ):Bound( 1 + (remain or 1) )

	if type(where) == "table" and getmetatable(where) == meta then
		where = where:Where() + 1
	end

	if where == "top" then where = 1 end
	if where == "bottom" then where = #notify_list + 1 end

	table.insert( notify_list, where or 1, self )

	return self

end

function meta:Where()

	for k, v in pairs( notify_list ) do
		if v == self then return k end
	end
	return 1

end

nextIconModelID = nextIconModelID or 0
function meta:SetIconModel( model, skin, material )

	nextIconModelID = nextIconModelID + 1

	local camera = Camera( Vector(-200,0,0), Angle(0,0,0), 8 )
	local scene = Scene( camera )
	local ent = scene:AddModel( "notify_model_icon" .. nextIconModelID, model)

	ent:SetupBones()
	if skin then ent:SetSkin( skin ) end
	local min, max = ent:GetModelBounds()

	for i=1, 6 do
		scene:SetBoxLight( i, 255,255,255 )
	end

	local zsize = max.z - min.z
	local ysize = max.y - min.y
	local dist = 0
	local tan = math.tan( (8 * DEG_2_RAD) / 2 )
	local expand = math.sqrt(2)

	for i=1, 3 do dist = math.max( max[i] - min[i] , dist ) end

	camera.pos.x = ( ( -dist / 2 ) / tan ) * expand

	self.modelicon = scene
	self.modelent = ent
	self.modelcenter = (min + max) / 2

	if material then

		self.modelent:SetMaterial( material )

	end

	return self

end

function meta:Title(...)

	self.title = self.style:Element(...)
	self:UpdateHighlightStyle( self.title )
	return self

end

function meta:Body(...)

	self.body = self.style:Element(...)
	self:UpdateHighlightStyle( self.body )
	return self

end

function meta:UpdateHighlightStyle( element )

	if not element then return end
	for k,v in pairs( dark_style_override ) do
		element:SetStyleOverride( k, self.highlight and v or nil )
	end

end

function meta:SetHighlighted( highlight )

	self.highlight = highlight
	self:UpdateHighlightStyle( self.title )
	self:UpdateHighlightStyle( self.body )
	return self

end

function meta:DrawBackground( rect )

	local scroll = self.time()
	local stops = GetHueGradientStops(self.gradient_hue == "rainbow" and ( math.fmod(scroll*200, 360) ) or self.gradient_hue)
	local a = CacheGradient( "stage0", Rect(0,0,200,35):ScreenScale(), -45 + math.sin(CurTime() * 4) * 20, stops, -math.fmod(scroll * 400, 400), nil )
	local b = CacheGradient( "stage1", Rect(0,0,200,35):ScreenScale(), -45 + math.cos(CurTime() * 4) * 20, stops, math.fmod(scroll * 400, 400) - 400, a )

	self.cached_gradient = b

	if self.highlight then
		LinearGradient( rect, 0, alpha_stops, 0, b )
	else
		LinearGradient( rect, 0, color_stops1, 0 )
	end

end

function meta:DrawFlash( rect, amount )

	LinearGradientCached( "blast", Rect( rect ):Inset( -ScreenScale(2)), Color(255,255,100 + amount * 155, amount * 255 ) )

end

function meta:ShakeRect( rect, sx, sy )

	rect.x = rect.x + math.random(-10,10) * .75 * sx
	rect.y = rect.y + math.random(-10,10) * .5 * sy

end

function meta:Update()

	local time = self.time
	local pingtime = self.ping_time
	local fx = self.fx

	fx.scroll = elapsed
	fx.shift = 0
	fx.flash = 1 - pingtime(true, .25)
	fx.shake_x = fx.flash
	fx.shake_y = pingtime(true, .5)
	fx.shake_y = 1 - fx.shake_y * fx.shake_y
	fx.zip = time(true, .2)
	fx.zip = math.pow((1-math.cos(fx.zip * math.pi/2)), 2)
	fx.fade = time:Range(.1,.3,true) * ( 1 - pingtime:Range(-1,-.5,true) )

	return self

end

function meta:DrawBodyIRT( rect )

	local fx = self.fx

	local left = ScreenScale(30)
	local top = ScreenScale(8)

	text_irt:Render( function()

		local oldx, oldy = rect.x, rect.y
		local oldW, oldH = ScrW(), ScrH()

		rect.x = 0
		rect.y = 0

		render.Clear( 255,0,0,0 )
		render.SetViewPort( rect:Unpack() )

		cam.Start2D()

		render.OverrideAlphaWriteEnable( true, true )
		render.OverrideColorWriteEnable( true, false )

		self.body:Draw( left, top, 0, 0, 255 * fx.fade )

		render.OverrideAlphaWriteEnable( false )
		render.OverrideColorWriteEnable( false )

		LinearGradient( rect, 0, alpha_stops, 0, self.cached_gradient )

		cam.End2D()
		render.SetViewPort( 0, 0, oldW, oldH )

		rect.x = oldx
		rect.y = oldy

	end )

	local mat = text_irt:GetUnlitMaterial(true,false,true,true)

	surface.SetMaterial( mat )
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(rect:Unpack())

end

function meta:DrawIcon( rect )

	if self.modelicon then

		local elapsed = self.time()
		local sub = Rect( rect )
		sub:Inset( 4 )
		sub.w = sub.h

		render.SetColorModulation(1,1,1)

		self.modelent:Identity()
		self.modelent:Rotate( Angle(elapsed * 80,elapsed * 120,elapsed * 30) )
		self.modelent:Translate( self.modelcenter * -1 )
		self.modelicon:Render( sub )

	end

end

function meta:Draw( y )

	self:Update()

	local x_offset = 10
	local stringw = 1
	if self.title then
		stringw = #self.title.raw_string * ScreenScale(8) --get us our rough text size
	end
	local rect = Rect( x_offset, y, math.max(generic_gradient_rect.w,stringw), generic_gradient_rect.h )
	
	local fx = self.fx
	local time = self.time
	local pingtime = self.ping_time

	if not self.body then
		rect.h = rect.h - 40
	end

	rect.h = rect.h * fx.zip
	rect.h = rect.h * pingtime:FromEnd(true, .5)

	self:ShakeRect( rect, fx.shake_x, fx.shake_y )
	self:DrawFlash( rect, fx.flash )
	self:DrawBackground( rect )
	self:DrawIcon( rect )

	if self.title then self.title:Draw( rect.x + ScreenScale(30), rect.y + ScreenScale(1), 0, 0, 255 * fx.fade ) end

	if self.body then

		if not self.highlight then
			self:DrawBodyIRT( rect )
		else
			self.body:Draw( rect.x + ScreenScale(30), rect.y + ScreenScale(8), 0, 0, 255 * fx.fade )
		end

	end

	return y + rect.h + 5 * pingtime:FromEnd(true, .5)

end

function meta:Done()

	return self.ping_time:FromEnd(true) == 0

end

function Create()

	return setmetatable({}, meta):Init()

end


--[[local cool_guy = Create()
	:Title("%name is having a chill day", 
		{name = "Cool guy"},
		{name = "green_name"}
	)
	:Dispatch( 4 )

local entry = Create()
	:Title("R.I.P. %name, killed by %killer", 
		{name = "Foohy", killer = "metrocop"}, 
		{killer = "red_name", name = "green_name"}
	)
	:Dispatch( 15 )

local shard_notify = Create()
	:Title("%name FOUND a shard", 
		{name = "Foohy"}
	)
	:Body("%total", 
		{total = function() return "$1,000" end}
	)
	:SetHue("rainbow")
	:SetIconModel( Model("models/sunabouzu/jazzshard.mdl") )
	:Dispatch( 15 )

local entry = Create()
	:Title("%name STOLE %count props", 
		{name = "Foohy", count = 135}
	)
	:Body("%total", 
		{total = function() return string.format("$%i",math.random(0,1000)) end}
	)
	:SetHighlighted( true )
	:Dispatch( 30, shard_notify )]]


local ping_test = jtime.Ticker( tick_manager )

function Paint()

	tick_manager:Update()

	--[[local w,h = element0:Size()

	draw.RoundedBox( 5, Rect(800,100,w,h):Inset(-10):Unpack( Color(0,0,0,200) ) )
	element0:Draw(800,100)]]

	--[[if ping_test(true) > .6 then
		ping_test:Time(0)
		entry:Ping()
		--local entry = Create()
		--entry:Dispatch( 2.5 )
	end]]

	local y = 10
	for k, v in pairs(notify_list) do
		y = v:Draw( y )
	end

	for i=#notify_list, 1, -1 do
		if notify_list[i]:Done() then
			notify_list[i].Done = function() return true end
			table.remove(notify_list, i)
		end
	end

end