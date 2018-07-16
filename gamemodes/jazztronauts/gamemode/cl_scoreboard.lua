-- TODO

if SERVER then return end

local start = CurTime()
local draw_charts = false

local test_values = {
	{"Foohy", 1000, 40},
	{"Matt", 950, 40},
	{"Mr. Sunabouzu", 180, 100},
	{"Shitlord", 500, 450},
	{"My Left Nipple", 800, 700},
	{"FUCK", 100, 10},
}

hook.Add("HUDPaint", "graph_test", function()

	if not draw_charts then return end

	local values = {}
	for k, v in pairs( player.GetAll() ) do
		local money = jazzmoney.GetPlayerMoney(v)
		if money then
			table.insert(values, {
				v:GetName(),
				money.earned,
				money.spent,
			})
		else
			table.insert(values, {
				v:GetName(),
				0,
				0,
			})
		end
	end

	local scr = Rect("screen")
	local cx, cy = scr:GetCenter()

	local duration = 4
	local dt = math.max(math.min((CurTime() - (start+.1) ) / duration, 1), 0)
	local dt2 = math.max(math.min((CurTime() - (start+.2) ) / duration, 1), 0)

	local bounce = Bounce(dt,.25,1.8,.6)
	local bounce2 = Bounce(dt2,.25,1.8,.6)

	--drawPieElement( cx, cy, 0, 120, 100 )

	graph.drawPieChart( cx, cy-200, 80, values, 1-bounce, 2, function(v) return v[1] .. " earned $" .. v[2] end )
	graph.drawPieChart( cx, cy+200, 80, values, 1-bounce2, 3, function(v) return v[1] .. " spent $" .. v[3] end )

end)

function GM:ScoreboardHide()

end

function GM:ScoreboardShow()

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
