local function drawProgressBar(x, y, width, height, prog, max)
	local perc = prog * 1.0 / max

	if perc > 0 then 
		draw.RoundedBox(0, x, y, width * perc, height, Color(0, 200, 0))
	end
	if perc < 1.0 then 
		draw.RoundedBox(0, x + width * perc, y, width * (1 - perc), height, Color(100, 100, 100))
	end

	draw.SimpleText(prog .. "/" .. max, nil, x + width/2, y + height/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function DrawMission(mid, x, y)
	local minfo = missions.GetMissionInfo(mid)
	draw.RoundedBox(5, x, y, 200, 50, Color(255, 255, 255, 50))
	draw.SimpleText(minfo.Instructions, nil, x + 5, y + 5)

	if missions.Active[mid] then
		drawProgressBar(x + 5, y + 5 + 20, 190, 15, missions.Active[mid], minfo.Count)
	elseif missions.Finished[mid] then
		draw.SimpleText("FINISHED!!!", nil, x + 5, y + 5 + 20, Color(255, 255, 0))
	else
		draw.SimpleText("<Locked>", nil, x + 5, y + 5 + 20, Color(200, 200, 200))
	end
end

hook.Add("HUDPaint", "JazzDrawMissions", function()
	for k, v in pairs(missions.MissionList) do
		DrawMission(k, 5, ScrH() - (80 + k * 60))
	end
	
end )