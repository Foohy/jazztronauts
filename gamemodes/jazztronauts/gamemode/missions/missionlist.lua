module( "missions", package.seeall )

ResetMissions()

include("jazz_localize.lua")

NPC_COMPUTER = 666
AddNPC("NPC_CAT_BAR", JazzLocalize("jazz.cat.bartender"), "models/andy/bartender/cat_bartender.mdl")
AddNPC("NPC_CAT_SING", JazzLocalize("jazz.cat.singer"), "models/andy/singer/cat_singer.mdl")
AddNPC("NPC_CAT_PIANO", JazzLocalize("jazz.cat.pianist"), "models/andy/pianist/cat_pianist.mdl")
AddNPC("NPC_CAT_CELLO", JazzLocalize("jazz.cat.cellist"), "models/andy/cellist/cat_cellist.mdl")
AddNPC("NPC_NARRATOR", "", "models/npc/cat.mdl")
AddNPC("NPC_BAR", "")
AddNPC("NPC_CAT_VOID", JazzLocalize("jazz.cat.unknown"), "models/andy/basecat/cat_all.mdl")
AddNPC("NPC_CAT_ASH", JazzLocalize("jazz.cat.ash"), "models/andy/basecat/cat_all.mdl")

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

local count = 15

AddMission(0, NPC_CAT_CELLO, {

	-- User-friendly instructions for what the player should collect
	Instructions = JazzLocalize("jazz.mission.drums",count),

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
	Count = count,

	-- List of all missions that needs to have been completed before this one becomes available
	-- Leave empty to be available immediately
	Prerequisites = nil,

	-- When they finish the mission, this function is called to give out a reward
	-- The 'GrantMoney' function returns a function that gives money
	OnCompleted = GrantMoney(5000)
})

count = 10
AddMission(1, NPC_CAT_CELLO, {
	-- User-friendly instructions for what the player should collect
	Instructions = JazzLocalize("jazz.mission.gasbeer",count),

	-- The accept function for what props count towards the mission
	-- Can be as broad or as specific as you want
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props_junk/gascan001a.mdl",
			"models/props_c17/oildrum001_explosive.mdl",
			"models/props_junk/propane_tank001a.mdl",
			"models/props_phx/oildrum001_explosive.mdl",
			"models/props/cs_militia/caseofbeer01.mdl",
			"models/props_junk/garbage_glassbottle001a.mdl",
			"models/props_junk/garbage_glassbottle002a.mdl",
			"models/props_junk/garbage_glassbottle003a.mdl",
			"models/props_junk/glassbottle01a.mdl",
			"models/props/cs_militia/bottle01.mdl",
			"models/props/cs_militia/bottle02.mdl",
			"models/props/cs_militia/bottle03.mdl"
		})
	end,

	-- They need to collect 10 of em' to complete the mission.
	Count = count,

	-- List of all missions that needs to have been completed before this one becomes available
	Prerequisites = { IndexToMID(0, NPC_CAT_CELLO) },

	-- When they finish the mission, this function is called to give out a reward
	-- The 'GrantMoney' function returns a function that gives money
	OnCompleted = GrantMoney(10000)
})

count = 10
AddMission(2, NPC_CAT_CELLO, {
	Instructions = JazzLocalize("jazz.mission.chems",count),
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
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_CELLO)  },
	OnCompleted = GrantMoney(20000)
})

count = 5
AddMission(3, NPC_CAT_CELLO, {
	-- User-friendly instructions for what the player should collect
	Instructions = JazzLocalize("jazz.mission.paint",count),

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
	Count = count,

	-- List of all missions that needs to have been completed before this one becomes available
	Prerequisites = { IndexToMID(2, NPC_CAT_CELLO)  },

	-- When they finish the mission, this function is called to give out a reward
	-- The 'GrantMoney' function returns a function that gives money
	OnCompleted = GrantMoney(15000)
})

count = 1
AddMission(4, NPC_CAT_CELLO, {
	Instructions = JazzLocalize("jazz.mission.drk",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/kleiner.mdl",
			"models/player/kleiner.mdl",
			"models/kleiner_monitor.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_CELLO)  },
	OnCompleted = GrantMoney(25000)
})

count = 1
AddMission(5, NPC_CAT_CELLO, {
	Instructions = JazzLocalize("jazz.mission.cactus",count),
	Filter = function(mdl)
		return mdl == "models/props_lab/cactus.mdl"
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_CELLO)  },
	OnCompleted = GrantMoney(30000)
})

/*
===========================
	Bartender Missions
===========================
*/
count = 10
AddMission(0, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.crates",count),
	Filter = function(mdl)
		return string.match(mdl, "crate") and
			not string.match(mdl, "chunk") and
			not string.match(mdl, "gib") and
			not string.match(mdl, "_p%d+") -- CSS crates_fruit_p<N>
	end,
	Count = count,
	Prerequisites = nil,
	OnCompleted = GrantMoney(5000)
})

