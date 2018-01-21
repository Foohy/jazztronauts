module( "missions", package.seeall )

ResetMissions()

NPC_INVALID = 0
NPC_CAT_BAR = 1
NPC_CAT_SING = 2
NPC_CAT_PIANO = 3
NPC_CAT_CHELLO = 4
NPC_COMPUTER = 666

AddMission(0, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Collect 10 pieces of actual garbage",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return string.find(mdl, "trash") or string.find(mdl, "rubbish") or string.find(mdl, "garbage")
    end,

    -- They need to collect 10 of em' to complete the mission.
    Count = 10,

    -- ID of the NPC that offers this mission
    NPCId = NPC_CAT_BAR,

    -- List of all missions that needs to have been completed before this one becomes available
    -- Leave empty to be available immediately
    Prerequisites = nil
})

AddMission(1, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Steal like 15 pieces of furniture",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return string.find(string.lower(mdl), "furniture")
    end,

    -- They need to collect 15 of em' to complete the mission.
    Count = 15,

    -- ID of the NPC that offers this mission
    NPCId = NPC_CAT_BAR,

    -- List of all missions that needs to have been completed before this one becomes available
    Prerequisites = { 0 }
})

AddMission(2, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Steal your only means of transportation",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return mdl == "models/sunabouzu/jazzbus.mdl"
    end,

    -- They need to collect 1 of em' to complete the mission.
    Count = 1,

    -- ID of the NPC that offers this mission
    NPCId = NPC_CAT_CHELLO,

    -- List of all missions that needs to have been completed before this one becomes available
    Prerequisites = { 1 }
})

AddMission(3, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Make G-Man literally rise and shine",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return mdl == "models/gman.mdl" or mdl == "models/gman_high.mdl"
    end,

    -- They need to collect 10 of em' to complete the mission.
    Count = 1,

    -- ID of the NPC that offers this mission
    NPCId = NPC_CAT_CHELLO,

    -- List of all missions that needs to have been completed before this one becomes available
    Prerequisites = { 2 }
})