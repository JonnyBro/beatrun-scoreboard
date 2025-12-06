util.AddNetworkString("Scoreboard_SendLevel")
util.AddNetworkString("Scoreboard_GetLevels")

LEVELS = {}

net.Receive("Scoreboard_SendLevel", function(len, ply)
	local level = net.ReadString()

	LEVELS[ply:SteamID64()] = level

	net.Start("Scoreboard_GetLevels")
		net.WriteTable(LEVELS)
	net.Broadcast()
end)