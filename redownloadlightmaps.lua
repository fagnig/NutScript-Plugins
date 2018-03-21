local PLUGIN = PLUGIN
PLUGIN.name = "Lightmap refresher"
PLUGIN.author = "some faggot"
PLUGIN.desc = "For use with weathermods."

nut.config.add("redownloadInterval", 600, "How often clients should redownload lightmaps.", nil, {
	data = {min = 120, max = 86400},
	category = "server"
})

if CLIENT then
	local redownloadTimer = 0
	local redownloadInterval = nut.config.get("redownloadInterval")

	local function RedownloadThink()
		if redownloadTimer < CurTime() then
			render.RedownloadAllLightmaps(true)
			redownloadTimer = CurTime() + redownloadInterval
		end
	end

	hook.Add("Think", "RedownloadTimer", RedownloadThink)

	netstream.Hook("nut_ReloadLightmaps", function()
		render.RedownloadAllLightmaps(true)
	end)

end

nut.command.add("redownloadlightmaps", {
	adminOnly = false,
	onRun = function(client, arguments)
		if SERVER then
			netstream.Start(client, "nut_ReloadLightmaps")
			client:notify( "Redownloading lightmaps." )
		end
	end
})

