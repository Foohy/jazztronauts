AddCSLuaFile()

GM.WaitForPlayersTime = 6 -- Countdown time for when everyone's ready to go

local tblName = "all_players"
local datatblName = "wait_time"

function GM:IsWaitingForPlayers()
    return self:GetEndWaitTime() > CurTime()
end

function GM:GetEndWaitTime()
    return (nettable.Get(datatblName) or {})["JazzWaitingForPlayers"] or 0
end

function GM:SetEndWaitTime(time)
    nettable.Get(datatblName)["JazzWaitingForPlayers"] = time
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

    -- You might be asking wtf
    -- I want to network a SINGLE float, and DTvars/net library is overkill
    -- and SetNW* is crazy unreliable, the client keeps stale values for some reason here
    -- So screw it, we'll just use an existing library that does basically the same thing
    nettable.Create(datatblName)

    -- Hook into player connect
    gameevent.Listen("player_connect")
    hook.Add("player_connect", "JazzAllPlayersAdd", function(data)
        playerList[util.SteamIDTo64(data.networkid)] = data.name
    end )

    -- Hook into player disconnect
    gameevent.Listen("player_disconnect")
    hook.Add("player_disconnect", "JazzAllPlayersRemove", function(data)
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

    -- Save current players (active + connecting) to persistent storage
    -- Called when the level changes so we know who's connecting after the changelevel
    function playerwait.SavePlayers()
        mergePlayers(playerList, player.GetAll()) -- Just in case
        playerwait.SetPlayers(playerList)
    end

    -- Call when the map has officially been started
    -- Runs a map cleanup, causes shards to generate, and props to get their value assigned
    function GM:StartMap()
        GAMEMODE:SetEndWaitTime(0)
        hook.Run("JazzMapStarted")
    end

    hook.Add("InitPostEntity", "JazzWaitPlayersThinkInit", function()

        -- Start waiting for players
        GAMEMODE:SetEndWaitTime(math.huge)

        -- Load in a previous playerlist if we just changed level
        table.Merge(playerList, playerwait.GetPlayers())
        playerwait.ClearPlayers()

        hook.Add("Think", "JazzWaitingForPlayersThink", function()
            if not mapcontrol.IsInHub() then 
                if PlayersStillConnecting() then
                    GAMEMODE:SetEndWaitTime(math.huge)
                    GAMEMODE.WaitQueued = false
                    return 
                end
            end

            -- Start countdown
            if not GAMEMODE.WaitQueued then
                GAMEMODE.WaitQueued = true
                GAMEMODE:SetEndWaitTime(CurTime() + GAMEMODE.WaitForPlayersTime)
            end

            -- Countdown over, start the map and stop thinking 
            if not GAMEMODE:IsWaitingForPlayers() then
                GAMEMODE:StartMap()
                hook.Remove("Think", "JazzWaitingForPlayersThink")
            end
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

end