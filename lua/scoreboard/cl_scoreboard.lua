hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
hook.Remove("ScoreboardShow", "FAdmin_scoreboard")

hook.Add("Initialize", "RemoveGamemodeFunctions", function()
	GAMEMODE.ScoreboardShow = nil
	GAMEMODE.ScoreboardHide = nil
end)

local scoreboard

hook.Add("OnScreenSizeChanged", "BeatrunScoreboard_ScreenSize", function()
	if IsValid(scoreboard) then scoreboard:Remove() end
end)

local commandGroups = {}

for _, group in ipairs(conf.commandgroups) do
	commandGroups[group] = true
end

local humanColor = Color(95, 245, 130)
local infectedColor = Color(255, 80, 80)

local function FormatTime(t)
	return string.FormattedTime(t, "%02i:%02i")
end

--[[
	Gamemodes, first active one wins

	value(ply)  text and color for the mode column
	sort(ply)   higher goes first
]]
local MODES = {
	{
		global = "GM_INFECTION",
		name = "beatrun.infection.name",
		header = "beatrun_scoreboard.survived",
		value = function(ply)
			local infected = ply:GetNW2Bool("Infected")
			local time = ply:GetNW2Float("PBTime")
			local text = BeatrunUI.L(infected and "beatrun_scoreboard.infected" or "beatrun_scoreboard.human")

			if time > 0 then text = text .. " " .. FormatTime(time) end

			return text, infected and infectedColor or humanColor
		end,
		sort = function(ply)
			return (ply:GetNW2Bool("Infected") and 0 or 1e6) + ply:GetNW2Float("PBTime")
		end
	},
	{
		global = "GM_DEATHMATCH",
		name = "beatrun.deathmatch.name",
		header = "beatrun_scoreboard.kills",
		value = function(ply)
			return ply:GetNW2Int("DeathmatchKills", 0)
		end,
		sort = function(ply)
			return ply:GetNW2Int("DeathmatchKills", 0)
		end
	},
	{
		global = "GM_DATATHEFT",
		name = "beatrun_scoreboard.datatheft",
		header = "beatrun_scoreboard.data",
		value = function(ply)
			return ply:GetNW2Int("DataBanked", 0) .. " (+" .. ply:GetNW2Int("DataCubes", 0) .. ")"
		end,
		sort = function(ply)
			return ply:GetNW2Int("DataBanked", 0) * 1000 + ply:GetNW2Int("DataCubes", 0)
		end
	},
	{
		global = "GM_EVENTMODE",
		name = "beatrun.eventmode.name",
		header = "beatrun_scoreboard.status",
		value = function(ply)
			local status = GetStatusData(ply:GetNW2String("EPlayerStatus", "Member"))

			return string.upper(BeatrunUI.L(status.label_key)), status.color
		end,
		sort = function(ply)
			local status = ply:GetNW2String("EPlayerStatus", "Member")

			return status == "Manager" and 2 or status == "Suspended" and 0 or 1
		end
	}
}

local function ActiveMode()
	for _, mode in ipairs(MODES) do
		if GetGlobalBool(mode.global) then return mode end
	end
end

local function LevelSort(ply)
	return ply:GetLevel() * 1e9 + ply:GetXP()
end

-- GetLevelRatio() caches one value for every player, so it's only valid for LocalPlayer
local function LevelRatio(ply)
	local level = ply:GetLevel()
	local prev = CalcXPForNextLevel(level - 1)
	local need = CalcXPForNextLevel(level) - prev

	if need <= 0 then return 0 end

	return math.Clamp((ply:GetXP() - prev) / need, 0, 1)
end

local function ShortName(ply)
	local name = string.upper(ply:Nick())
	local len = utf8.len(name)

	if len and len > conf.namemax then name = string.sub(name, 1, utf8.offset(name, conf.namemax + 1) - 1) .. "..." end

	return name
end

local function PingTier(ping)
	if ping < 100 then return conf.fullping, conf.pingcol4 end
	if ping < 170 then return conf.ping3, conf.pingcol3 end
	if ping < 260 then return conf.ping2, conf.pingcol2 end

	return conf.ping1, conf.pingcol1
end

-- Column x positions, shared by the header and the rows so they always line up
local function Columns(w, mode)
	local S = BeatrunUI.S
	local mute = w - S(8) - S(32)
	local ping = mute - S(140)
	local level = ping - S(110)
	local modeX = mode and level - S(180)
	local rank = (modeX or level) - S(240)

	return {
		name = S(50),
		rank = rank,
		mode = modeX,
		level = level,
		ping = ping,
		mute = mute
	}
