local PLUGIN = PLUGIN
PLUGIN.name = "Radiation"
PLUGIN.author = "some faggot"
PLUGIN.desc = "Radiation System"

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:getRadiation()
	return (self:getNetVar("radiation")) or 0
end

function playerMeta:getRadiationPercent()
	return math.Clamp(self:getRadiation()/100, 0 ,1)
end

function playerMeta:addRadiation(amount)
	local curRadiation = self:getRadiation()

	self:setNetVar("radiation", 
		math.Clamp(math.min(curRadiation) + amount, 0, 100)
	)
end

function playerMeta:setRadiation(amount)
	
	self:setNetVar("radiation", math.Clamp(amount, 0, 100))
end

if (CLIENT) then
	local color = Color(39, 174, 96)

	function PLUGIN:RenderScreenspaceEffects()
		if (LocalPlayer():getRadiation() > 45 and LocalPlayer():getRadiation() < 75) then
			DrawMotionBlur(0.1, 0.3, 0.01)
		elseif(LocalPlayer():getRadiation() > 75) then
			DrawMotionBlur(0.1, 0.7, 0.01)
		end
    end
else
	local PLUGIN = PLUGIN
	
	function PLUGIN:CharacterPreSave(character)
		local savedRads = math.Clamp(character.player:getRadiation(), 0, 100)
		character:setData("radiation", savedRads)
	end

	function PLUGIN:PlayerLoadedChar(client, character, lastChar)
		if (character:getData("radiation")) then
			client:setNetVar("radiation", character:getData("radiation"))
		else
			client:setNetVar("radiation", 0)
		end
	end

	function PLUGIN:PlayerDeath(client)
		client.resetRads = true
	end

	function PLUGIN:PlayerSpawn(client)
		if (client.resetRads) then
			client:setNetVar("radiation", 0)
			client.resetRads = false
		end
	end

	local thinkTime = CurTime()
	local damageTime = CurTime()
	function PLUGIN:Think()
		if (thinkTime < CurTime()) then
			for k, v in ipairs(player.GetAll()) do
				if v:getNetVar("radiation", 0) == 100 then
					if v:Alive() then
						v:Kill()
						nut.log.add(client, "death", "radiation")
					end
				end	
			end
			thinkTime = CurTime() + .5
		end
		
		--damage meme
		if (damageTime < CurTime()) then
			for k, v in ipairs(player.GetAll()) do
			
				if (v:getNetVar("radiation", 0) > 45 and v:getNetVar("radiation", 0) < 75) then
					v:addRadiation(-0.1)
					v:TakeDamage(1,v,v:GetActiveWeapon())
				elseif (v:getNetVar("radiation", 0) > 75) then
					v:addRadiation(-0.1)
					v:TakeDamage(1.5,v,v:GetActiveWeapon())
				end
			end
			damageTime = CurTime() + 15
		end
	end
end

nut.command.add("charsetradiation", {
	adminOnly = true,
	syntax = "<string character> <number radiation>",
	onRun = function(client, arguments)
		local target = nut.util.findPlayer(arguments[1])
		local radiation = tonumber(arguments[2])

		target:setRadiation(radiation)

		if client == target then
            client:notify("You have set your radiation to "..radiation)
        else
            client:notify("You have set "..target:Name().."'s radiation to "..radiation)
            target:notify(client:Name().." has set your radiation to "..radiation)
        end
	end
})