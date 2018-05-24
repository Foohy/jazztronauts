-- This file controls how the dialog should be drawn/styled/progressed
-- Handles text rendering, option selection, and scene selection.

surface.CreateFont( "DialogFont", {
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

local function RenderDialog(_dialog)
    local width, height = 850, 200
	if _dialog.open == 0 then return end

	local open = math.sin( _dialog.open * math.pi / 2 )
	open = math.sqrt(open)

	local w = width * open
	local h = height * open

	local x = ScrW() / 2
	local y = ScrH() - h

	surface.SetDrawColor( 0,0,0,190 )
	surface.DrawRect( x - w/2, y - h/2, w, h )

	local left = x - 800/2 // - _dialog.textw / 2
	local top = y - 200/2//- _dialog.texth / 2

	surface.SetTextColor( 255, 255, 255, 255 * open )
	surface.SetFont( "DialogFont" )
    local tw,th = surface.GetTextSize( "a" )
	local lines = string.Explode( "\n", _dialog.printed )
	for k, line in pairs(lines) do
		surface.SetTextPos( left, top + th * (k-1) )
		surface.DrawText( line )
	end
end


local function Initialize()
    dialog.SetOptionCallback(CreateResponseButtons)
    dialog.SetRenderCallback(RenderDialog)
end
hook.Add("InitPostEntity", "JazzInitializeDialogRendering", Initialize)
hook.Add("OnReloaded", "JazzInitializeDialogRendering", Initialize)

-- Setup scene with clientside player/cat doubles