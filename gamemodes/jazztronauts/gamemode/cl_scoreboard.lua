-- TODO

if SERVER then return end

local start = CurTime()
local draw_charts = false

surface.CreateFont( "JazzRespawnHint", {
	font	  = "KG Shake it Off Chunky",
	size	  = 30,
	weight	= 700,
	antialias = true
})

local Radius = ScreenScale(25)
local XOff = ScreenScale(220)
local YOff = ScreenScale(100)

local nameLookups = {}
local function getPlayerName(id64)
	local entry = nameLookups[id64]
	if entry and entry.name then return entry.name end

	if not entry then
		nameLookups[id64] = { name = jazzloc.Localize("jazz.hud.loading") }
		steamworks.RequestPlayerInfo(id64, function(plyName)
			nameLookups[id64].name = plyName or jazzloc.Localize("jazz.hud.unknown")
		end )
	end

	return nameLookups[id64].name
end

local function mergeFields(entry, data, ...)
	if type(data) == "table" then
		for _, field in pairs({ ... }) do
			entry[#entry + 1] = data[field]
		end
	else
		entry[#entry + 1] = data
	end
end

local function getLocalValues(src, ...)
	local values = {}
	for k, v in pairs( player.GetAll() ) do
		local data = src[v:SteamID64()]
		if data then
			local entry = { v:GetName() }
			mergeFields(entry, data, ...)

			values[#values + 1] = entry
		else
			table.insert(values, {
				v:GetName(),
				0,
				0,
			})
		end
	end

	return values
end

local function getGlobalValues(src, ...)
	local values = {}
	for k, v in pairs(src) do
		local entry = { getPlayerName(k) }
		mergeFields(entry, v, ...)

		values[#values + 1] = entry
	end

	return values
end

function getValues(global, src, ...)
	if global then
		return getGlobalValues(src, ...)
	else
		return getLocalValues(src, ...)
	end
end

hook.Add("HUDPaint", "graph_test", function()
	if not draw_charts then return end
	local showGlobal = input.IsMouseDown(MOUSE_RIGHT)

	local allMoney = jazzmoney.GetAllNotes()
	local moneyValues = getValues(showGlobal, allMoney, "earned", "spent")

	local shardValues = getValues(showGlobal, mapgen.GetPlayerShards())

	local scr = Rect("screen")
	local cx, cy = scr:GetCenter()

	local duration = 4
	local dt = math.max(math.min((CurTime() - (start+.1) ) / duration, 1), 0)
	local dt2 = math.max(math.min((CurTime() - (start+.2) ) / duration, 1), 0)

	local bounce = Bounce(dt,.25,1.8,.6)
	local bounce2 = Bounce(dt2,.25,1.8,.6)

	--drawPieElement( cx, cy, 0, 120, 100 )
	--PrintTable(shardValues)
	--PrintTable(moneyValues)
	graph.drawPieChart( cx + XOff, YOff, Radius, moneyValues, 1-bounce, 2, function(v) return jazzloc.Localize("jazz.hud.earned",v[1],v[2]) end )
	graph.drawPieChart( cx + XOff, YOff*2, Radius, moneyValues, 1-bounce2, 3, function(v) return jazzloc.Localize("jazz.hud.spent",v[1],v[3]) end )
	graph.drawPieChart( cx + XOff, YOff*3, Radius, shardValues, 1-bounce2, 2, function(v) return jazzloc.Localize("jazz.hud.found",v[1],v[2]) end )


	-- Also draw a little hint on how to kill themselves
	draw.SimpleText(jazzloc.Localize("jazz.hud.kys"), "JazzRespawnHint", ScrW()/2, ScrH() - ScreenScale(10), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)

function GM:ScoreboardHide()
	self.BaseClass.ScoreboardHide(self)
end

function GM:ScoreboardShow()
	self.BaseClass.ScoreboardShow(self)
end

hook.Add( "HUDDrawScoreboard", "graph_test", function()
	return true
end )

hook.Add( "ScoreboardShow", "graph_test", function()
	start = CurTime()
	draw_charts = true
end )
hook.Add("ScoreboardHide", "graph_test", function()
	draw_charts = false
end )

-- Handle letting them respawn by holding tab + m1 + m2
local function isHoldingCombo()
	return LocalPlayer():KeyDown(IN_SCORE) and
		input.IsMouseDown(MOUSE_LEFT) and
		input.IsMouseDown(MOUSE_RIGHT)
end

local buildupTime = 3
local comboTime = 0
local killsound = nil
local killed = false
hook.Add("Think", "RespawnKeyComboThink", function()
	local comboHeld = isHoldingCombo()
	if not comboHeld or killed then
		comboTime = 0
		if killsound then
			killsound:Stop()
			killsound = nil
		end

		-- Reset once they let go
		if not comboHeld then killed = false end

		return
	end
	if not killsound then
		killsound = CreateSound(Entity(0), "ambient/levels/labs/teleport_preblast_suckin1.wav")
		killsound:SetSoundLevel(0)
		killsound:PlayEx(1, 75)
	end

	local p = comboTime / buildupTime
	util.ScreenShake(LocalPlayer():GetPos(), p * 5, p * 5, 0.1, 256)

	comboTime = comboTime + FrameTime()
	if comboTime > buildupTime then
		RunConsoleCommand("kill")
		killed = true
		return
	end
end )