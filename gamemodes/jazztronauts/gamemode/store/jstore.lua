AddCSLuaFile("jstore.lua")

module( "jstore", package.seeall )

/* properties layout = 
{
    price = 100,
    cat = "upgrades",
    name = "Stan Upgrade",
    [requires = "stan"] -- unlock that must be purchased before this one is available
}
*/

local list_name = "store"
unlocks.Register(list_name)

-- Register name and pricing information with a specific unlock
function Register(unlockName, price, props)
    if not Items then Items = {} end
    props = props or {}
    props.price = price
    props.unlock = unlockName -- For completeness

    Items[unlockName] = props

    return unlockName
end

-- Register a 'series' of purchases. These are unlocks that directly have the previous
-- Unlock as a prerequisite. Useful for similar upgrades that keep affecting the same property
-- eg. "Stan Range Upgrade I", "Stan Range Upgrade II", "Stan Range Upgrade III"
function RegisterSeries(baseUnlockName, basePrettyName, basePrice, category, req, count)
    if not Series then Series = {} end
    Series[baseUnlockName] = {}

    for i=1, count do
        local unlock = baseUnlockName .. i
        local props = { 
            name = basePrettyName .. " - " .. i,
            category = category,
            requires = req,
            level = i,
            baseseries = baseUnlockName
        }

        -- Add a new unique item and store in repeats table for fast lookup
        req = Register(unlock, basePrice, props)
        table.insert(Series[baseUnlockName], req)
    end

    return baseUnlockName
end

-- For items registered above, get the highest level that has been purchased by the 
-- given player. Returns 0 for none purchased, 1 for only level 1, etc.
-- Makes slightly more sense to be in unlocks, but this works fine too
function GetSeries(ply, unlockName)

    -- Lookup list of repeated items
    if not Series[unlockName] then return 0 end

    -- Step through it backwards. Highest purchase found is their unlock level
    for i = #Series[unlockName], 1, -1 do
        if unlocks.IsUnlocked(list_name, ply, Series[unlockName][i]) then
            return i
        end
    end

    return 0
end

-- Get the 'base' name for a repeating item, given one of the series
function GetSeriesBase(unlockName)
    local itm = GetItem(unlockName)
    print(itm, unlockName)
    return itm and itm.baseseries or nil
end

-- Get a list of all registered store items
function GetItems()
    if not Items then return {} end

    return Items 
end

-- Get information about a specific item by name
function GetItem(name)
    if not name or not Items then return nil end

    return Items[name]
end

-- Query if a specific item is available for purchase
function IsAvailable(ply, name)
    local itm = GetItem(name)

    if not itm then return false end
    if not itm.requires then return true end -- No ownership requirements

    -- "requires" can either be a plain string, indicating only a single prerequisite item
    if type(itm.requires) == "string" then
        return unlocks.IsUnlocked(list_name, ply, itm.requires)

    -- Or it can be an table of strings, indicating multiple prerequisite items
    elseif type(itm.requires) == "table" then
        for _, v in pairs(itm.requires) do
            if not unlocks.IsUnlocked(list_name, ply, v) then 
                return false 
            end
        end

        return true 
    end

    return false
end

if SERVER then
    util.AddNetworkString( "jazz_store_purchase" )

    -- Purchase a single item, given its full unlock name
    -- Ensure the item is available, the player has enough money, and that
    -- they haven't already purchased it
    function PurchaseItem(ply, unlockName)
        if not IsValid(ply) or not unlockName then return false end
        
        local item = GetItem(unlockName)
        if not item then return false end
        if not IsAvailable(ply, unlockName) then return false end

        -- Check the player has enough money
        if ply:GetNotes() < item.price then return false end

        -- On successful unlock, decrement money
        if unlocks.Unlock(list_name, ply, unlockName) then
            ply:ChangeNotes(-item.price)
            return true
        end

        return false
    end

    net.Receive("jazz_store_purchase", function(len, ply)
        local item = net.ReadString()

        if IsValid(ply) then 
            local success = PurchaseItem(ply, item)

            -- Write the response
            net.Start("jazz_store_purchase")
                net.WriteString(item)
                net.WriteBool(success)
            net.Send(ply)
        end

    end )
end
if CLIENT then
    local callbacks = {}

    local function addCallback(unlock, func)
        if not func then return end

        callbacks[unlock] = callbacks[unlock] or {}
        table.insert(callbacks[unlock], func)
    end

    local function runCallbacks(unlock, response)
        if not callbacks[unlock] then return end 

        -- Execute all callbacks associated with this item
        -- informing of whether the purchase was successful
        for _, v in pairs(callbacks[unlock]) do
            v(response)
        end

        -- Clear out the one-time callbacks
        callbacks[unlock] = nil 
    end

    -- From the client, indicate to the server that we would like
    -- to purchase a specific item. This accepts a callback function that is ran when the
    -- server responds, along with a status indicator
    function PurchaseItem(unlockName, callback)
        if not unlockName then return false end
        
        local item = GetItem(unlockName)
        if not item then return false end

        addCallback(unlockName, callback)
        
        net.Start("jazz_store_purchase")
            net.WriteString(unlockName)
        net.SendToServer()
    end

    -- Listen for item purchase callbacks
    net.Receive("jazz_store_purchase", function()
        local item = net.ReadString()
        local success = net.ReadBool()

        runCallbacks(item, success)
    end )
end