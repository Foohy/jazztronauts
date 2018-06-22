AddCSLuaFile()

local tblName = "all_players"

function GM:IsWaitingForPlayers()
    return not Entity(1):GetNWBool("JazzMapStarted")
end

function GM:GetConnectingPlayers()
    local playerList = table.Copy(nettable.Get(tblName))
    if not playerList then return {} end

    for _, v in pairs(player.GetAll()) do
        playerList[v:SteamID64()] = nil
    end

    return playerList
end


if SERVER then

    nettable.Create(tblName)

    local playerList = nettable.Get(tblName)

    -- Hook into player connect
    gameevent.Listen("player_connect")
    hook.Add("player_connect", "JazzAllPlayersAdd", function(data)
        playerList[data.networkid] = data.name
    end )

    -- Hook into player disconnect
    gameevent.Listen("player_disconnect")
    hook.Add("player_disconnect", "JazzAllPlayersRemove", function(data)
        playerList[data.networkid] = nil
    end )

    -- Check if there are players still in the process of connecting
    local function PlayersStillConnecting()
        print(#playerList)
        return table.Count(playerList) > player.GetCount() or player.GetCount() == 0
    end

    -- Call when the map has officially been started
    -- Runs a map cleanup, causes shards to generate, and props to get their value assigned
    function GM:StartMap()
        Entity(1):SetNWBool("JazzMapStarted", true)

        hook.Run("JazzMapStarted")
    end

    -- SetNW* functions don't actually set too early in the process
    -- I don't feel like slamming DTVars on some ent or using the net lib, but jeeze man
    local function ReadyToStart()
        Entity(1):SetNWBool("JazzReadyToStart", true)
        return Entity(1):GetNWBool("JazzReadyToStart")
    end

    hook.Add("InitPostEntity", "JazzWaitPlayersThinkInit", function()
        hook.Add("Think", "JazzWaitingForPlayersThink", function()
            if PlayersStillConnecting() then return end
            if not ReadyToStart() then return end
            //if CurTime() < 10 then return end

            GAMEMODE:StartMap()
            hook.Remove("Think", "JazzWaitingForPlayersThink")
        end )
    end )

else
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

	    draw.SimpleText("WAITING FOR PLAYERS", "JazzIntermissionCountdown", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local num = 1
        for _, v in pairs(GAMEMODE:GetConnectingPlayers()) do
            local w, h = surface.GetTextSize(v)
	        draw.SimpleText(v, "JazzIntermissionCountdown", ScrW() / 2, ScrH() / 2 + h * num, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            num = num + 1
        end
    end)

end