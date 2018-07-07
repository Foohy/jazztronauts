AddCSLuaFile()

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
    
    local countdownConvar = CreateConVar("jazz_wait_countdowntime", "15", FCVAR_ARCHIVE, 
        "Once enough players have joined, how many seconds of countdown before we begin.")

    local shouldWaitConvar = CreateConVar("jazz_wait_enable", "1", FCVAR_ARCHIVE, 
            "Should we bother waiting for players to join, or just jump straight into the game.")
        
    concommand.Add("jazz_wait_force", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GAMEMODE.JazzForceNoWait = true
    end )

    nettable.Create(tblName)
    local playerList = nettable.Get(tblName)
    local tempPlayers = {}

    -- You might be asking wtf
    -- I want to network a SINGLE float, and DTvars/net library is overkill
    -- and SetNW* is crazy unreliable, the client keeps stale values for some reason here
    -- So screw it, we'll just use an existing library that does basically the same thing
    nettable.Create(datatblName)

    -- Hook into player connect
    gameevent.Listen("player_connect")
    hook.Add("player_connect", "JazzAllPlayersAdd", function(data)
        playerList[util.SteamIDTo64(data.networkid)] = data.name
        tempPlayers[util.SteamIDTo64(data.networkid)] = nil
    end )

    -- Hook into player disconnect
    gameevent.Listen("player_disconnect")
    hook.Add("player_disconnect", "JazzAllPlayersRemove", function(data)
        playerList[util.SteamIDTo64(data.networkid)] = nil
        tempPlayers[util.SteamIDTo64(data.networkid)] = nil
    end )

    -- Hook into player spawn, to mark temp players as no longer temporary
    hook.Add("PlayerInitialSpawn", "JazzUnmarkTempPlayer", function(ply)
        tempPlayers[ply:SteamID64() or "0"] = nil
    end)

    -- Check if there are players still in the process of connecting
    local function PlayersStillConnecting()
        return table.Count(playerList) > player.GetCount() or player.GetCount() == 0
    end

    function GM:ShouldWaitForPlayers()

        -- Don't wait while in hub
        if mapcontrol.IsInHub() then return false end

         -- Don't bother waiting for 1 person 
        if player.GetCount() == 1 and table.Count(playerList) <= 1 then return false end

        -- Manual override
        if self.JazzForceNoWait then return false end

        return shouldWaitConvar:GetBool() 
    end

    function GM:EnoughPlayersToStart()
        if PlayersStillConnecting() then return false end

        return true
    end

    local function mergePlayers(dest, players)
        for k, v in pairs(players) do
            dest[v:SteamID64()] = v:GetName()
        end
    end

    local function removeByKeys(dest, removeKeys)
        for k, _ in pairs(dest) do
            if removeKeys[k] then dest[k] = nil end
        end
    end

    -- Save current players (active + connecting) to persistent storage
    -- Called when the level changes so we know who's connecting after the changelevel
    function playerwait.SavePlayers()
        local players = table.Copy(playerList)
        
        -- Ensure nothing slipped through the cracks
        mergePlayers(players, player.GetAll())

        -- Don't save "temporary" players.
        -- These are players that were connecting for over a whole map but never successfully joined
        removeByKeys(players, tempPlayers)

        playerwait.SetPlayers(players)
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
        tempPlayers = playerwait.GetPlayers()
        table.Merge(playerList, tempPlayers)
        playerwait.ClearPlayers()

        hook.Add("Think", "JazzWaitingForPlayersThink", function()
            local botherWaiting = gamemode.Call("ShouldWaitForPlayers")

            if botherWaiting then 

                -- If not enough players to start, delay and try again later
                if not gamemode.Call("EnoughPlayersToStart") then
                    GAMEMODE:SetEndWaitTime(math.huge)
                    GAMEMODE.WaitQueued = false
                    return 
                end
            end

            -- Start countdown
            if botherWaiting and not GAMEMODE.WaitQueued then
                GAMEMODE.WaitQueued = true
                GAMEMODE:SetEndWaitTime(CurTime() + countdownConvar:GetFloat())
            end

            -- Countdown over, start the map and stop thinking 
            if not botherWaiting or not GAMEMODE:IsWaitingForPlayers() then
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