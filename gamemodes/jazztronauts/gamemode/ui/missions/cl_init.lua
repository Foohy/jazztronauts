
surface.CreateFont( "Mission_ProgressPercent", {
	font = "KG Shake it Off Chunky",
	extended = false,
	size = ScreenScale(10),
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

surface.CreateFont( "Mission_Description", {
	font = "Verdana",
	extended = false,
	size = ScreenScale(7),
	weight = 1000,
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

local function drawProgressBar(m, x, y, width, height, prog, max, animclip)
	local perc = prog * 1.0 / max

	local flash = CurTime() - (m.progbump or 0)
	local flash2 = .5 + math.sin(8 * (flash-.5) * math.pi)/2
	if flash > 1 then flash2 = 0 else flash2 = flash2 * (1 - flash) end

	perc = math.max( perc - (1/max) * flash2 * flash2, 0 )
	perc = math.min( perc, 1 )

	if perc < 1.0 then
		draw.RoundedBox(4, x, y, width, height, Color(80, 0, 80))
	end
	if perc > 0 then
		draw.RoundedBox(4, x, y, width * perc, height, Color(255, 200, flash2*255))
	end

	local subclip = Rect(x,y,width,height)
	subclip.w = width*perc
	subclip:Clamp( animclip )
	subclip:SetClip(true)
	draw.SimpleText(prog .. "/" .. max, "Mission_ProgressPercent", x + width/2, y + height/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	subclip.x = x + width*perc
	subclip.w = width - width*perc
	subclip:Clamp( animclip )
	subclip:SetClip(true)
	draw.SimpleText(prog .. "/" .. max, "Mission_ProgressPercent", x + width/2, y + height/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local metrics = {
	width = ScreenScale(120),
	height = ScreenScale(20),
	spacing = ScreenScale(2),
}

local function IsFinished()

end

local tables = {}
local function MissionTable(mid)
	tables[mid] = tables[mid] or {}
	return tables[mid]
end

local function DrawMission(mission, x, y)
	local font = "Mission_Description"
	local mid = mission.missionid
	local m = MissionTable(mid)
	local width = metrics.width
	local height = metrics.height
	local minfo = missions.GetMissionInfo(mid)

	if mission.progress ~= m.prev_progress then
		m.prev_progress = mission.progress
		m.progbump = CurTime()
	end

	local bumpdt = 1-math.min( CurTime() - (m.progbump or 0), 1 )
	bumpdt = bumpdt * bumpdt
	height = height + bumpdt * 10

	y = y - height

	local rect = Rect(x,y,width,height)

	m.opentimer = m.opentimer or CurTime()
	local duration = .35
	local dt = math.min( (CurTime() - m.opentimer) / duration, 1 )

	dt = math.sin( dt * math.pi/2 )

	local animclip = Rect( rect )
	animclip.w = animclip.w * dt
	animclip:SetClip(true)


	local tr = TextRect( minfo.Instructions, font ):Dock( rect, DOCK_TOP + DOCK_LEFT):Inset(ScreenScale(2))

	draw.RoundedBox(5, x, y, width, height, Color(255 - bumpdt*255, bumpdt*255, 255 - bumpdt*255, 50))
	draw.SimpleText(minfo.Instructions, font, tr.x, tr.y, Color(255 - bumpdt*255,255,255 - bumpdt*255))

	if not mission.completed then
		drawProgressBar(m, x + 5, y + height - 25, width-10, 20, missions.Active[mid], minfo.Count, animclip)
	elseif mission.completed then
		draw.SimpleText(jazzloc.Localize("jazz.mission.finished"), font, x + 5, y + 5 + 20, Color(255, 255, 0))
	else
		draw.SimpleText(jazzloc.Localize("jazz.mission.locked"), font, x + 5, y + 5 + 20, Color(200, 200, 200))
	end

	animclip:SetClip(false)

	return y - metrics.spacing
end

local ShowFinishedMissions = false
hook.Add("HUDPaint", "JazzDrawMissions", function()
	if jazzHideHUD then return end
	
	local spacing = ScreenScale(2)
	local offset = ScreenScale(40)
	local y = ScrH() - offset
	for k, v in pairs(missions.ClientMissionHistory) do
		if ( ShowFinishedMissions and v.completed ) or not v.completed then
			y = DrawMission(v, ScreenScale(12), y)
		elseif ( not ShowFinishedMissions and v.completed ) then
			v.timer = nil
		end
	end
end )

hook.Add( "ScoreboardShow", "jazz_showFinishedMissions", function()
	ShowFinishedMissions = true
end )
hook.Add("ScoreboardHide", "jazz_hideFinishedMissions", function()
	ShowFinishedMissions = false
end )
