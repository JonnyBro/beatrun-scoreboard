conf = conf or {}

-- TITLE
conf.servertitle = "Beatrun Community Server"

-- SHOWN RANKS
conf.showngroups = {}
conf.showngroups["superadmin"] = {ShownName = "Super Admin", GroupColor = Color(255, 0, 0)}
conf.showngroups["admin"] = {ShownName = "Admin", GroupColor = Color(94, 255, 110)}
conf.showngroups["vip"] = {ShownName = "VIP", GroupColor = Color(218, 206, 45)}
conf.showngroups["user"] = {ShownName = "User", GroupColor = Color(0, 230, 255)}

-- GROUPS WHO HAVE THE STAR ICON
conf.commandgroups = {"superadmin", "admin"}

-- MAXIMUM LETTERS OF USER NAME
conf.namemax = 18

-- ADMIN GROUP COLORS
conf.groupcol = Color(255, 255, 255)

-- PING BAR COLORS
conf.pingcol4 = Color(0, 255, 0)
conf.pingcol3 = Color(250, 255, 0)
conf.pingcol2 = Color(255, 155, 0)
conf.pingcol1 = Color(255, 100, 0)

-- TRANSLATIONS
conf.CopySteamIDText = "Copy SteamID of %s (%s)"
conf.NameText = "PLAYER"
conf.RankText = "RANK"
conf.Levels = "LEVEL"
conf.Ping = "PING"
conf.Mute = "MUTE"

-- THEME
conf.servertitlc = Color(255, 255, 255)
conf.white = Color(255, 255, 255)
conf.grey = Color(230, 230, 230, 240)
conf.hover = Color(120, 120, 120)

-- MATERIALS
conf.blur = Material("pp/blurscreen")
conf.fullping = Material("icons/fullping.png")
conf.ping3 = Material("icons/3bar.png")
conf.ping2 = Material("icons/2bar.png")
conf.ping1 = Material("icons/1bar.png")
conf.star = Material("icons/group.png")
conf.muted = Material("icons/voice-off.png")
conf.unmuted = Material("icons/voice-on.png")

-- FONTS
surface.CreateFont("title", {
	shadow = true,
	blursize = 0,
	underline = false,
	rotary = false,
	strikeout = false,
	additive = false,
	antialias = false,
	extended = false,
	scanlines = 2,
	font = "x14y24pxHeadUpDaisy",
	italic = false,
	outline = false,
	symbol = false,
	weight = 500,
	size = 72
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