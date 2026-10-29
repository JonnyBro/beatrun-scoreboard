conf = conf or {}

-- TITLE
conf.servertitle = "Beatrun Community Server"

-- SHOWN RANKS
conf.showngroups = {}
conf.showngroups["superadmin"] = {ShownName = "Super Admin", GroupColor = Color(255, 0, 0)}
conf.showngroups["admin"] = {ShownName = "Admin", GroupColor = Color(94, 255, 110)}
conf.showngroups["vip"] = {ShownName = "VIP", GroupColor = Color(218, 206, 45)}
conf.showngroups["mostjobless"] = {ShownName = "No J*b", GroupColor = Color(45, 218, 166)}
conf.showngroups["user"] = {ShownName = "User", GroupColor = Color(0, 230, 255)}

-- GROUPS WHO HAVE THE STAR ICON
conf.commandgroups = {"superadmin", "admin"}

-- MAXIMUM LETTERS OF USER NAME
conf.namemax = 18

-- PING BAR COLORS
conf.pingcol4 = Color(0, 255, 0)
conf.pingcol3 = Color(250, 255, 0)
conf.pingcol2 = Color(255, 155, 0)
conf.pingcol1 = Color(255, 100, 0)

-- BAN DURATIONS IN THE PLAYER MENU (MINUTES, 0 = PERMANENT)
conf.bantimes = {
	{"beatrun_scoreboard.menu.ban.hour", 60},
	{"beatrun_scoreboard.menu.ban.day", 1440},
	{"beatrun_scoreboard.menu.ban.week", 10080},
	{"beatrun_scoreboard.menu.ban.perm", 0}
}