end

local function StyleMenu(menu)
	menu.Paint = function(_, w, h)
		local theme = CurrentTheme()

		surface.SetDrawColor(theme.bg.r, theme.bg.g, theme.bg.b, math.max(theme.bg.a, 240))
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(theme.border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
end

local function StyleOption(option, icon)
	local S = BeatrunUI.S

	option:SetFont("BeatrunUISmall")
	option:SetTextInset(S(icon and 36 or 12), 0)

	-- DMenuOption forces a height of 22 in its own PerformLayout
	option.PerformLayout = function(s, w, h)
		local contentW = s:GetContentSize()

		s:SetSize(math.max(s:GetParent():GetWide(), contentW + S(64)), S(30))

		DButton.PerformLayout(s, w, h)
	end

	option.Paint = function(s, w, h)
		local theme = CurrentTheme()
		local hovered = s:IsHovered() or IsValid(s.SubMenu) and s.SubMenu:IsVisible()
		local col = hovered and theme.accent or theme.text.primary

		s:SetTextColor(col)

		if hovered then
			surface.SetDrawColor(theme.panels.secondary)
			surface.DrawRect(0, 0, w, h)
		end

		if icon then
			local size = S(16)

			surface.SetDrawColor(col)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(S(12), (h - size) / 2, size, size)
		end

		if s.SubMenu then draw.SimpleText("▸", "AEUIDefault", w - S(12), h / 2, theme.text.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
	end
end

local function AddOption(menu, text, icon, func)
	local option = menu:AddOption(BeatrunUI.L(text), func)
	StyleOption(option, icon)

	return option
end

local function AddSubMenu(menu, text, icon)
	local sub, option = menu:AddSubMenu(BeatrunUI.L(text))
	StyleOption(option, icon)
	StyleMenu(sub)

	return sub
end

local function AddSpacer(menu)
	local spacer = menu:AddSpacer()
	if not IsValid(spacer) then return end

	spacer.Paint = function(_, w, h)
		surface.SetDrawColor(CurrentTheme().border)
		surface.DrawRect(0, h / 2, w, 1)
	end
end

local function AddVolumeSlider(menu, ply)
	local S = BeatrunUI.S

	local panel = vgui.Create("DPanel", menu)
	panel:SetSize(S(260), S(34))
	panel:DockPadding(S(36), 0, S(12), 0)
	panel.Paint = function(_, w, h)
		local size = S(16)

		surface.SetDrawColor(CurrentTheme().text.primary)
		surface.SetMaterial(conf.unmuted)
		surface.DrawTexturedRect(S(12), (h - size) / 2, size, size)
	end

	local slider = BeatrunUI.MakeSlider(panel)
	slider:Dock(FILL)
	slider:SetMinMax(0, 100)
	slider:SetDecimals(0)
	slider:SetValue(math.Round(ply:GetVoiceVolumeScale() * 100))
	slider.OnValueChanged = function(_, value)
		if IsValid(ply) then ply:SetVoiceVolumeScale(value / 100) end
	end

	menu:AddPanel(panel)
end

local function CanRun(command)
	return ULib ~= nil and ULib.ucl.query(LocalPlayer(), command)
end

local function RunUlx(command, ply, ...)
	if not IsValid(ply) then return end

	RunConsoleCommand("ulx", command, "$" .. ply:UserID(), ...)
end

local function OpenPlayerMenu(ply)
	if not IsValid(ply) then return end

	local isSelf = ply == LocalPlayer()
	local menu = DermaMenu()
	StyleMenu(menu)

	AddOption(menu, "beatrun_scoreboard.menu.profile", nil, function()
		if IsValid(ply) then ply:ShowProfile() end
	end)

	AddOption(menu, "beatrun_scoreboard.menu.copysteamid", nil, function()
		if IsValid(ply) then SetClipboardText(ply:SteamID()) end
	end)

	AddOption(menu, "beatrun_scoreboard.menu.copysteamid64", nil, function()
		if IsValid(ply) then SetClipboardText(ply:SteamID64() or "") end
	end)

	if not isSelf then
		local muted = ply:IsMuted()

		AddOption(menu, muted and "beatrun_scoreboard.menu.unmute" or "beatrun_scoreboard.menu.mute", muted and conf.unmuted or conf.muted, function()
			if IsValid(ply) then ply:SetMuted(not muted) end
		end)

		AddVolumeSlider(menu, ply)
	end

	local admin = {}

	if not isSelf and CanRun("ulx goto") then table.insert(admin, {"beatrun_scoreboard.menu.goto", conf.icons.teleport, function() RunUlx("goto", ply) end}) end
	if not isSelf and CanRun("ulx bring") then table.insert(admin, {"beatrun_scoreboard.menu.bring", conf.icons.teleport, function() RunUlx("bring", ply) end}) end
	if CanRun("ulx return") then table.insert(admin, {"beatrun_scoreboard.menu.return", conf.icons["return"], function() RunUlx("return", ply) end}) end

	if CanRun("ulx jail") then
		table.insert(admin, {"beatrun_scoreboard.menu.jail", conf.icons.jail, function() RunUlx("jail", ply) end})
		table.insert(admin, {"beatrun_scoreboard.menu.unjail", conf.icons.jail, function() RunUlx("unjail", ply) end})
	end

	if #admin > 0 then
		AddSpacer(menu)

		for _, item in ipairs(admin) do
			AddOption(menu, item[1], item[2], item[3])
		end
	end

	local course = {}

	if CanRun("ulx courserestart") then table.insert(course, {"beatrun_scoreboard.menu.course.restart", function() RunUlx("courserestart", ply) end}) end
	if CanRun("ulx tolastcp") then table.insert(course, {"beatrun_scoreboard.menu.course.lastcp", function() RunUlx("tolastcp", ply) end}) end
	if CanRun("ulx invalidaterun") then table.insert(course, {"beatrun_scoreboard.menu.course.invalidate", function() RunUlx("invalidaterun", ply) end}) end

	if #course > 0 then
		local sub = AddSubMenu(menu, "beatrun_scoreboard.menu.course", conf.icons["return"])

		for _, item in ipairs(course) do
			AddOption(sub, item[1], nil, item[2])
		end
	end

	local canKick = not isSelf and CanRun("ulx kick")
	local canBan = not isSelf and CanRun("ulx ban")

	if canKick or canBan then AddSpacer(menu) end

	if canKick then AddOption(menu, "beatrun_scoreboard.menu.kick", conf.icons.kick, function() RunUlx("kick", ply) end) end

	if canBan then
		local sub = AddSubMenu(menu, "beatrun_scoreboard.menu.ban", conf.icons.ban)

		for _, ban in ipairs(conf.bantimes) do
			AddOption(sub, ban[1], nil, function() RunUlx("ban", ply, tostring(ban[2])) end)
		end
	end

	menu:Open()
end

local function CreatePlayerRow(parent, ply)
	local S = BeatrunUI.S

	local row = parent:Add("DPanel")
	row:SetTall(S(40))
	row:Dock(TOP)
	row:DockMargin(0, 0, 0, S(4))
	row.ply = ply
	row.OnMousePressed = function(self, code)
		if code == MOUSE_RIGHT then OpenPlayerMenu(ply) end
	end

	local profile = row:Add("DButton")
	profile:SetText("")
	profile:SetCursor("hand")
	profile.Paint = nil
	profile.DoClick = function()
		if not IsValid(ply) then return end

		ply:ShowProfile()
		surface.PlaySound("buttons/button9.wav")
	end
	profile.DoRightClick = function() OpenPlayerMenu(ply) end

	local avatar = profile:Add("AvatarImage")
	avatar:Dock(FILL)
	avatar:SetPlayer(ply, 64)
	avatar:SetMouseInputEnabled(false)
	avatar.PaintOver = function(self, w, h)
		surface.SetDrawColor(CurrentTheme().border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local name = row:Add("DButton")
	name:SetText("")
	name:SetCursor("hand")
	name.Paint = function(self, w, h)
		if not IsValid(ply) then return end

		local theme = CurrentTheme()
		local col = self:IsDown() and theme.text.muted or self:IsHovered() and theme.accent or theme.text.primary

		draw.SimpleText(ShortName(ply), "BeatrunUI", 0, h / 2, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	name.DoClick = function()
		if not IsValid(ply) then return end

		SetClipboardText(ply:SteamID())
		surface.PlaySound("buttons/button9.wav")
	end
	name.DoRightClick = function() OpenPlayerMenu(ply) end

	local mute = row:Add("DButton")
	mute:SetText("")
	mute:SetCursor("hand")
	mute.Paint = function(self, w, h)
		if not IsValid(ply) then return end

		ApplyButtonTheme(self, w, h, "secondary")

		local theme = CurrentTheme()
		local muted = ply:IsMuted()
		local iconSize = S(20)

		surface.SetDrawColor(muted and theme.buttons.danger.t or theme.text.primary)
		surface.SetMaterial(muted and conf.muted or conf.unmuted)
		surface.DrawTexturedRect((w - iconSize) / 2, (h - iconSize) / 2, iconSize, iconSize)
	end
	mute.DoClick = function()
		if not IsValid(ply) then return end

		ply:SetMuted(not ply:IsMuted())
		surface.PlaySound("buttons/button9.wav")
	end
	mute.DoRightClick = function() OpenPlayerMenu(ply) end
	mute:SetVisible(ply ~= LocalPlayer())

	row.PerformLayout = function(self, w, h)
		local cols = Columns(w, ActiveMode())
		local size = S(32)
		local y = (h - size) / 2

		profile:SetPos(S(8), y)
		profile:SetSize(size, size)

		name:SetPos(cols.name, 0)
		name:SetSize(cols.rank - cols.name - S(40), h)

		mute:SetPos(cols.mute, y)
		mute:SetSize(size, size)
	end

	row.Paint = function(self, w, h)
		if not IsValid(ply) then return end

		local theme = CurrentTheme()
		local mode = ActiveMode()
		local cols = Columns(w, mode)

		BeatrunUI.PaintPanel(w, h, (self:IsHovered() or self:IsChildHovered()) and theme.panels.secondary or theme.panels.primary, ply == LocalPlayer())

		local group = ply:GetUserGroup()
		local rank = conf.showngroups[group]

		if commandGroups[group] then
			local starSize = S(16)

			surface.SetDrawColor(theme.text.primary)
			surface.SetMaterial(conf.star)
			surface.DrawTexturedRect(cols.rank - starSize - S(8), (h - starSize) / 2, starSize, starSize)
		end

		if rank then draw.SimpleText(string.upper(rank.ShownName), "BeatrunUI", cols.rank, h / 2, rank.GroupColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

		if mode then
			local text, col = mode.value(ply)

			draw.SimpleText(text, "BeatrunUI", cols.mode, h / 2, col or theme.text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText(ply:GetLevel(), "BeatrunUI", cols.level, h / 2 - S(3), theme.text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local barW, barH = S(60), S(3)
		local barY = h - S(9)

		surface.SetDrawColor(theme.panels.secondary)
		surface.DrawRect(cols.level, barY, barW, barH)
		surface.SetDrawColor(theme.accent)
		surface.DrawRect(cols.level, barY, math.Round(barW * LevelRatio(ply)), barH)

		local ping = ply:Ping()
		local icon, iconCol = PingTier(ping)
		local iconSize = S(20)
		local iconY = (h - iconSize) / 2

		surface.SetDrawColor(theme.text.dark.r, theme.text.dark.g, theme.text.dark.b, 40)
		surface.SetMaterial(conf.fullping)
		surface.DrawTexturedRect(cols.ping, iconY, iconSize, iconSize)

		surface.SetDrawColor(iconCol)
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(cols.ping, iconY, iconSize, iconSize)

		local pingX = cols.ping + iconSize + S(8)
		local pingW = draw.SimpleText(ping, "BeatrunUI", pingX, h / 2, theme.text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		local loss = ply:GetNW2Int("PLoss", 0)

		if loss > 0 then draw.SimpleText(loss .. "%", "BeatrunUISmall", pingX + pingW + S(6), h / 2, theme.buttons.danger.t, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
	end

	return row
end

local function CreateScoreboard()
	local S = BeatrunUI.S
	local L = BeatrunUI.L

	scoreboard = vgui.Create("DFrame")
	scoreboard:SetSize(ScrW(), ScrH())
	scoreboard:SetTitle("")
	scoreboard:ShowCloseButton(false)
	scoreboard:SetDraggable(false)
	scoreboard:DockPadding(0, 0, 0, 0)
	scoreboard:MakePopup()
	scoreboard:SetKeyboardInputEnabled(false)
	scoreboard.rows = {}

	scoreboard.Paint = function(self, w, h)
		local theme = CurrentTheme()
		local mode = ActiveMode()

		if theme.blur then BeatrunUI.DrawPanelBlur(self) end

		surface.SetDrawColor(theme.bg.r, theme.bg.g, theme.bg.b, math.min(theme.bg.a, 200))
		surface.DrawRect(0, 0, w, h)

		local info = {
			string.format(L("beatrun_scoreboard.players"), player.GetCount(), game.MaxPlayers()),
			game.GetMap(),
			L(mode and mode.name or "beatrun.hud.freeplay")
		}

		draw.SimpleText(conf.servertitle, "BeatrunUILarge", w / 2, S(110), theme.text.primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(table.concat(info, "  //  "), "BeatrunUI", w / 2, S(150), theme.text.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local container = scoreboard:Add("DPanel")
	container:Dock(FILL)
	container.Paint = nil

	local width = math.min(S(1100), ScrW() - S(80))
	local side = (ScrW() - width) / 2

	container:DockPadding(side, S(180), side, S(24))

	local scroll = container:Add("DScrollPanel")
	ApplyScrollTheme(scroll)

	local header = container:Add("DPanel")
	header:Dock(TOP)
	header:SetTall(S(36))
	header:DockMargin(0, 0, 0, S(8))
	header.Paint = function(self, w, h)
		local theme = CurrentTheme()
		local mode = ActiveMode()
		local cols = Columns(scroll:GetCanvas():GetWide(), mode)
		local y = h / 2

		draw.SimpleText(L("beatrun_scoreboard.player"), "BeatrunUISmall", cols.name, y, theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(L("beatrun_scoreboard.rank"), "BeatrunUISmall", cols.rank, y, theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if mode then draw.SimpleText(L(mode.header), "BeatrunUISmall", cols.mode, y, theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

		draw.SimpleText(L("beatrun_scoreboard.level"), "BeatrunUISmall", cols.level, y, theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(L("beatrun_scoreboard.ping"), "BeatrunUISmall", cols.ping, y, theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(L("beatrun_scoreboard.mute"), "BeatrunUISmall", cols.mute + S(16), y, theme.text.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(theme.text.primary)
		surface.DrawRect(0, h - S(2), w, S(2))
	end

	local footer = container:Add("DPanel")
	footer:Dock(BOTTOM)
	footer:DockMargin(0, S(12), 0, 0)
	footer.Paint = nil

	local hint = BeatrunUI.MakeKeyHint(footer, "beatrun_scoreboard.rmb", "beatrun_scoreboard.actions")
	footer:SetTall(hint:GetTall())
	footer.PerformLayout = function()
		hint:CenterHorizontal()
	end

	scroll:Dock(FILL)

	function scoreboard:Update()
		for ply, row in pairs(self.rows) do
			if not IsValid(ply) then
				row:Remove()
				self.rows[ply] = nil
			end
		end

		for _, ply in ipairs(player.GetAll()) do
			if not self.rows[ply] then self.rows[ply] = CreatePlayerRow(scroll, ply) end
		end

		local mode = ActiveMode()
		local key = mode and mode.sort or LevelSort
		local sorted = {}
		local keys = {}

		for ply in pairs(self.rows) do
			table.insert(sorted, ply)
			keys[ply] = key(ply)
		end

		table.sort(sorted, function(a, b)
			if keys[a] ~= keys[b] then return keys[a] > keys[b] end

			return a:UserID() < b:UserID()
		end)

		for i, ply in ipairs(sorted) do
			self.rows[ply]:SetZPos(i)
		end

		if mode ~= self.mode then
			self.mode = mode

			for _, row in pairs(self.rows) do
				row:InvalidateLayout()
			end
		end
	end

	scoreboard.Think = function(self)
		if (self.nextUpdate or 0) > RealTime() then return end

		self.nextUpdate = RealTime() + 0.5
		self:Update()
	end
end

hook.Add("ScoreboardShow", "Beatrun_ScoreShow", function()
	hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
	hook.Remove("ScoreboardShow", "FAdmin_scoreboard")

	if not IsValid(scoreboard) then CreateScoreboard() end

	scoreboard:Stop()
	scoreboard:Update()
	scoreboard:SetVisible(true)
	scoreboard:SetAlpha(0)
	scoreboard:AlphaTo(255, 0.1)
end)

hook.Add("ScoreboardHide", "Beatrun_ScoreHide", function()
	if not IsValid(scoreboard) then return end

	CloseDermaMenus()

	scoreboard:Stop()
	scoreboard:AlphaTo(0, 0.1, 0, function()
		scoreboard:SetVisible(false)
	end)
end)
