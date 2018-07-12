module( "missions", package.seeall )

ResetMissions()

NPC_COMPUTER = 666
AddNPC("NPC_CAT_BAR", "Bartender", "models/andy/bartender/cat_bartender.mdl")
AddNPC("NPC_CAT_SING", "Singer", "models/andy/singer/cat_singer.mdl")
AddNPC("NPC_CAT_PIANO", "Pianist", "models/andy/pianist/cat_pianist.mdl")
AddNPC("NPC_CAT_CELLO", "Cellist", "models/andy/cellist/cat_cellist.mdl")
AddNPC("NPC_NARRATOR", "", "models/npc/cat.mdl")
AddNPC("NPC_BAR", "")

-- Utility function for giving a player a monetary reward
local function GrantMoney(amt)
    return function(ply)
        ply:ChangeNotes(amt * newgame.GetMultiplier())
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

local function MatchesAny(mdl, tbl)
    for _, v in pairs(tbl) do
        if string.lower(mdl) == string.lower(v) then 
            return true
        end
    end

    return false
end

AddMission(0, NPC_CAT_CELLO, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Collect 15 oil drums",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return MatchesAny(mdl, { 
            "models/props_c17/oildrum001_explosive.mdl",
            "models/props_c17/oildrum001.mdl",
            "models/props_phx/oildrum001_explosive.mdl",
            "models/props_phx/oildrum001.mdl" 
        })
    end,

    -- They need to collect 15 of em' to complete the mission.
    Count = 15,

    -- List of all missions that needs to have been completed before this one becomes available
    -- Leave empty to be available immediately
    Prerequisites = nil,

    -- When they finish the mission, this function is called to give out a reward
    -- The 'GrantMoney' function returns a function that gives money
    OnCompleted = GrantMoney(1500)
})

AddMission(1, NPC_CAT_CELLO, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Collect 10 gas cans and beer bottles",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return MatchesAny(mdl, { 
            "models/props_junk/gascan001a.mdl",
            "models/props_c17/oildrum001_explosive.mdl",
            "models/props_junk/propane_tank001a.mdl",
            "models/props_phx/oildrum001_explosive.mdl" 
        })
    end,

    -- They need to collect 10 of em' to complete the mission.
    Count = 10,

    -- List of all missions that needs to have been completed before this one becomes available
    Prerequisites = { IndexToMID(0, NPC_CAT_CELLO) },

    -- When they finish the mission, this function is called to give out a reward
    -- The 'GrantMoney' function returns a function that gives money
    OnCompleted = GrantMoney(1500)
})

AddMission(2, NPC_CAT_CELLO, {
    -- User-friendly instructions for what the player should collect
    Instructions = "Collect 5 paintcans",

    -- The accept function for what props count towards the mission
    -- Can be as broad or as specific as you want
    Filter = function(mdl) 
        return MatchesAny(mdl, {
            "models/props_junk/metal_paintcan001a.mdl",
            "models/props_junk/metal_paintcan001b.mdl",
            "models/props/cs_militia/paintbucket01.mdl" 
        })
    end,

    -- They need to collect 1 of em' to complete the mission.
    Count = 5,

    -- List of all missions that needs to have been completed before this one becomes available
    Prerequisites = { IndexToMID(1, NPC_CAT_CELLO)  },

    -- When they finish the mission, this function is called to give out a reward
    -- The 'GrantMoney' function returns a function that gives money
    OnCompleted = GrantMoney(1500)
})

AddMission(3, NPC_CAT_CELLO, {
    Instructions = "Collect 10 random chemicals",
    Filter = function(mdl) 
        return MatchesAny(mdl, {
            "models/props_junk/garbage_plasticbottle001a.mdl",
            "models/props_junk/garbage_plasticbottle002a.mdl",
            "models/props_junk/garbage_plasticbottle003a.mdl",
            "models/props_junk/plasticbucket001a.mdl",
            "models/props_junk/glassjug01.mdl",
            "models/props_lab/crematorcase.mdl",
            "models/props_lab/jar01a.mdl",
            "models/props_lab/jar01b.mdl",
            "models/props/de_train/biohazardtank.mdl",
            "models/props/de_train/biohazardtank_dm_10.mdl"
        })
    end,
    Count = 10,
    Prerequisites = { IndexToMID(2, NPC_CAT_CELLO)  },
    OnCompleted = GrantMoney(1500)
})

