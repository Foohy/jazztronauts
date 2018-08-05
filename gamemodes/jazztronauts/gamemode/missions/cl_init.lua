include("missions.lua")
include("converse.lua")

local function getNPCId(mid)
	local mid = tonumber(mid)
	if not mid then return -1 end

	local npc = dialog.GetFocus()
	if not IsValid(npc) or not npc.GetNPCID then return -1 end

	return mid + npc:GetNPCID() * 1000
end

dialog.RegisterFunc("start", function(d, id)
	local mid = getNPCId(id)
	missions.TryStartMission(mid)
end )

dialog.RegisterFunc("finish", function(d, id)
	local mid = getNPCId(id)
	missions.TryFinishMission(mid)
end )