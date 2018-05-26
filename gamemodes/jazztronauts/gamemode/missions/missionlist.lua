module( "missions", package.seeall )

ResetMissions()

NPC_COMPUTER = 666
AddNPC("NPC_CAT_BAR", "Bartender")
AddNPC("NPC_CAT_SING", "Singer")
AddNPC("NPC_CAT_PIANO", "Piano Man")
AddNPC("NPC_CAT_CELLO", "Cellist")

-- Utility function for giving a player a monetary reward
local function GrantMoney(amt)
    return function(ply)
        ply:ChangeNotes(amt)
    end
end

-- Utility function for unlocking something for the player
local function UnlockItem(lst, unlock)
    return function(ply)
        unlocks.Unlock(lst, ply, unlock)
    end
end

-- Combine multiple rewards
local function MultiReward(...)
    local funcs = {...}
    return function(ply)
        for _, v in pairs(funcs) do
            v(ply)
        end
    end
end

AddMission(0, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Collect 15 oil drums",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return mdl == "models/props_c17/oildrum001_explosive.mdl" or
        mdl == "models/props_c17/oildrum001.mdl" or
        mdl == "models/props_phx/oildrum001_explosive.mdl" or
        mdl == "models/props_phx/oildrum001.mdl"
    end,

    -- They need to collect 15 of em' to complete the mission.
    Count = 15,

    -- ID of the NPC that offers this mission
    NPCId = NPC_CAT_CELLO,

    -- List of all missions that needs to have been completed before this one becomes available
    -- Leave empty to be available immediately
    Prerequisites = nil,

    -- When they finish the mission, this function is called to give out a reward
    -- The 'GrantMoney' function returns a function that gives money
    OnCompleted = GrantMoney(1500)
})

AddMission(1, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Collect 10 gas cans and beer bottles",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return mdl == "models/props_junk/gascan001a.mdl" or
        mdl == "models/props_c17/oildrum001_explosive.mdl" or
        mdl == "models/props_junk/propane_tank001a.mdl" or
        mdl == "models/props_phx/oildrum001_explosive.mdl"
    end,

    -- They need to collect 10 of em' to complete the mission.
    Count = 10,

    -- ID of the NPC that offers this mission
    NPCId = NPC_CAT_CELLO,

    -- List of all missions that needs to have been completed before this one becomes available
    Prerequisites = { 0 },

    -- When they finish the mission, this function is called to give out a reward
    -- The 'GrantMoney' function returns a function that gives money
    OnCompleted = GrantMoney(1500)
})

AddMission(2, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Collect 5 paintcans",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return mdl == "models/props_junk/metal_paintcan001a.mdl" or
        mdl == "models/props_junk/metal_paintcan001b.mdl" or
        mdl == "models/props/cs_militia/paintbucket01.mdl"
    end,

    -- They need to collect 1 of em' to complete the mission.
    Count = 5,

    -- ID of the NPC that offers this mission
    NPCId = NPC_CAT_CELLO,

    -- List of all missions that needs to have been completed before this one becomes available
    Prerequisites = { 1 },

    -- When they finish the mission, this function is called to give out a reward
    -- The 'GrantMoney' function returns a function that gives money
    OnCompleted = GrantMoney(1500)
})

AddMission(3, {
    Instructions = "Collect 10 chemicals",
    Filter = function(mdl) 
        return mdl == "models/props_junk/garbage_plasticbottle001a.mdl" or 
        mdl == "models/props_junk/garbage_plasticbottle002a.mdl" or 
        mdl == "models/props_junk/plasticbucket001a.mdl" or 
        mdl == "models/props_junk/glassjug01.mdl"
    end,
    Count = 10,
    NPCId = NPC_CAT_CELLO,
    Prerequisites = { 2 },
    OnCompleted = GrantMoney(1500)
})

AddMission(4, {
    Instructions = "Kidnap Dr. Kleiner",
    Filter = function(mdl) 
        return mdl == "models/kleiner.mdl" or 
        mdl == "models/player/kleiner.mdl" or
        mdl == "models/kleiner_monitor.mdl"
    end,
    Count = 1,
    NPCId = NPC_CAT_CELLO,
    Prerequisites = { 3 },
    OnCompleted = GrantMoney(1500)
})

AddMission(5, {
    Instructions = "Steal a potted cactus",
    Filter = function(mdl) 
        return mdl == "models/props_lab/cactus.mdl"
    end,
    Count = 1,
    NPCId = NPC_CAT_CELLO,
    Prerequisites = { 4 },
    OnCompleted = GrantMoney(1500)
})