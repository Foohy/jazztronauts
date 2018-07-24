-- This file controls how the dialog should be drawn/styled/progressed
-- Handles text rendering, option selection, and scene selection.

local chatboxMat = Material("materials/ui/chatbox.png", "alphatest")

local function ScreenScaleEx(...)
	local scales = {...}
	for k, v in pairs(scales) do
		scales[k] = ScreenScale(v)
	end

	return unpack(scales)
end

-- Position of top left corner of text, relative to dialog background
local TextX, TextY = ScreenScaleEx(80, 25)

-- Position of top left corner for name text
local NameTextX, NameTextY = ScreenScaleEx(75, 20)

-- Position of top left corner of dialog background
local BGOffX, BGOffY = ScreenScaleEx(60, 10)

local BGW, BGH = ScreenScaleEx(500, 90)

local DialogColor = Color(64, 38, 49, 255)


local CatW, CatH = ScreenScaleEx(150, 170)
local CatCamOffset = Vector(-35, 60, 0):GetNormal() * 70

-- Local view camera offsets for specific models
-- We try to not need these, but sometimes it's just easier
local CamOffsets = {
	["models/krio/jazzcat1.mdl"] = {pos = Vector(0, 0, 12), offset = Vector(-36, -60, 0):GetNormal() * 70},
	["models/andy/bartender/cat_bartender.mdl"] = {pos = Vector(0, 15, 0), offset = Vector(-60, 0, -36):GetNormal() * 90},
	["models/andy/pianist/cat_pianist.mdl"] = {pos = Vector(0, 15, 0), offset = Vector(-60, 0, -36):GetNormal() * 90},
	["models/andy/cellist/cat_cellist.mdl"] = {pos = Vector(0, 15, 0), offset = Vector(-60, 0, -36):GetNormal() * 90},
	["models/andy/singer/cat_singer.mdl"] = {pos = Vector(0, 15, 0), offset = Vector(-60, 0, -36):GetNormal() * 90},
	["models/props_c17/oildrum001_explosive.mdl"] = { pos = Vector(0, 0, 40), offset = CatCamOffset },
	["models/pizza_steve/pizza_steve.mdl"] = { pos = Vector(0, 0, -23), offset = CatCamOffset * 1.1 }
}

local DialogCallbacks = {}


