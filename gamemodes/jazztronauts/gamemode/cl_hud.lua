//Draws the dynamic money counter

//MODIFIABLES
local HideDelay = 2 //How many seconds to show the amt after it is done filling the counter?
local FillDelay = 2 //Number of seconds before the money can begin filling
local FadeSpeed = 900 //How fast to fade out

local distFromSide = 8

//NON-MODIFIABLES
local bgWidth = 15
local lastWidth = 1
local CurAlpha = 200
local VisualAmount = 0
local HideTime = 0
local moneyFillDelay = 0 //Delay before the money begin filling into the main dude
local moneyFillVelocity = 1 //Amount of money to fill per frame. Adjusted based on how many money to fill
local lastMoneyCount = 0
local isFadingOut = false

surface.CreateFont( "NoteFont",
{
	font		= "Impact",
	size		= ScreenScale(17),
	weight		= 500
})

local function addCommas( num )
	local result = ""

	local sign, before, after = string.match( tostring(num), "^([%+%-]?)(%d*)(%.?.*)$")

	while string.len( before ) > 3 do
		result = "," .. string.sub( before, -3, -1 ) .. result 
		before = string.sub( before, 1, -4 )
	end 

	return sign .. before .. result .. after 

end

local function DrawNoteCount()
	local amt = LocalPlayer() && LocalPlayer():GetNotes() or 0
	if amt != lastMoneyCount then
		moneyFillDelay = CurTime() + FillDelay
		lastMoneyCount = amt
	end
	if amt != VisualAmount then
		HideTime = CurTime() + HideDelay
	end
	
	if CurTime() > HideTime && CurAlpha <= 0 then return //Don't draw if the alpha is 0
	elseif CurTime() > HideTime then
		CurAlpha = math.Clamp(CurAlpha - (FrameTime() * FadeSpeed ), 0, 255 )
	else
		CurAlpha = 200
	end

	surface.SetFont( "NoteFont")
	local finalText = addCommas( VisualAmount ) .. " n"
	bgWidth, bgHeight = surface.GetTextSize( finalText )
	lastWidth = Lerp( FrameTime() * 10, lastWidth, bgWidth + 15 )
	draw.RoundedBox( 4, ScrW() - (distFromSide + lastWidth ), 10, lastWidth, bgHeight + 10, Color( 0, 0, 0, CurAlpha ) )
	
	//Draw how many money we have
	local FinalAmountText = {}
	FinalAmountText["pos"] = { ScrW() - distFromSide - 8, 16 }
	FinalAmountText["color"] = Color(255, 255, 255, CurAlpha)
	FinalAmountText["text"] = finalText
	FinalAmountText["font"] = "NoteFont"
	FinalAmountText["xalign"] = TEXT_ALIGN_RIGHT
	FinalAmountText["yalign"] = TEXT_ALIGN_TOP

	draw.TextShadow( FinalAmountText, 2, math.Clamp( CurAlpha - 40, 0, 200 ) )
	
	//Draw the new money text
	local text = ""
	local color = Color( 255, 0, 0 )
	if amt - VisualAmount > 0 then
		text = "+"
		color = Color( 0, 255, 0 )
	end
	text = text .. tostring( amt - VisualAmount )

	if amt - VisualAmount != 0 then
		draw.DrawText( text, "HudHintTextLarge", ScrW() - distFromSide , bgHeight + 20, color, TEXT_ALIGN_RIGHT)
	end

	if CurTime() > moneyFillDelay then
		moneyFillVelocity = FrameTime() * (math.abs(amt - VisualAmount) ) + 5
		moneyFillVelocity = math.Round( moneyFillVelocity )

		if amt - VisualAmount > 0 then
			VisualAmount = VisualAmount + moneyFillVelocity
			if amt - VisualAmount <= 0 then 
				VisualAmount = amt
			end
		elseif amt - VisualAmount < 0 then
			VisualAmount = VisualAmount - moneyFillVelocity

			if amt - VisualAmount >= 0 then 
				VisualAmount = amt
			end
		else 
			VisualAmount = amt
		end
	end

end

local function DrawShardCount()
	if mapcontrol.IsInHub() then return end

	local left, total = mapgen.GetShardCount()
	local str = (total - left) .. "/" .. total .. " shards collected"
	local color = Color(143, 0, 255, 100)
	if left == 0 then 
		str = "Collected all " .. total .. " shards!"
		color = HSVToColor(math.fmod(CurTime() * 360, 360), .3, .7)
	end

	surface.SetFont("NoteFont")
	local offset = surface.GetTextSize(str) / 2
	offset = offset + 5
	draw.WordBox( 5, ScrW() / 2 - offset, 5, str, "NoteFont", color, color_white ) 

end

hook.Add("HUDPaint", "JazzDrawHUD", function()
	DrawNoteCount()
	DrawShardCount()

	-- Always show the moneybux in the hub
	if mapcontrol.IsInHub() then
		HideTime = math.huge
	end
	
end )

//Show the money count when pressing tab
hook.Add( "ScoreboardShow", "jazz_scoreboardShow", function()
	if !mapcontrol.IsInHub() then return end
	HideTime = math.huge
end )
hook.Add("ScoreboardHide", "jazz_scoreboardHide", function()
	if !mapcontrol.IsInHub() then return end
	HideTime = CurTime()
end )
