include("playerwait.lua")

surface.CreateFont( "JazzWaitingCountdown", {
    font      = "KG Shake it Off Chunky",
    size      = ScreenScale(32),
    weight    = 700,
    antialias = true
})

surface.CreateFont( "JazzWaitingCountdownPlayer", {
    font      = "KG Shake it Off Chunky",
    size      = ScreenScale(20),
    weight    = 700,
    antialias = true
})


-- Clientside hook for when map starts
hook.Add("Think", "JazzCheckWaitingForPlayersThink", function()
    if not GAMEMODE:IsWaitingForPlayers() then
        hook.Run("JazzMapStarted")
        hook.Remove("Think", "JazzCheckWaitingForPlayersThink")
        GAMEMODE.JazzHasStartedMap = true
    end
end )


hook.Add("HUDPaint", "JazzTemporaryWaitingForPlayersVisuals", function()
    if not GAMEMODE:IsWaitingForPlayers() then return end

    draw.SimpleText("WAITING FOR PLAYERS", "JazzWaitingCountdown", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local w, h = surface.GetTextSize("W")
    local offset = h
    local num = 0
    for k, v in pairs(GAMEMODE:GetConnectingPlayers()) do
        local w, h = surface.GetTextSize(v)
        draw.SimpleText(v, "JazzWaitingCountdownPlayer", ScrW() / 2, ScrH() / 2 + h * num + offset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        num = num + 1
    end

    local endtime = GAMEMODE:GetEndWaitTime()
    print(endtime)
    if endtime < math.huge then
    	local time = math.max(0, math.Round(endtime - CurTime() + 1))
    	draw.SimpleText(time, "JazzWaitingCountdownPlayer", ScrW() / 2, ScrH() / 2 + offset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