count = 10
AddMission(1, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.cars",count),
	Filter = function(mdl)
		return string.match(mdl, "car00") or
			string.match(mdl, "van00") or
			string.match(mdl, "car_nuke") or
			string.match(mdl, "car_militia")
	end,
	Count = count,
	Prerequisites = { IndexToMID(0, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(10000)
})

count = 10
AddMission(2, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.melons",count),
	Filter = function(mdl)
		return string.match(mdl, "watermelon")
	end,
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(15000)
})

count = 15
AddMission(3, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.gas",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props_junk/propane_tank001a.mdl",
			"models/props_junk/gascan001a.mdl",
			"models/props_junk/PropaneCanister001a.mdl",
			"models/props_c17/canister_propane01a.mdl",
			"models/props_citizen_tech/firetrap_propanecanister01a.mdl",
			"models/props_citizen_tech/firetrap_propanecanister01b.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(2, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(20000)
})

count = 5
AddMission(4, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.washers",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props_c17/furniturewashingmachine001a.mdl",
			"models/props_wasteland/laundry_washer001a.mdl",
			"models/props_wasteland/laundry_dryer002.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(25000)
})

count = 10
AddMission(5, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.antlions",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/antlion.mdl",
			"models/antlion_worker.mdl",
			"models/antlion_guard.mdl",
			"models/antlion_grub.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(30000)
})



/*
===========================
	Pianist Missions
===========================
*/
count = 5
AddMission(0, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.chairs",count),
	Filter = function(mdl)
		return string.match(mdl, "chair") and
			not string.match(mdl, "chunk") and
			not string.match(mdl, "gib") and
			not string.match(mdl, "damage")
	end,
	Count = count,
	Prerequisites = nil,
	OnCompleted = GrantMoney(5000)
})

count = 10
AddMission(1, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.crabs",count),
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
	Count = count,
	Prerequisites = { IndexToMID(0, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(10000)
})

count = 20
AddMission(2, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.meals",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props_junk/garbage_takeoutcarton001a.mdl",
			"models/food/burger.mdl",
			"models/food/hotdog.mdl",
			"models/props_junk/watermelon01.mdl",
			"models/props_junk/food_pile01.mdl",
			"models/props_junk/food_pile02.mdl",
			"models/props_junk/food_pile03.mdl",
			"models/props/cs_militia/food_stack.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(15000)
})

count = 30
AddMission(3, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.vending",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props/cs_office/vending_machine.mdl",
			"models/props_interiors/vendingmachinesoda01a_door.mdl",
			"models/props_interiors/vendingmachinesoda01a.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(2, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(20000)
})

count = 1
AddMission(4, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.horse",count),
	Filter = function(mdl)
		return mdl == "models/props_c17/statue_horse.mdl"
		--TODO: L4D2 has its own horse statue model, should let it count too
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(25000)
})

count = 3
AddMission(5, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.metropolice",count),
	Filter = function(mdl)
		return mdl == "models/police.mdl"
		--TODO:Dr. Kleiner can use player model too, should do that for this too. Police Cheaple, too!
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(30000)
})

/*
===========================
	Singer Missions
===========================
*/
count = 10
AddMission(0, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.documents",count),
	Filter = function(mdl)
		return string.match(mdl, "binder") or
			string.match(mdl, "filecabinet") or
			string.match(mdl, "file_cabinet")
	end,
	Count = count,
	Prerequisites = nil,
	OnCompleted = GrantMoney(5000)
})

count = 5
AddMission(1, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.dolls",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props_lab/huladoll.mdl",
			"models/props_c17/doll01.mdl",
			"models/maxofs2d/companion_doll.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(0, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(10000)
})

count = 15
AddMission(2, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.radiators",count),
	Filter = function(mdl)
		return string.match(mdl, "radiator")
	end,
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(15000)
})

count = 10
AddMission(3, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.plants",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props/de_inferno/claypot03.mdl",
			"models/props/de_inferno/pot_big.mdl",
			"models/props/de_inferno/potted_plant1.mdl",
			"models/props/de_inferno/potted_plant2.mdl",
			"models/props/de_inferno/potted_plant3.mdl",
			"models/props/cs_office/plant01.mdl",
			"models/props_lab/cactus.mdl",
			"models/props_junk/terracotta01.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(2, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(20000)
})

count = 1
AddMission(4, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.alyx",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/alyx.mdl",
			"models/alyx_ep2.mdl",
			"models/alyx_interior.mdl",
			"models/alyx_intro.mdl",
			"models/player/alyx.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(25000)
})

count = 10
AddMission(5, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.radios",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/infra/props_clutter/cheap_radio.mdl",
			"models/infra/props_clutter/radiophone.mdl",
			"models/props/cs_office/radio.mdl",
			"models/props_lab/citizenradio.mdl",
			"models/props_radiostation/radio_antenna01.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(30000)
})




