AddCSLuaFile()

module( "jazzmoney", package.seeall )


local SharedPotConvar = CreateConVar("jazz_money_shared", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enable a shared money pot. "
    .. "Everything a player earns affects the whole group, that each player can decide how they spend it. "
    .. "If false, reverts to the traditional \"what you earn is what you spend\". "
    .. "A shared pot is more engaging for cooperative group play, but if ya'll want to hate eachother then go ahead, turn it off.")

local spentTblName= "players_spent"
local earnTblName = "players_earned"

if SERVER then
    local money = include("sql.lua")

    -- Create the shared nettables on player $
    local spentTbl = nettable.Create(spentTblName, nettable.TRANSMIT_AUTO, 1.0)
    local earnTbl = nettable.Create(earnTblName, nettable.TRANSMIT_AUTO, 1.0)

    -- Get the total amount of money that's been earned
    local cacheTotal = nil
    function GetTotal(ignoreCache)
        if not ignoreCache and cacheTotal then return cacheTotal end
        cacheTotal = money.GetTotalEarned()
        return cacheTotal
    end

    -- Force an update to make sure everyone's client numbers are accurate
    local function UpdateTotal()
        GetTotal(true)

        -- Update datatables on everyone
        for _, v in pairs(player.GetAll()) do
            v:RefreshNotes()
        end

        -- Update nettable for playercounts
        local allNotes = money.GetAllNotes()
        for _, v in pairs(allNotes) do
            earnTbl[v.steamid] = v.earned
            spentTbl[v.steamid] = v.spent
        end
    end

    -- Get per-player money info (earned/spent)
    function GetPlayerMoney(ply)
        return money.GetNotes(ply)
    end

    -- Get the total number of players that participated in this session
    function GetTotalPlayers()
        return money.GetTotalPlayers()
    end

    -- Player earned some money
    function AddNotes(ply, amt)
        if money.ChangeEarned(ply, math.max(0, amt)) then    
            UpdateTotal(amt) -- Refresh total $ cache
            return true
        end

        return false
    end

    -- Player spent some money
    function RemoveNotes(ply, amt)
        local num = GetNotes(ply)

        -- Not enough money
        if num < amt then return false end

        local ret = money.ChangeSpent(ply, math.max(0, amt))

        -- Update this person's spent table
        if ret then
            spentTbl[ply:SteamID64()] = GetPlayerMoney(ply).spent
        end

        return ret
    end

    -- Encapsulate AddNotes and RemoveNotes depending on if delta is positive or negative
    function ChangeNotes(ply, delta)
        if delta > 0 then
            return AddNotes(ply, delta)
        elseif delta < 0 then 
            return RemoveNotes(ply, math.abs(delta))
        end

        -- Change 0 does nothing
        return false
    end

    UpdateTotal()

    -- Lua refresh do a full total update
    cvars.AddChangeCallback(SharedPotConvar:GetName(), function()
        UpdateTotal() 
    end, "jazz_update_money")
end

AllPlayerMoney = AllPlayerMoney or {}
Total = Total or 0

-- Get note count for every single player
function GetAllNotes()
    return AllPlayerMoney
end

-- Whether or not the money is shared between players
function IsShared()
    return SharedPotConvar:GetBool()
end

-- Get how much money the given player has at their disposal
function GetNotes(ply)
    local mon = GetPlayerMoney(ply)
    local total = IsShared() and GetTotal() or (mon and mon.earned or 0)
    return total - (mon and mon.spent or 0)
end

if CLIENT then

    -- Get the total amount of money that's been earned
    function GetTotal()
        return Total
    end

    -- Get per-player money info (earned/spent)
    function GetPlayerMoney(ply)
        local id64 = isstring(ply) and ply or (IsValid(ply) and ply:SteamID64())
        return AllPlayerMoney[id64]
    end

end

-- Combine player earned and spent tables
local function updateEarned(changed, removed)
    local earnedTbl, spentTbl = nettable.Get(earnTblName), nettable.Get(spentTblName)
    local newTotal = 0
    for k, v in pairs(earnedTbl) do
        local earned, spent = earnedTbl[k], spentTbl[k]
        newTotal = newTotal + (earned or 0)

        if not earned or not spent then continue end

        AllPlayerMoney[k] = AllPlayerMoney[k] or {}
        AllPlayerMoney[k].earned = earned
        AllPlayerMoney[k].spent = spent
    end

    Total = newTotal
end

nettable.Hook(earnTblName, "jazzUpdateEarned", updateEarned)
nettable.Hook(spentTblName, "jazzUpdateEarned", updateEarned)
