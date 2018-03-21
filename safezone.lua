local PLUGIN = PLUGIN
PLUGIN.name = "Safe Zones"
PLUGIN.author = "some faggot"
PLUGIN.desc = "Safe zones"

local playerMeta = FindMetaTable("Player")

function playerMeta:isInArea(areaID)
	local areaData = nut.area.getArea(areaID)

	if (!areaData) then
		return false, "Area you specified is not valid."
	end

	--local char = v:getChar()

	--if (!char) then
	--	return false, "Your character is not valid."
	--end

	local clientPos = self:GetPos() + self:OBBCenter()
	return clientPos:WithinAABox(areaData.minVector, areaData.maxVector), areaData
end

function playerMeta:getSafeStatus()
	return (self:getNetVar("isSafe")) or false
end

function playerMeta:setSafeStatus(status)
	self:setNetVar("isSafe", status)
end

if (CLIENT) then
	function PLUGIN:HUDPaint()
		if LocalPlayer():getSafeStatus() then
			local Texture1 = Material("stalker/ui/hud_safe.png") 
			surface.SetMaterial(Texture1)
			surface.SetDrawColor(Color(116, 195, 101, 255))
			surface.DrawTexturedRect(ScrW()-48, ScrH()-189, 32, 32, Color(0, 255, 0, 255))
		end
	end
else

function PLUGIN:PlayerLoadedChar(client, character, lastChar)
		client:setSafeStatus(false)
		client:setNetVar("safeTick", CurTime() + 5)
end
/*
function PLUGIN:PlayerTick(client)
	if client:getChar():getArea() ~= nil then
		if !client:getChar():getData("isSafe") then
			if client:getChar():getData("safeTick") > CurTime() then
				client:getChar():setData("isSafe", true)
			end
		end
	else
		client:getChar():setData("isSafe", false)
	end
end
*/
function PLUGIN:OnPlayerAreaChanged(client, areaID)
	if client:getArea() then
		client:setNetVar("safeTick", CurTime() + 5)
	end
end

/*
function PLUGIN:EntityTakeDamage(entity, dmgInfo)
	if (IsValid(entity.nutPlayer)) then
		if entity:getSafeStatus() then
			dmgInfo:SetDamage(0)
		end
	end
end
*/
local thinkTime = CurTime()
local funny = 0
function PLUGIN:Think()
	if (thinkTime < CurTime()) then
		for k, v in ipairs(player.GetAll()) do
			funny = 0
			for u, i in ipairs(nut.area.getAllArea()) do
				if v:isInArea(u) then
					funny = 0
					break
				end
				funny = funny + 1
			end
			if funny > 0 then
				v.curArea = nil
			end
		
			if v:getArea() ~= nil then
				if !v:getSafeStatus("isSafe") then
					if v:getNetVar("safeTick") > CurTime() then
						v:setSafeStatus(true)
					end
				end
			else
				v:setSafeStatus(false)
				v:setNetVar("safeTick", CurTime() + 5)
			end
		end
		thinkTime = CurTime() + .5
	end
end
end