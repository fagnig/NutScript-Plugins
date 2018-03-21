	--[[
	PLUGIN.eventdefs["Zombie1"] = {
		entities = {
			{"npc_mutant_classiczombie", 6}, -- {ent_name, amount}
			{"npc_mutant_dog", 2},
		},
		items = {
			{"mp5", {["durability"] = 15}}, -- {nut_item uniqueID, data}
			{"mp5", {["durability"] = 60}},
		},
		props = {
			{"models/props_c17/oildrum001.mdl", 5}, -- {propmodel, amount}
			{"models/props_c17/oildrum002.mdl", 5},
		},
		ragdolls = {
			{"models/kleiner.mdl", 2, 1, "000000000"}, -- {ragdollmodel, amount, skingroup, bodygroups}
			{"models/kleiner.mdl", 3, 2, "000000000"},
		},
		loot = {
			{"kit_event", 1}, 
		},
		pdabroadcast = "Zombies have been spotted at %s, proceed with caution.",
		difficulty = 1,
		lootChance = 10, --percentage
	}
]]--
--entities: spawns <amount> entities of the type listed
--items: spawns the listed items with the given data
--props: spawns <amount> props with the model listed
--ragdolls: spawns <amount> ragdolls and sets skin and bodygroup
--loot: like items, except each item has a chance to spawn