-- TRANSLATIONS
conf.translations = {
	en = {
		["beatrun_scoreboard.players"] = "Players: %i/%i",
		["beatrun_scoreboard.player"] = "PLAYER",
		["beatrun_scoreboard.rank"] = "RANK",
		["beatrun_scoreboard.level"] = "LEVEL",
		["beatrun_scoreboard.ping"] = "PING",
		["beatrun_scoreboard.mute"] = "MUTE",
		["beatrun_scoreboard.kills"] = "KILLS",
		["beatrun_scoreboard.data"] = "DATA",
		["beatrun_scoreboard.status"] = "STATUS",
		["beatrun_scoreboard.survived"] = "SURVIVED",
		["beatrun_scoreboard.human"] = "HUMAN",
		["beatrun_scoreboard.infected"] = "INFECTED",
		["beatrun_scoreboard.datatheft"] = "Data Theft",
		["beatrun_scoreboard.rmb"] = "RMB",
		["beatrun_scoreboard.actions"] = "Player actions",
		["beatrun_scoreboard.menu.profile"] = "Open profile",
		["beatrun_scoreboard.menu.copysteamid"] = "Copy SteamID",
		["beatrun_scoreboard.menu.copysteamid64"] = "Copy SteamID64",
		["beatrun_scoreboard.menu.mute"] = "Mute",
		["beatrun_scoreboard.menu.unmute"] = "Unmute",
		["beatrun_scoreboard.menu.goto"] = "Go to",
		["beatrun_scoreboard.menu.bring"] = "Bring",
		["beatrun_scoreboard.menu.return"] = "Return",
		["beatrun_scoreboard.menu.jail"] = "Jail",
		["beatrun_scoreboard.menu.unjail"] = "Unjail",
		["beatrun_scoreboard.menu.course"] = "Course",
		["beatrun_scoreboard.menu.course.restart"] = "Restart course",
		["beatrun_scoreboard.menu.course.lastcp"] = "To last checkpoint",
		["beatrun_scoreboard.menu.course.invalidate"] = "Invalidate run",
		["beatrun_scoreboard.menu.kick"] = "Kick",
		["beatrun_scoreboard.menu.ban"] = "Ban",
		["beatrun_scoreboard.menu.ban.hour"] = "1 hour",
		["beatrun_scoreboard.menu.ban.day"] = "1 day",
		["beatrun_scoreboard.menu.ban.week"] = "1 week",
		["beatrun_scoreboard.menu.ban.perm"] = "Permanently"
	},
	ru = {
		["beatrun_scoreboard.players"] = "Игроки: %i/%i",
		["beatrun_scoreboard.player"] = "ИГРОК",
		["beatrun_scoreboard.rank"] = "РАНГ",
		["beatrun_scoreboard.level"] = "УРОВЕНЬ",
		["beatrun_scoreboard.ping"] = "ПИНГ",
		["beatrun_scoreboard.mute"] = "МУТ",
		["beatrun_scoreboard.kills"] = "УБИЙСТВА",
		["beatrun_scoreboard.data"] = "ДАННЫЕ",
		["beatrun_scoreboard.status"] = "СТАТУС",
		["beatrun_scoreboard.survived"] = "ВЫЖИЛ",
		["beatrun_scoreboard.human"] = "ЧЕЛОВЕК",
		["beatrun_scoreboard.infected"] = "ЗАРАЖЁН",
		["beatrun_scoreboard.datatheft"] = "Кража данных",
		["beatrun_scoreboard.rmb"] = "ПКМ",
		["beatrun_scoreboard.actions"] = "Действия с игроком",
		["beatrun_scoreboard.menu.profile"] = "Открыть профиль",
		["beatrun_scoreboard.menu.copysteamid"] = "Копировать SteamID",
		["beatrun_scoreboard.menu.copysteamid64"] = "Копировать SteamID64",
		["beatrun_scoreboard.menu.mute"] = "Заглушить",
		["beatrun_scoreboard.menu.unmute"] = "Включить звук",
		["beatrun_scoreboard.menu.goto"] = "Телепорт к игроку",
		["beatrun_scoreboard.menu.bring"] = "Телепорт к себе",
		["beatrun_scoreboard.menu.return"] = "Вернуть",
		["beatrun_scoreboard.menu.jail"] = "В тюрьму",
		["beatrun_scoreboard.menu.unjail"] = "Из тюрьмы",
		["beatrun_scoreboard.menu.course"] = "Курс",
		["beatrun_scoreboard.menu.course.restart"] = "Перезапустить курс",
		["beatrun_scoreboard.menu.course.lastcp"] = "На последний чекпоинт",
		["beatrun_scoreboard.menu.course.invalidate"] = "Аннулировать забег",
		["beatrun_scoreboard.menu.kick"] = "Кикнуть",
		["beatrun_scoreboard.menu.ban"] = "Забанить",
		["beatrun_scoreboard.menu.ban.hour"] = "1 час",
		["beatrun_scoreboard.menu.ban.day"] = "1 день",
		["beatrun_scoreboard.menu.ban.week"] = "1 неделя",
		["beatrun_scoreboard.menu.ban.perm"] = "Навсегда"
	}
}

local function AddTranslations(lang)
	for key, text in pairs(conf.translations.en) do
		language.Add(key, text)
	end

	for key, text in pairs(conf.translations[lang] or {}) do
		language.Add(key, text)
	end
end

AddTranslations(GetConVar("gmod_language"):GetString())

cvars.AddChangeCallback("gmod_language", function(_, _, lang)
	AddTranslations(lang)
end, "BeatrunScoreboard")

-- MATERIALS
conf.fullping = Material("icons/fullping.png")
conf.ping3 = Material("icons/3bar.png")
conf.ping2 = Material("icons/2bar.png")
conf.ping1 = Material("icons/1bar.png")
conf.star = Material("icons/group.png")
conf.muted = Material("icons/voice-off.png")
conf.unmuted = Material("icons/voice-on.png")
conf.icons = {
	teleport = Material("icons/teleport.png"),
	["return"] = Material("icons/return.png"),
	jail = Material("icons/jail.png"),
	kick = Material("icons/kick.png"),
	ban = Material("icons/ban.png")
}
