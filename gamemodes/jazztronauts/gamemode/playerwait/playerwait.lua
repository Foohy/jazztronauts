AddCSLuaFile()

local tblName = "all_players"

function GM:IsWaitingForPlayers()
    return Entity(0):GetNWBool("JazzWaitingForPlayers")
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
        PrintTable(data)
        playerList[util.SteamIDTo64(data.networkid)] = data.name
    end )

    -- Hook into player disconnect
    gameevent.Listen("player_disconnect")
    hook.Add("player_disconnect", "JazzAllPlayersRemove", function(data)
        print("PLAYER DISCONNECT =========================")
        PrintTable(data)
        playerList[util.SteamIDTo64(data.networkid)] = nil
    end )

    -- Check if there are players still in the process of connecting
    local function PlayersStillConnecting()
        return table.Count(playerList) > player.GetCount() or player.GetCount() == 0
    end

    local function mergePlayers(dest, players)
        for k, v in pairs(players) do
            dest[v:SteamID64()] = v:GetName()
        end
    end

    function playerwait.SavePlayers()
        print("=========== SAVE PLAYERS")
        mergePlayers(playerList, player.GetAll()) -- Just in case
        PrintTable(playerList)
        print("-----------------------------")
        playerwait.SetPlayers(playerList)
        PrintTable(playerList)
    end

    -- Call when the map has officially been started
    -- Runs a map cleanup, causes shards to generate, and props to get their value assigned
    function GM:StartMap()
        Entity(0):SetNWBool("JazzWaitingForPlayers", false)

        hook.Run("JazzMapStarted")
    end

    hook.Add("InitPostEntity", "JazzWaitPlayersThinkInit", function()

        -- Start waiting for players
        Entity(0):SetNWBool("JazzWaitingForPlayers", true)

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

end