local PLUGIN = PLUGIN
PLUGIN.name = "Data Setter"
PLUGIN.author = "some faggot"
PLUGIN.desc = "Plugin to set item data."

nut.command.add("setdata", {
	adminOnly = true,
	syntax = "<string key> <number data>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local key = arguments[1]
		local data = tonumber(arguments[2])
		local stasheditem = nut.item.instances
		
		if (!data or !isnumber(data) or data < 0) then
			return "@invalidArg", 2
		end

		for k, v in pairs( stasheditem ) do
			if v:getEntity() then
			local dist = hitpos:Distance(client:GetPos())
			local distance = v:getEntity():GetPos():Distance( hitpos )
				if distance <= 32 then
					v:setData(key, data)

					client:notify( "Data set successfully.")
				end
			end
			end
		end
})