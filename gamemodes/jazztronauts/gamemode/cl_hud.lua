//Draws the dynamic money counter

include("jazz_localize.lua")

//MODIFIABLES
local HideDelay = 2 //How many seconds to show the amt after it is done filling the counter?
local FillDelay = propfeed.StayDuration //Number of seconds before the money can begin filling
local FadeSpeed = 900 //How fast to fade out

local distFromSide = ScreenScale(6)
local coinDistance = ScreenScale(32)
local coinSize = ScreenScale(20)
local distFromTop = ScreenScale(7)

//NON-MODIFIABLES
local bgWidth = 15
local lastWidth = 1
local CurAlpha = 200
local VisualAmount = 0
local HideTime = mapcontrol.IsInHub() and math.huge or 0
local moneyFillDelay = 0 //Delay before the money begin filling into the main dude
local moneyFillVelocity = 1 //Amount of money to fill per frame. Adjusted based on how many money to fill
local lastMoneyCount = -1
local isFadingOut = false

local catcoin = Material("materials/ui/jazztronauts/catcoin.png", "smooth")

surface.CreateFont( "JazzNote",
{
	font		= "KG Shake it Off Chunky Mono",
	size		= ScreenScale(20),
	weight		= 1500
})
surface.CreateFont( "JazzNoteFill",
{
	font		= "KG Shake it Off Chunky Mono",
	size		= ScreenScale(12),
	weight		= 500,
	antialias	= true
})
surface.CreateFont( "JazzNoteMultiplier",
{
	font		= "KG Shake it Off Chunky",
	size		= ScreenScale(12),
	weight		= 1500,
	antialias	= true
})
surface.CreateFont( "JazzBlackShard",
{
	font		= "Palatino Linotype",
	size		= ScreenScale(20),
	weight		= 1500
})

local function drawTextRotated(text, font, x, y, color, rotation, maxWidth)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)
	local actualWidth = math.cos(math.rad(rotation)) * w
	local scaleMult = math.min(1, maxWidth / actualWidth)

	local rotMat = Matrix()
	rotMat:Translate(Vector(x, y, 0))
	rotMat:Rotate(Angle(0, rotation, 0))
	rotMat:Scale(Vector(1, 1, 1) * scaleMult)
	rotMat:Translate(Vector(-x, -y, 0))


	cam.PushModelMatrix(rotMat)
		surface.SetTextColor(color)
		surface.SetTextPos(x - w/2, y - h/2)
		surface.DrawText(text)
	cam.PopModelMatrix()
end

local function DrawNoteCount()
	local amt = LocalPlayer() and LocalPlayer():GetNotes() or 0

	--fix just loading in
	if lastMoneyCount < 0 and amt ~= 0 then
		lastMoneyCount = amt
		VisualAmount = amt
	end

	if amt ~= lastMoneyCount then
		-- Only delay if earning money
		if amt > lastMoneyCount then
			moneyFillDelay = CurTime() + FillDelay:GetFloat()
		end

		lastMoneyCount = amt
	end
	if amt ~= VisualAmount then
		HideTime = CurTime() + HideDelay
	end

	if CurTime() > HideTime and CurAlpha <= 0 then return //Don't draw if the alpha is 0
	elseif CurTime() > HideTime then
		CurAlpha = math.Clamp(CurAlpha - (FrameTime() * FadeSpeed ), 0, 255 )
	else
		CurAlpha = 200
	end

	-- Current multiplier for all earned money
	local noteMultiplier = newgame.GetMultiplier()
	local finalText = JazzLocalize("jazz.hud.money",string.Comma( VisualAmount ))

	surface.SetFont( "JazzNote")
	bgWidth, bgHeight = surface.GetTextSize( finalText )

	lastWidth = Lerp( FrameTime() * 10, lastWidth, bgWidth + coinSize + ScreenScale(13) )
	draw.RoundedBox( 4, ScrW() - (distFromSide + lastWidth), distFromTop, lastWidth, bgHeight, Color( 0, 0, 0, CurAlpha ) )

	//Draw how many money we have
	local FinalAmountText = {}
	FinalAmountText["pos"] = { ScrW() - distFromSide - coinSize - ScreenScale(10), distFromTop }
	FinalAmountText["color"] = Color(255, 255, 255, CurAlpha)
	FinalAmountText["text"] = finalText
	FinalAmountText["font"] = "JazzNote"
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

	if amt - VisualAmount ~= 0 then
		draw.DrawText( text, "JazzNoteFill", ScrW() - distFromSide, bgHeight + ScreenScale(6), color, TEXT_ALIGN_RIGHT)
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

	-- Draw Cat Coin
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(catcoin)
	surface.DrawTexturedRect(ScrW() - coinDistance, distFromTop, coinSize, coinSize)

	-- Draw extra money multiplier
	if noteMultiplier > 1 then
		local multCol = Color(108, 52, 0, 250)
		drawTextRotated(noteMultiplier, "JazzNoteMultiplier",
			ScrW() - coinDistance / 2 - distFromSide, distFromTop + coinSize / 2 - ScreenScale(1),
			multCol, 0, coinSize/1.3)
	end

end

local function DrawBlackShardCount()
	if mapcontrol.IsInGamemodeMap() then return end
	if GAMEMODE:IsWaitingForPlayers() then return end

	local bshard = IsValid(bshard) and bshard or ents.FindByClass("jazz_shard_black")[1]
	if not IsValid(bshard) or not bshard.GetStartSuckTime then return end

	local sucktime = bshard:GetStartSuckTime()
	local left, total = sucktime > 0 and sucktime < CurTime() and 0 or 1, 1
	local str = JazzLocalize("jazz.shards.one")
	local color = Color(100, 100, 100, 100)
	if left == 0 then
		color = Color(200, 10, 10)
		str = JazzLocalize("jazz.shards.none")
	end

	surface.SetFont("JazzBlackShard")
	local offset = surface.GetTextSize(str) / 2
	offset = offset + 5
	draw.WordBox( 5, ScrW() / 2 - offset, 5, str, "JazzBlackShard", color, color_white )
end

local function DrawShardCount()
	if mapcontrol.IsInGamemodeMap() then return end
	if GAMEMODE:IsWaitingForPlayers() then return end

	local left, total = mapgen.GetShardCount()
	local str = JazzLocalize("jazz.shards.partialcollected",total - left,total)
	local color = Color(143, 0, 255, 100)
	if left == 0 then
		str = JazzLocalize("jazz.shards.all",total)
		color = HSVToColor(math.fmod(CurTime() * 360, 360), .3, .7)
	end

	surface.SetFont("JazzNote")
	local offset = surface.GetTextSize(str) / 2
	offset = offset + 5
	draw.WordBox( 5, ScrW() / 2 - offset, 5, str, "JazzNote", color, color_white )

end

hook.Add("HUDPaint", "JazzDrawHUD", function()
	if !GetConVar("cl_drawhud"):GetBool() then return end
	DrawNoteCount()

	local isCommitted = mapgen.GetTotalCollectedBlackShards() > mapgen.GetTotalRequiredBlackShards() / 2
	if isCommitted then
		DrawBlackShardCount()
	else
		DrawShardCount()
	end

	-- Always show the moneybux in the hub
	if mapcontrol.IsInHub() then
		HideTime = math.huge
	end

end )

//Show the money count when pressing tab
hook.Add( "ScoreboardShow", "jazz_scoreboardShow", function()
	HideTime = math.huge
end )
hook.Add("ScoreboardHide", "jazz_scoreboardHide", function()
	if mapcontrol.IsInHub() then return end
	HideTime = CurTime()
end )
