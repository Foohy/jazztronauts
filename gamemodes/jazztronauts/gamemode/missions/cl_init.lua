include("missions.lua")

dialog.RegisterFunc("start", function(id)
    local mid = tonumber(id) or -1
	missions.TryStartMission(mid)
end )

dialog.RegisterFunc("finish", function(id)
    local mid = tonumber(id) or -1
	missions.TryFinishMission(mid)
end )