PLUGIN.name = "Revive"
PLUGIN.author = "some faggot"
PLUGIN.desc = "A downed/revive implementation"

nut.config.add("reviveOn", false, "If true revive mode will be active.", nil, {
	category = "Revive"
})

nut.config.add("reviveRessurrectionTime", 10, "How long it should take to revive someone.", nil, {
	data = {min = 3, max = 60},
	category = "Revive"
})

function PLUGIN:PlayerDisconnected(ply)
	if SCHEMA.Corpses[ply] then
		for k, v in ipairs(nut.faction.indices) do
			if (k == client:Team()) then
				points = nut.plugin.list["spawns"].spawns[v.uniqueID] or {}

				break
			end
		end

		if (points) then 
			for k, v in ipairs(nut.class.list) do
				if (class == v.index) then
					className = v.uniqueID

					break
				end
			end

			points = points[className] or points[""]

			if (points and table.Count(points) > 0) then
				local position = table.Random(points)

				ply:SetPos(position)
			end
		end
	end
end

if CLIENT then

	surface.CreateFont( "ReviveText", {
	 font = "Trebuchet MS",
	 size = 25,
	 weight = 500,
	 blursize = 0,
	 scanlines = 0,
	 antialias = true
	} )

	hook.Add("HUDPaint", "DrawDeadPlayers", function()
		if (LocalPlayer():getChar()) then
			for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
				if IsValid(v) and v.isDeadBody then
					if LocalPlayer():GetPos():Distance(v:GetPos()) > 512 then return end
					local Pos = v:GetPos():ToScreen()
					draw.RoundedBox(0, Pos.x, Pos.y, 10, 40, Color(175, 100, 100))
					draw.RoundedBox(0, Pos.x - 15, Pos.y + 15, 40, 10, Color(175, 100, 100))

					draw.SimpleText("Time Left: "..math.Round(v:GetNWFloat("Time") - CurTime()), "ReviveText", Pos.x, Pos.y - 20, Color(249, 255, 239), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	end)

	netstream.Hook("nut_DeadBody", function( index )
		local ragdoll = Entity(index)

		if IsValid(ragdoll) then
			ragdoll.isDeadBody = true
		end
	end)
else
	function PLUGIN:PlayerSpawn( client )
		client:UnSpectate()
		if not client:getChar() then 
			return 
		end

		if IsValid(SCHEMA.Corpses[client]) then
			if !client:getNetVar("resurrected") then
				hook.Run("DeathDrop",client,SCHEMA.Corpses[client]:GetPos())
			end
			SCHEMA.Corpses[client]:Remove()
			client:setNetVar("resurrected", false)
		end

	end

	SCHEMA.Corpses = SCHEMA.Corpses or {}

	function SCHEMA:DoPlayerDeath( client, attacker, dmg )
		if not client:getChar() then 
			return 
		end

		if client:getNetVar("deathsdoortime") != nil and client:getNetVar("deathsdoortime") > CurTime() then
			hook.Run("DeathDrop",client,client:GetPos())
			client:setNetVar("deathsdoortime", CurTime())
			return
		end

		SCHEMA.Corpses[client] = ents.Create("prop_ragdoll")
		SCHEMA.Corpses[client]:SetPos(client:GetPos())
		SCHEMA.Corpses[client]:SetModel(client:GetModel())
		for k,v in pairs(client:GetBodyGroups()) do
			local curBG = client:GetBodygroup(v.id)
			SCHEMA.Corpses[client]:SetBodygroup(v.id, curBG)
		end
		SCHEMA.Corpses[client]:SetSkin(client:GetSkin())
		SCHEMA.Corpses[client]:setNetVar("player", client)
		SCHEMA.Corpses[client]:SetAngles(client:GetAngles())
		SCHEMA.Corpses[client]:Spawn()
		SCHEMA.Corpses[client]:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		local phys = SCHEMA.Corpses[client]:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:ApplyForceCenter(client:GetVelocity() * 15);
		end
		SCHEMA.Corpses[client].player = client
		SCHEMA.Corpses[client]:SetNWFloat("Time", CurTime() + nut.config.get("spawnTime", 10))
		SCHEMA.Corpses[client]:SetNWBool("Body", true)

		timer.Simple(0.5, function()
			netstream.Start(nil, "nut_DeadBody", SCHEMA.Corpses[client]:EntIndex())
		end)

		nut.chat.send(client, "me", "falls to the ground due to their injuries.", false)

		client:Spectate(OBS_MODE_CHASE)
		client:SpectateEntity(SCHEMA.Corpses[client])
		client:notify("You will respawn in "..math.Round(nut.config.get("spawnTime", 10)).." seconds.")
		timer.Simple(0.01, function()
			if(client:GetRagdollEntity() != nil and client:GetRagdollEntity():IsValid()) then
				client:GetRagdollEntity():Remove()
			end
		end)


	end
	function RevivePlayer(client)
	end

	hook.Add( "KeyPress", "keypress_use_revive", function( ply, key )
		if ( key == IN_USE ) then
			local traceRes = ply:GetEyeTrace()
			if ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "prop_ragdoll" ) then
				local traceEnt = traceRes.Entity
					if not ( IsValid( traceEnt.player ) ) then
						ply:notify( "You cannot revive a disconnected player's body." )
						return
					end
					ply:setAction("Reviving...", nut.config.get("reviveRessurrectionTime", 10))
					ply:doStaredAction(traceEnt, function()
						traceEnt.player:UnSpectate()
						traceEnt.player:setNetVar("resurrected", true)
						traceEnt.player:setNetVar("deathsdoortime", CurTime()+180)
						traceEnt.player:Spawn()
						traceEnt.player:SetHealth( 1 ) 
						traceEnt.player:SetPos(traceEnt:GetPos())
						ply:notify( "You revived "..traceEnt.player:GetName() )
						traceEnt.player:notify( "You were revived by "..ply:GetName() )
					end, nut.config.get("reviveRessurrectionTime", 10), function() ply:setAction() end, 128)

				--end
			end
		end

	end )
end

