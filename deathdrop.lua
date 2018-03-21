PLUGIN.name = "DeathDrop"
PLUGIN.author = "some faggot"
PLUGIN.desc = "Handles items when player dies."

nut.config.add("deathItemShouldDrop", false, "If true items will drop in the world.", nil, {
	category = "Death"
})

nut.config.add("deathWeaponDura", true, "If true weapons will take damage.", nil, {
	category = "Death"
})

nut.config.add("deathWeaponDuraDmg", 35, "How much damage a weapon will take from a playerdeath.", nil, {
	data = {min = 0, max = 100},
	category = "Death"
})

nut.config.add("deathItemMaxDrop", 1, "How many items that can drop from one death.", nil, {
	data = {min = 0, max = 50},
	category = "Death"
})

nut.config.add("deathItemDropChance", 50, "How big the chance to drop items is.", nil, {
	data = {min = 1, max = 100},
	category = "Death"
})

function PLUGIN:PlayerDeath(client, inflictor, attacker)
	local character = client:getChar()

	if (client:getChar()) then
		local items = client:getChar():getInv():getItems(false)
		local itemNames = {}
		local counter = 0

	    for k, item in pairs( items ) do
	        if item.noDeathDrop != true then
				if (item.keepWhenEquipped and item:getData("equip", false)) then
					if item:getData("durability", false) then
						if nut.config.get("deathWeaponDura") then
							item:setData("durability", math.Clamp( item:getData("durability") - nut.config.get("deathWeaponDuraDmg", 35), 0, 100 ) )	
						end
					end
				else
					if (counter < nut.config.get("deathItemMaxDrop", 1)) then
						if math.random(100) < nut.config.get("deathItemDropChance", 50) then
							if (nut.config.get("deathItemShouldDrop")) then
								item:transfer()
								if item:getEntity() then
									item:getEntity():SetPos(client:GetPos() + Vector( math.Rand(-8,8), math.Rand(-8,8), counter * 5 ))
								end
							else
								item:remove()
							end
							table.Add(itemNames, {item.name})
							counter = counter + 1
						end
					end
				end
			end
	    end
	   
	    timer.Simple(nut.config.get("spawnTime", 5) + 1, function()
	    	for j, name in pairs( itemNames ) do
	    		client:notify( "Your "..name.." was lost to the Zone." ) --Flufftext
	    	end
	    end)
	end
end