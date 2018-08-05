
local left = ScreenScale(200)
local top = ScreenScale(100)

surface.CreateFont( "JazzDialogGimmickFont", {
	font = "Palatino Linotype",
	extended = false,
	size = ScreenScale(20),
	weight = 500,
	antialias = false,
	shadow = true,
} )

hook.Add("OnJazzDialogCreatePanel", "JazzDoDumbSilentHillDialogGimmickTextPanel", function(richText)
	if dialog.GetParam("STYLE") != "horror" then return end

	function richText:PerformLayout()
		self:SetFontInternal("JazzDialogGimmickFont")
		self:SetFGColor(Color(255, 255, 255, 200))
	end
end )

hook.Add("OnJazzDialogPaintOverride", "JazzDoDumbSilentHillDialogGimmickPaint", function(_dialog)
	if dialog.GetParam("STYLE") != "horror" then return end

	local bottom = ScrH() - top
	_dialog.textpanel:SetPos(left, bottom)
	_dialog.textpanel:SetSize(ScrW() - left*2, ScrH() - top*2)
	_dialog.textpanel:PaintManual()

	return true
end )

hook.Add("JazzOverrideCatSound", "JazzDoDumbSilentHillDialogGimmickNoChatSounds", function(npcid)
	if dialog.GetParam("STYLE") == "horror" then return true end
end)