AddMission(4, NPC_CAT_CELLO, {
    Instructions = "Kidnap Dr. Kleiner",
    Filter = function(mdl) 
        return MatchesAny(mdl, {
            "models/kleiner.mdl",
            "models/player/kleiner.mdl",
            "models/kleiner_monitor.mdl" 
        })
    end,
    Count = 1,
    Prerequisites = { IndexToMID(3, NPC_CAT_CELLO)  },
    OnCompleted = GrantMoney(1500)
})

AddMission(5, NPC_CAT_CELLO, {
    Instructions = "Steal a potted cactus",
    Filter = function(mdl) 
        return mdl == "models/props_lab/cactus.mdl"
    end,
    Count = 1,
    Prerequisites = { IndexToMID(4, NPC_CAT_CELLO)  },
    OnCompleted = GrantMoney(1500)
})

/*
===========================
    Bartender Missions
===========================
*/
AddMission(0, NPC_CAT_BAR, {
    Instructions = "Find 10 storage crates",
    Filter = function(mdl) 
        return string.match(mdl, "crate") and
            not string.match(mdl, "chunk") and
            not string.match(mdl, "gib") and
            not string.match(mdl, "_p%d+") -- CSS crates_fruit_p<N>
    end,
    Count = 10,
    Prerequisites = nil,
    OnCompleted = GrantMoney(2500)
})


/*
===========================
    Pianist Missions
===========================
*/
AddMission(0, NPC_CAT_PIANO, {
    Instructions = "Find 5 chairs",
    Filter = function(mdl) 
        return string.match(mdl, "chair") and
            not string.match(mdl, "chunk") and
            not string.match(mdl, "gib") and
            not string.match(mdl, "damage")
    end,
    Count = 5,
    Prerequisites = nil,
    OnCompleted = GrantMoney(2500)
})

AddMission(1, NPC_CAT_PIANO, {
    Instructions = "Steal 10 headcrabs",
    Filter = function(mdl) 
        return MatchesAny(mdl, {
            "models/headcrab.mdl",
            "models/headcrabblack.mdl",
            "models/headcrabclassic.mdl",
            
            -- Let em steal the heads off zombies
            "models/zombie/classic.mdl",
            "models/zombie/poison.mdl",
            "models/zombie/fast.mdl"
        })
    end,
    Count = 10,
    Prerequisites = { IndexToMID(0, NPC_CAT_PIANO)  },
    OnCompleted = GrantMoney(2500)
})

AddMission(2, NPC_CAT_PIANO, {
    Instructions = "Find 20 boxes of chinese takeout",
    Filter = function(mdl) 
        return mdl == "models/props_junk/garbage_takeoutcarton001a.mdl"
    end,
    Count = 20,
    Prerequisites = { IndexToMID(1, NPC_CAT_PIANO)  },
    OnCompleted = GrantMoney(2500)
})

AddMission(3, NPC_CAT_PIANO, {
    Instructions = "Borrow 30 vending machines",
    Filter = function(mdl) 
        return MatchesAny(mdl, {
            "models/props/cs_office/vending_machine.mdl",
            "models/props_interiors/vendingmachinesoda01a_door.mdl",
            "models/props_interiors/vendingmachinesoda01a.mdl"
        })
    end,
    Count = 30,
    Prerequisites = { IndexToMID(2, NPC_CAT_PIANO)  },
    OnCompleted = GrantMoney(2500)
})

AddMission(4, NPC_CAT_PIANO, {
    Instructions = "Find a horse statue",
    Filter = function(mdl) 
        return mdl == "models/props_c17/statue_horse.mdl"
    end,
    Count = 1,
    Prerequisites = { IndexToMID(3, NPC_CAT_PIANO)  },
    OnCompleted = GrantMoney(2500)
})