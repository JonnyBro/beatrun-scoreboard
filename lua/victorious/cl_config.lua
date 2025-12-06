VictoriousScoreboardConfig = VictoriousScoreboardConfig or {}

VictoriousScoreboardConfig.servertitle = "Beatrun Community Server"

VictoriousScoreboardConfig.UsingDarkRP = false

VictoriousScoreboardConfig.UsingDarkRPCategories = false

VictoriousScoreboardConfig.UsingDarkRPCategoriesTitles = false

-- this could be "ulx", "fadmin" or "serverguard". Ask Admiration to add more(or ask any lua dev to edit settings in the end of this file)
VictoriousScoreboardConfig.DefaultAdminMod = "ulx"

-- SHOWN RANKS
VictoriousScoreboardConfig.showngroups = {}
VictoriousScoreboardConfig.showngroups["superadmin"] = {ShownName = "Super Admin", GroupColor = Color(255, 0, 0)}
VictoriousScoreboardConfig.showngroups["exclusive"] = {ShownName = "Exclusive", GroupColor = Color(255, 111, 0)}
VictoriousScoreboardConfig.showngroups["admin"] = {ShownName = "Admin", GroupColor = Color(94, 255, 110)}
VictoriousScoreboardConfig.showngroups["user"] = {ShownName = "User", GroupColor = Color(0, 230, 255)}

-- GROUPS WHO HAVE THE STAR ICON
VictoriousScoreboardConfig.commandgroups = {"superadmin"}

-- MAXIMUM LETTERS OF USER NAME
VictoriousScoreboardConfig.namemax = 18

-- ADMIN GROUP COLORS
VictoriousScoreboardConfig.groupcol = Color(255, 255, 255)

-- QUICK BAN BUTTON TIME
VictoriousScoreboardConfig.bantime = 0 -- Minutes

-- KICK REASON
VictoriousScoreboardConfig.kreason = "You were kicked from the server!"

-- BAN REASON
VictoriousScoreboardConfig.breason = "You were banned for %s minutes!"

-- PING BAR COLORS
VictoriousScoreboardConfig.pingcol4 = Color(0, 255, 0)
VictoriousScoreboardConfig.pingcol3 = Color(250, 255, 0)
VictoriousScoreboardConfig.pingcol2 = Color(255, 155, 0)
VictoriousScoreboardConfig.pingcol1 = Color(255, 100, 0)

-- TRANSLATIONS

VictoriousScoreboardConfig.KickText = "Kick"

VictoriousScoreboardConfig.GotoText = "Goto"

VictoriousScoreboardConfig.TeleportText = "TP"

VictoriousScoreboardConfig.ReturnText = "Return"

VictoriousScoreboardConfig.JailText = "Jail"

VictoriousScoreboardConfig.BanText = "Ban"

VictoriousScoreboardConfig.CopySteamIDText = "Copy SteamID %s (%s)"

VictoriousScoreboardConfig.NameText = "Player"
VictoriousScoreboardConfig.RankText = "Rank"
VictoriousScoreboardConfig.Kills = "Kills"
VictoriousScoreboardConfig.Deaths = "Deaths"
VictoriousScoreboardConfig.Levels = "Level"
VictoriousScoreboardConfig.Ping = "Ping"

-- ______________________________________________________________________
--______________________________________________________________________

-- THEME
VictoriousScoreboardConfig.servertitlc = Color(255, 255, 255)
VictoriousScoreboardConfig.white = Color(255, 255, 255)
VictoriousScoreboardConfig.grey = Color(230, 230, 230, 240)
VictoriousScoreboardConfig.hover = Color(120, 120, 120)

