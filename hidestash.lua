local PLUGIN = PLUGIN
PLUGIN.name = "Hidden Stash System"
PLUGIN.author = "some faggot"
PLUGIN.desc = "Simple hidestash system."
PLUGIN.stashpoints = PLUGIN.stashpoints or {}

if SERVER then
	local spawntime = 1

	function PLUGIN:ItemShouldSave(entity)
		return (!entity.generated)
	end

	function PLUGIN:LoadData()
		self.stashpoints = self:getData() or {}
	end

	function PLUGIN:SaveData()
		self:setData(self.stashpoints)
	end

else

	netstream.Hook("nut_DisplayStashPoints", function(data)
		for k, v in pairs(data) do
			local emitter = ParticleEmitter( v[1] )
			local smoke = emitter:Add( "sprites/glow04_noz", v[1] )
			smoke:SetVelocity( Vector( 0, 0, 1 ) )
			smoke:SetDieTime(10)
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(255)
			smoke:SetStartSize(64)
			smoke:SetEndSize(64)
			smoke:SetColor(255,186,50)
			smoke:SetAirResistance(300)
		end
	end)

end

nut.command.add("stashhide", {
	adminOnly = false,
	onRun = function(client)
		client:setAction("Covering up items...", 2, function()

		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local stasheditem = nut.item.instances
		local mt = 0
		
		for k, v in pairs( stasheditem ) do
			if v:getEntity() then
				local dist = hitpos:Distance(client:GetPos())
				local distance = v:getEntity():GetPos():Distance( hitpos )
				if dist <= 70 then
					if distance <= 32 then
						table.insert( PLUGIN.stashpoints, { hitpos, v.uniqueID, v:getEntity():GetAngles(), v.data } )
						nut.log.add(client, "created a stash at x:" .. hitpos.x .. " y:" .. hitpos.y .. " z:" .. hitpos.z .. " containing: " .. v.name)
						--if v:getData("id") then
						--	att = nut.item.inventories[ v:getData("id") ]:getItems()
						--	for h,j in pairs (att) do
						--		j:transfer()
						--	end
						--end
						v:remove()
						client:notify( "You hid ".. v.name )
						mt = mt + 1
					end
				end
			end
		end
		if mt > 0 then
			nut.chat.send(client, "meclose", "covers up something", false)
		end
		end)
	end
})

nut.command.add("stashunhide", {
	adminOnly = false,
	onRun = function(client)
		client:setAction("Searching...", 5, function()
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local mt = 0
		
		for k, v in pairs( PLUGIN.stashpoints ) do
			local dist = hitpos:Distance(client:GetPos())
			local distance = v[1]:Distance( hitpos )
			if dist <= 70 then
				if distance <= 32 then
					--local itemdata = v[4]
					nut.item.spawn(v[2], v[1] + Vector( 0, 0, mt * 5 ), nil, v[3], v[4])
					PLUGIN.stashpoints[k] = nil
					client:notify( "You uncovered a(n) ".. nut.item.list[v[2]].name )
					mt = mt + 1
				end
			end
		end
		if mt == 0 then
			client:notify( "You didn't find anything" )
		else
			nut.chat.send(client, "meclose", "uncovers something", false)
		end
		end)

	end
})

nut.command.add("stashdisplay", {
	adminOnly = true,
	onRun = function(client, arguments)
		if SERVER then
			netstream.Start(client, "nut_DisplayStashPoints", PLUGIN.stashpoints)
			client:notify( "Displayed all stashes for 10 secs." )
		end
	end
})
