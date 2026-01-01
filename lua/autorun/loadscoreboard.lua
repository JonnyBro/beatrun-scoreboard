local function includeFile(fileName)
	local fullPath = "scoreboard/" .. fileName
	local loadType = string.Left(string.lower(fileName), 3)

	if loadType == "sh_" then
		AddCSLuaFile(fullPath)
		include(fullPath)
	elseif loadType == "cl_" then
		AddCSLuaFile(fullPath)

		if CLIENT then include(fullPath) end
	elseif loadType == "sv_" then
		if SERVER then include(fullPath) end
	end
end

includeFile("cl_config.lua")
includeFile("sh_scoreboard.lua")
includeFile("sv_resource.lua")