util.AddNetworkString("SendLevel")
util.AddNetworkString("GetLevels")

LEVELS = {}

net.Receive("SendLevel", function(len, ply)
	local level = net.ReadString()

	LEVELS[ply:SteamID64()] = level

	net.Start("GetLevels")
		net.WriteTable(LEVELS)
	net.Broadcast()
end)