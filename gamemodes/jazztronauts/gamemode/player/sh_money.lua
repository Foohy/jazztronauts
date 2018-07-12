AddCSLuaFile()

module( "jazzmoney", package.seeall )


local SharedPotConvar = CreateConVar("jazz_money_shared", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enable a shared money pot. "
    .. "Everything a player earns affects the whole group, that each player can decide how they spend it. "
    .. "If false, reverts to the traditional \"what you earn is what you spend\". "
    .. "A shared pot is more engaging for cooperative group play, but if ya'll want to hate eachother then go ahead, turn it off.")

if SERVER then
    local money = include("sql.lua")

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

        for _, v in pairs(player.GetAll()) do
            v:RefreshNotes()
        end
    end

    -- Whether or not the money is shared between players
    function IsShared()
        return SharedPotConvar:GetBool()
    end

    -- Get note count for every single player
    function GetAllNotes()
        return money.GetAllNotes()
    end

    -- Get how much money the given player has at their disposal
    function GetNotes(ply)
        local mon = money.GetNotes(ply)
        local total = IsShared() and GetTotal() or (mon and mon.earned or 0)
        return total - (mon and mon.spent or 0)
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

        return money.ChangeSpent(ply, math.max(0, amt))
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


    -- Lua refresh do a full total update
    cvars.AddChangeCallback(SharedPotConvar:GetName(), function()
        UpdateTotal() 
    end, "jazz_update_money")

end
