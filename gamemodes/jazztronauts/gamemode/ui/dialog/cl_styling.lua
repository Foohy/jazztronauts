-- This file controls how the dialog should be drawn/styled/progressed
-- Handles text rendering, option selection, and scene selection.

local chatboxMat = Material("materials/ui/chatbox.png", "alphatest")

-- Position of top left corner of text, relative to dialog background
local TextX = ScreenScale(80)
local TextY = ScreenScale(25)

-- Position of top left corner for name text
local NameTextX = ScreenScale(75)
local NameTextY = ScreenScale(20)

-- Position of top left corner of dialog background
local BGOffX = ScreenScale(60)
local BGOffY = ScreenScale(10)

local BGW = ScreenScale(500)
local BGH = ScreenScale(90)


local CatW = ScreenScale(150)
local CatH = ScreenScale(170)
local CatCamOffset = Vector(-60, -35, 0):GetNormal() * 70


local DialogCallbacks = {}

surface.CreateFont( "JazzDialogNameFont", {
	font = "KG Shake it Off Chunky",
	extended = false,
	size = ScreenScale(15),
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

surface.CreateFont( "JazzDialogFont", {
	font = "Arial",
	extended = false,
	size = ScreenScale(15),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "JazzDialogFontHint", {
	font = "Arial",
	extended = false,
	size = ScreenScale(11),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )


local function RenderCatCutIn(_dialog, x, y, w, h)
	local cat = dialog.GetFocus()
	if not IsValid(cat) then return end
	local headpos = cat:GetPos() + cat:GetAngles():Up() * 49

	local pos = headpos + cat:GetAngles():Forward() * CatCamOffset.X + cat:GetAngles():Right() * CatCamOffset.Y
	local ang = (headpos - pos):Angle()

	cam.Start3D(pos, ang, 25, x, y, w, h)
		cat:DrawModel()
	cam.End3D()
end

local function GetCurrentSpeaker()
	local speaker = dialog.GetFocus()
	if not IsValid(speaker) || !speaker.GetNPCID then return "" end

	return string.upper(missions.GetNPCName(speaker:GetNPCID()))
end

DialogCallbacks.Paint = function(_dialog)
	if _dialog.open == 0 then return end

	local open = math.sin( _dialog.open * math.pi / 2 )
	open = math.sqrt(open)

	local w = BGW * open
	local h = BGH * open

	local x = ScrW() / 2 + BGOffX
	local y = ScrH() - h/2 - BGOffY

	surface.SetMaterial(chatboxMat)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRectUV( x - w/2, y - h/2, w, h, 0, 0, 1, 1)

	local left = x - w/2 + NameTextX
	local top = y - h/2 + NameTextY

	surface.SetTextColor( 64, 38, 49, 255 * open )
	surface.SetFont( "JazzDialogNameFont" )
    local tw,th = surface.GetTextSize( "a" )

	-- Draw current speaker's name
	surface.SetTextPos( left, top - th)
	surface.DrawText( GetCurrentSpeaker())

	surface.SetFont( "JazzDialogFont" )
    local tw,th = surface.GetTextSize( "a" )
	left = x - w/2 + TextX
	top = y - h/2 + TextY

	-- Draw dialog contents
	local lines = string.Explode( "\n", _dialog.printed )
	for k, line in pairs(lines) do
		surface.SetTextPos( left, top + th * (k-1) )
		surface.DrawText( line )
	end

	-- If we're waiting on input, slam that down
	if dialog.ReadyToContinue() then
		surface.SetFont( "JazzDialogFontHint" )
		local contstr = "Click to continue...    "
		local tw,th = surface.GetTextSize(contstr)
		surface.SetTextColor( 38, 38, 38, 255 * open )
		surface.SetTextPos( x + w/2 - tw, y + h/2 - th)
		surface.DrawText(contstr)
	end

	-- Render whoever's talking
	RenderCatCutIn(_dialog, 0, ScrH() - CatH * math.EaseInOut(_dialog.open, 0, 1), CatW, CatH)
end

-- Called when the dialog presents the user with a list of branching options
DialogCallbacks.ListOptions = function(data)
	local frame = vgui.Create("DFrame")
	frame:Center()
	frame:MakePopup()
	frame:SetSizable(true)
	frame:SetWide(100)

	for k, v in ipairs(data.data) do
		local btn = vgui.Create("DButton", frame)
		btn:SetText(v.data[1].data)
		btn:SizeToContents()
		btn:Dock(TOP)
		btn.DoClick = function()
            dialog.StartGraph(v.data[1], true)
			frame:Close()
		end
	end

	frame:InvalidateLayout(true)
	frame:SizeToChildren(true, true)
end

-- Called when we are beginning a new dialog session
DialogCallbacks.DialogStart = function()
	gui.EnableScreenClicker(true)
end

-- Called when we are finished with a dialog session
DialogCallbacks.DialogEnd = function()
	gui.EnableScreenClicker(false)
end

-- Hook into dialog system to style it up and perform IO
local function Initialize()
    dialog.SetCallbackTable(DialogCallbacks)
end
hook.Add("InitPostEntity", "JazzInitializeDialogRendering", Initialize)
hook.Add("OnReloaded", "JazzInitializeDialogRendering", Initialize)

-- Hook into user input so they can optionally skip dialog, or continue to the next one
local wasSkipPressed = false
hook.Add("Think", "JazzDialogSkipListener", function()
	local skip = input.IsMouseDown(MOUSE_LEFT) 
		or input.IsKeyDown(KEY_SPACE)
		or input.IsKeyDown(KEY_ENTER)
	
	if skip == wasSkipPressed then return end
	wasSkipPressed = skip

	if not dialog.IsInDialog() then return end
	if not skip then return end

	-- First try to continue to the next page of dialog
	if not dialog.Continue() then

		-- If we couldn't, that means we're still writing 
		-- So speed up the text output
		dialog.SkipText()
	end
end)