-- MATERIALS
VictoriousScoreboardConfig.blur = Material("pp/blurscreen")
VictoriousScoreboardConfig.fullping = Material("icons/fullping.png")
VictoriousScoreboardConfig.ping3 = Material("icons/3bar.png")
VictoriousScoreboardConfig.ping2 = Material("icons/2bar.png")
VictoriousScoreboardConfig.ping1 = Material("icons/1bar.png")
VictoriousScoreboardConfig.bullets = Material("icons/kills.png")
VictoriousScoreboardConfig.death = Material("icons/death.png")
VictoriousScoreboardConfig.star = Material("icons/group.png")
VictoriousScoreboardConfig.cog = Material("icons/settings.png")
VictoriousScoreboardConfig.kick = Material("icons/kick.png")
VictoriousScoreboardConfig.tele = Material("icons/teleport.png")
VictoriousScoreboardConfig.test = Material("icons/return.png")
VictoriousScoreboardConfig.ban = Material("icons/ban.png")
VictoriousScoreboardConfig.jail = Material("icons/jail.png")

surface.CreateFont("title", {
	font = "x14y24pxHeadUpDaisy",
	size = 72,
	weight = 500,
	extended = true
})

surface.CreateFont("score", {
	font = "x14y24pxHeadUpDaisy",
	size = 20,
	weight = 500,
	extended = true
})

surface.CreateFont("player", {
	font = "x14y24pxHeadUpDaisy",
	size = 18,
	weight = 100,
	extended = true
})

VictoriousScoreboardConfig.AdminMod = {}

-- ULX
VictoriousScoreboardConfig.AdminMod["ulx"] = {}
VictoriousScoreboardConfig.AdminMod["ulx"].ban = function(ply, time, reason) RunConsoleCommand("ulx", "ban", ply:Nick(), time, reason) end
VictoriousScoreboardConfig.AdminMod["ulx"].kick = function(ply, reason) RunConsoleCommand("ulx", "kick", ply:Nick(), reason) end
VictoriousScoreboardConfig.AdminMod["ulx"].jail = function(ply) RunConsoleCommand("ulx", "jail", ply:Nick()) end
VictoriousScoreboardConfig.AdminMod["ulx"].Goto = function(ply) RunConsoleCommand("ulx", "goto", ply:Nick()) end
VictoriousScoreboardConfig.AdminMod["ulx"].Teleport = function(ply) RunConsoleCommand("ulx", "teleport", ply:Nick()) end
VictoriousScoreboardConfig.AdminMod["ulx"].Return = function(ply) RunConsoleCommand("ulx", "return", ply:Nick()) end

-- Fadmin
VictoriousScoreboardConfig.AdminMod["fadmin"] = {}
VictoriousScoreboardConfig.AdminMod["fadmin"].ban = function(ply, time, reason) RunConsoleCommand("fadmin", "ban", ply:Nick(), time, reason) end
VictoriousScoreboardConfig.AdminMod["fadmin"].kick = function(ply, reason) RunConsoleCommand("fadmin", "kick", ply:Nick(), reason) end
VictoriousScoreboardConfig.AdminMod["fadmin"].jail = function(ply) RunConsoleCommand("fadmin", "jail", ply:Nick(), "normal") end
VictoriousScoreboardConfig.AdminMod["fadmin"].Goto = function(ply) RunConsoleCommand("fadmin", "goto", ply:Nick()) end

-- ServerGuard
VictoriousScoreboardConfig.AdminMod["serverguard"] = {}
VictoriousScoreboardConfig.AdminMod["serverguard"].ban = function(ply, time, reason) RunConsoleCommand("sg", "ban", ply:Nick(), time, reason) end
VictoriousScoreboardConfig.AdminMod["serverguard"].kick = function(ply, reason) RunConsoleCommand("sg", "kick", ply:Nick(), reason) end
VictoriousScoreboardConfig.AdminMod["serverguard"].jail = function(ply) RunConsoleCommand("sg", "jail", ply:Nick(), 0) end
VictoriousScoreboardConfig.AdminMod["serverguard"].Goto = function(ply) RunConsoleCommand("sg", "goto", ply:Nick()) end