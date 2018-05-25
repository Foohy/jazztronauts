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
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local function CreateResponseButtons(data)
	local frame = vgui.Create("DFrame")
	frame:Center()
	frame:MakePopup()
	frame:SetSizable(true)
	frame:SetWide(100)
	PrintTable(data)
	for k, v in ipairs(data.data) do
		print("yo: ", v)
		PrintTable(v)
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

local function RenderDialog(_dialog)
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

	-- Render whoever's talking
	RenderCatCutIn(_dialog, 0, ScrH() - CatH * math.EaseInOut(_dialog.open, 0, 1), CatW, CatH)
end


local function Initialize()
    dialog.SetOptionCallback(CreateResponseButtons)
    dialog.SetRenderCallback(RenderDialog)
end
hook.Add("InitPostEntity", "JazzInitializeDialogRendering", Initialize)
hook.Add("OnReloaded", "JazzInitializeDialogRendering", Initialize)

-- Setup scene with clientside player/cat doubles