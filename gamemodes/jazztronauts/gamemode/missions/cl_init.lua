include("missions.lua")

dialog.RegisterFunc("start", function(d, id)
    local mid = tonumber(id) or -1
	missions.TryStartMission(mid)
end )

dialog.RegisterFunc("finish", function(d, id)
    local mid = tonumber(id) or -1
	missions.TryFinishMission(mid)
end )