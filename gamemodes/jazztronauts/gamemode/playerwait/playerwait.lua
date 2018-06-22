AddCSLuaFile()

local tblName = "all_players"

function GM:IsWaitingForPlayers()
    return not Entity(0):GetNWBool("JazzMapStarted")
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
        print("PLAYER CONNECT ============================")
        playerList[data.networkid] = true
    end )

    -- Hook into player disconnect
    gameevent.Listen("player_disconnect")
    hook.Add("player_disconnect", "JazzAllPlayersRemove", function(data)
        print("PLAYER DISCONNECT =========================")
        playerList[data.networkid] = nil
    end )

    -- Check if there are players still in the process of connecting
    local function PlayersStillConnecting()
        return table.Count(playerList) > player.GetCount() or player.GetCount() == 0
    end

    local function mergePlayers(dest, players)
        for k, v in pairs(players) do
            dest[v:SteamID64()] = true
        end
    end

    function playerwait.SavePlayers()
        mergePlayers(playerList, player.GetAll()) -- Just in case
        playerwait.SetPlayers(playerList)
    end

    -- Call when the map has officially been started
    -- Runs a map cleanup, causes shards to generate, and props to get their value assigned
    function GM:StartMap()
        Entity(0):SetNWBool("JazzMapStarted", true)

        hook.Run("JazzMapStarted")
    end

    hook.Add("InitPostEntity", "JazzWaitPlayersThinkInit", function()
        -- Load in a previous playerlist if we just changed level
        table.Merge(playerList, playerwait.GetPlayers())
        playerwait.ClearPlayers()

        hook.Add("Think", "JazzWaitingForPlayersThink", function()
            if not mapcontrol.IsInHub() then 
                if PlayersStillConnecting() then return end
                if CurTime() < 20 then return end
            end

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