surface.CreateFont( "JazzDialogNameFont", {
	font = "KG Shake it Off Chunky",
	extended = false,
	size = ScreenScale(15),
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "JazzDialogFont", {
	font = "Arial",
	extended = false,
	size = ScreenScale(15),
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "JazzDialogFontHint", {
	font = "Arial",
	extended = false,
	size = ScreenScale(11),
	weight = 500,
	antialias = true,
} )

-- The focus proxy allows us to use another model as a replacement
-- for the normal npc. The NPC provides the context for the dialog
-- and this lets us modify it without actually modifying it
local focusProxy
function dialog.SetFocusProxy(focusEnt)
	focusProxy = focusEnt
end

function dialog.GetFocusProxy()
	return focusProxy
end

local function drawPlayer(ply)
	if not pac then
		ply:DrawModel()
		return 
	end

	pac.ForceRendering(true) 
	pac.ShowEntityParts(ply)
	pac.RenderOverride(ply, "opaque")
	pac.RenderOverride(ply, "translucent", true)
	ply:DrawModel()
	pac.ForceRendering(false)
end

local function isPlayer(ply)
	return ply:IsPlayer() or ply == LocalPlayer().JazzDialogProxy
end

local renderPlayerCutIn = false
local function RenderEntityCutIn(ent, x, y, w, h)
	if not IsValid(ent) then return end

	local headpos = ent:GetPos()
	local entangs = ent:GetAngles()
	local offset = entangs:Right() * CatCamOffset.X + entangs:Forward() * CatCamOffset.Y

	-- Attempt to automatically find a good spot to focus on
	local bone = ent:LookupBone("ValveBiped.Bip01_Neck1")	
	bone = bone or ent:LookupBone("ValveBiped.Bip01_Head1")
	bone = bone or ent:LookupBone("Head")
	bone = bone or ent:LookupBone("rig_cat:j_head")

	if bone and ent:GetBonePosition(bone) != ent:GetPos() then
		headpos = ent:GetBonePosition(bone)
	elseif isPlayer(ent) then
		headpos = ent:GetPos() + entangs:Up() * 60
	end

	-- Apply additional offsets if necessary
	local posang = CamOffsets[ent:GetModel()]
	if posang then
		headpos = headpos + entangs:Right() * posang.pos.x + entangs:Forward() * posang.pos.y +  entangs:Up() * posang.pos.z
		offset = entangs:Right() * posang.offset.X + entangs:Forward() * posang.offset.Y + entangs:Up() * posang.offset.Z
	end

	-- Calculate virtual camera view
	local pos = headpos + offset
	local ang = (headpos - pos):Angle()

	renderPlayerCutIn = ent == LocalPlayer()
	cam.Start3D(pos, ang, 25, x, y, w, h)
		if isPlayer(ent) then
			drawPlayer(ent)
		else
			ent.NoFollowPlayer = true
			ent:DrawModel()
			ent.NoFollowPlayer = false
		end
	cam.End3D()

	renderPlayerCutIn = false
end
hook.Add("ShouldDrawLocalPlayer", "JazzDrawLocalPlayerDialog", function()
	if renderPlayerCutIn then return true end
end )

local function GetSpeakerName(ent)
	if not IsValid(ent) then return "nil" end

	-- Allow entities to override their visual name/npcid
	local npcid = ent.JazzDialogID or (ent.GetNPCID and ent:GetNPCID())
	local name = ent.JazzDialogName or missions.GetNPCPrettyName(npcid) or (ent.GetName and ent:GetName()) or ent:GetClass()
	return string.upper(name)
end

local function GetCurrentSpeaker()
	local speaker = dialog.GetSpeaker()
	if not IsValid(speaker) then speaker = focusProxy end
	if not IsValid(speaker) then return nil, "nil" end

	-- Allow entities to have their own passive proxies
	if speaker.JazzDialogProxy then
		--speaker = speaker.JazzDialogProxy
	end

	if speaker == dialog.GetFocus() and IsValid(focusProxy) then
		speaker = focusProxy
	end

	return speaker, GetSpeakerName(speaker), isPlayer(speaker)
end

DialogCallbacks.Paint = function(_dialog)
	if _dialog.open == 0 then return end
	if not IsValid(_dialog.textpanel) then return end
	if hook.Call("OnJazzDialogPaintOverride", GAMEMODE, _dialog) then return end

	local speaker, speakername, localspeaker = GetCurrentSpeaker()

	local open = math.sin( _dialog.open * math.pi / 2 )
	open = math.sqrt(open)

	local w = BGW * open
	local h = BGH * open

	local x = ScrW() / 2 + BGOffX * (localspeaker and -1 or 1)
	local y = ScrH() - h/2 - BGOffY

	surface.SetMaterial(chatboxMat)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRectUV( x - w/2, y - h/2, w, h, localspeaker and 1 or 0, 0, localspeaker and 0 or 1, 1)

	local left = x - w/2 + NameTextX 
	local top = y - h/2 + NameTextY

	surface.SetTextColor( DialogColor.r, DialogColor.g, DialogColor.b, 255 * open )
	surface.SetFont( "JazzDialogNameFont" )
    local tw,th = surface.GetTextSize(speakername)

	-- Draw current speaker's name
	local nameX = localspeaker and x + w/2 - tw - NameTextX or left
	surface.SetTextPos(nameX, top - th)
	surface.DrawText(speakername)

	surface.SetFont( "JazzDialogFont" )
    local tw,th = surface.GetTextSize( "a" )
	left = x - w/2 + TextX * (localspeaker and 0.2 or 1)
	top = y - h/2 + TextY

	-- Draw dialog contents
	_dialog.textpanel:SetPos(left, top)
	_dialog.textpanel:SetSize(ScrW(), ScrH())
	/*
	local lines = string.Explode( "\n", _dialog.printed )
	for k, line in pairs(lines) do
		surface.SetTextPos( left, top + th * (k-1) )
		surface.DrawText( line )
	end*/

	-- If we're waiting on input, slam that down
	if dialog.ReadyToContinue() then
		surface.SetFont( "JazzDialogFontHint" )
		local contstr = "Click to continue...    "
		local tw,th = surface.GetTextSize(contstr)
		local contX = x + w/2 - tw //* (localspeaker and 0.2 or 1)
		if localspeaker then
			contX = contX - ScreenScale(65)
		end
		surface.SetTextColor( 38, 38, 38, 255 * open )
		surface.SetTextPos(contX, y + h/2 - th)
		surface.DrawText(contstr)
		_dialog.textpanel:SetCursor("hand")
	end

	-- Render whoever's talking
	if localspeaker then
		RenderEntityCutIn(speaker, ScrW() - CatW, ScrH() - CatH * math.EaseInOut(_dialog.open, 0, 1), CatW, CatH)
	else
		RenderEntityCutIn(speaker, 0, ScrH() - CatH * math.EaseInOut(_dialog.open, 0, 1), CatW, CatH)
	end
end

-- Called when the dialog presents the user with a list of branching options
DialogCallbacks.ListOptions = function(data)
	local frame = vgui.Create("DFrame")
	frame:MakePopup()
	frame:SetSizable(true)
	frame:ShowCloseButton(false)
	frame:SetSizable(false)
	frame:SetTitle("")
	frame:SetPos(ScreenScaleEx(20, 20))
	frame:SetSize(ScreenScaleEx(400, 300))
	frame:NoClipping(true)
	frame:DockPadding(0, 20, 0, 20)
	frame.Paint = function(self, w, h)

		-- Rotated pink back box	
		local rotmat = Matrix()
		rotmat:Translate(Vector(w/2, h/2, 0))
		rotmat:Rotate(Angle(0, -2, 0))
		rotmat:Translate(Vector(-w/2, -h/2, 0))
		rotmat:Translate(Vector(ScreenScale(-5, 0, 0)))
		cam.PushModelMatrix(rotmat)
			draw.RoundedBox(ScreenScale(19), 0, 0, w, h, Color(238, 19, 122))
		cam.PopModelMatrix()

		-- upright normal box
		draw.RoundedBox(ScreenScale(10), 0, 0, w, h, Color(224, 209, 177))

	end

	for k, v in ipairs(data.data) do
		local btn = vgui.Create("DButton", frame)
		btn:SetFont("JazzDialogFont")
		btn:SetText(v.data[1].data)
		btn:SizeToContents()
		btn:SizeToContentsY(ScreenScale(5))
		btn:Dock(TOP)
		btn:DockMargin(ScreenScaleEx(5, 0, 5, 8))

		btn.Paint = function(self, w, h)
			if self.Hovered then 
				local thick = ScreenScale(1)
				surface.SetDrawColor(238, 19, 122)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(215, 195, 151, 255)
				surface.DrawRect(thick, thick, w - thick*2, h - thick*2) 
			end
		end

		btn.DoClick = function()
            dialog.StartGraph(v.data[1], true, { speaker = LocalPlayer() })
			frame:Close()
		end
	end

	frame:InvalidateLayout(true)
	frame:SizeToChildren(true, true)
end

local function CreateRichText()
	local richText = vgui.Create("RichText")
	richText:SetAutoDelete(false)
	richText:SetVerticalScrollbarEnabled(false)

	function richText:PerformLayout()
		self:SetFontInternal("JazzDialogFont")
		self:SetFGColor(DialogColor)
	end

	-- STOP SELECTING MY TEXT
	function richText:Think()
		self:KillFocus()
	end

	hook.Call("OnJazzDialogCreatePanel", GAMEMODE, richText)

	return richText
end

-- Called when we are beginning a new dialog session
DialogCallbacks.DialogStart = function(d)
	if not dialog.GetParam("HIDE_MOUSE") then
		gui.EnableScreenClicker(true)
	end

	dialog.SetFocusProxy(nil)
	LocalPlayer().JazzDialogLastLockAngles = nil

	if IsValid(d.textpanel) then
		d.textpanel:Remove()
		d.textpanel = nil
	end
		
	d.textpanel = CreateRichText()
end

-- Called when we are finished with a dialog session
DialogCallbacks.DialogEnd = function(d)
	gui.EnableScreenClicker(false)
	dialog.InformScriptFinished(d.entrypoint, d.seen)
	dialog.ResetView()
	dialog.StopBGMusic(1.5)
	dialog.SetFocusProxy(nil)
	LocalPlayer().JazzDialogLastLockAngles = nil

	if IsValid(d.textpanel) then
		d.textpanel:Remove()
		d.textpanel = nil
	end
end

-- Called when we should append the specific text to our dialog output
DialogCallbacks.AppendText = function(d, txt)
	if IsValid(d.textpanel) then
		d.textpanel:AppendText(txt)
	end
end

-- Called when we should set the dialog text to this
DialogCallbacks.SetText = function(d, txt)
	if IsValid(d.textpanel) then
		d.textpanel:SetText(txt)
	end
end

-- Hook into dialog system to style it up and perform IO
local function Initialize()
    dialog.SetCallbackTable(DialogCallbacks)
end
hook.Add("InitPostEntity", "JazzInitializeDialogRendering", Initialize)
hook.Add("OnReloaded", "JazzInitializeDialogRendering", Initialize)

local lastKeyDownFlag = 0
local prefixFuncs = 
{
	["IN"] = function(val) return bit.band(lastKeyDownFlag, val) == val end,
	["KEY"] = function(val) return input.IsKeyDown(val) end,
	["MOUSE"] = function(val) return input.IsMouseDown(val) end
}

local function AnyKeyDown(enumName)
	local enumVal = _G[enumName]
	if not enumVal then return false end

	local prefix = string.Split(enumName, "_")[1]
	if not prefixFuncs[prefix] then return false end

	return prefixFuncs[prefix](enumVal)
end

local function AnyKeysDown(keys)
	for _, v in pairs(keys) do
		if AnyKeyDown(v) then return true end
	end

	return false
end

local DefaultKeys = { "MOUSE_LEFT", "KEY_SPACE", "KEY_ENTER" }

local wasSkipPressed = false
local wasSkipPressedInDialog = false
hook.Add("StartCommand", "JazzDialogLockPlayer", function(ply, usercmd)

	-- Specific logic to make it so they must have RELEASED the skip key before
	if not wasSkipPressedInDialog and not dialog.IsInDialog() then 
		return 
	end

	wasSkipPressedInDialog = wasSkipPressed

	-- Before we clear buttons, we'll query em later
	lastKeyDownFlag = usercmd:GetButtons()

	ply.JazzDialogLastLockAngles = ply.JazzDialogLastLockAngles or usercmd:GetViewAngles()
	usercmd:ClearMovement()
	usercmd:ClearButtons()
	usercmd:SetViewAngles(ply.JazzDialogLastLockAngles)
end )

-- Hook into user input so they can optionally skip dialog, or continue to the next one
hook.Add("Think", "JazzDialogSkipListener", function()
	local keyOverrides = dialog.GetParam("ADVANCE_KEYS")
	keyOverrides = keyOverrides and string.Replace(keyOverrides, " ", "")
	keyOverrides = keyOverrides and string.Split(keyOverrides, ",")

	local skip = AnyKeysDown(keyOverrides or DefaultKeys)
	
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



-- Set the color of all upcoming text
dialog.RegisterFunc("c", function(d, r, g, b, a)
	if not r or not g then
		r = DialogColor.r
		g = DialogColor.g
		b = DialogColor.b
		a = tonumber(r) or DialogColor.a
	else
		r = tonumber(r) or 255
		g = tonumber(g) or 255
		b = tonumber(b) or 255
		a = tonumber(a) or 255
	end

	d.textpanel:InsertColorChange(r, g, b, a)
end )
