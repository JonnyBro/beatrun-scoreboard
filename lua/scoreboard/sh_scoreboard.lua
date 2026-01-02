if CLIENT then
	local LVLS = {}

	hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
	hook.Remove("ScoreboardShow", "FAdmin_scoreboard")

	hook.Add("Initialize", "RemoveGamemodeFunctions", function()
		GAMEMODE.ScoreboardShow = nil
		GAMEMODE.ScoreboardHide = nil
	end)

	local scoreboard

	local function DrawBlurRect(x, y, w, h, amount, density)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(conf.blur)

		for i = 1, density do
			conf.blur:SetFloat("$blur", i / 3 * (amount or 6))
			conf.blur:Recompute()

			render.UpdateScreenEffectTexture()

			render.SetScissorRect(x, y, x + w, y + h, true)
			surface.DrawTexturedRect(0 * -1, 0 * -1, ScrW(), ScrH())
			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end

	local function LerpColor(t, from, to)
		return Color(Lerp(t, from.r, to.r), Lerp(t, from.g, to.g), Lerp(t, from.b, to.b), Lerp(t, from.a, to.a))
	end

	local scrollW = 500
	local adminWidth = 300

	local function CreatePlayerPanel(ply)
		local panel = vgui.Create("DPanel")

		panel:SetSize(scrollW * 2 + adminWidth, 36)
		panel:SetPlayer(ply)

		local profilebutton = panel:Add("DButton")
		profilebutton:SetPos(300, 2)
		profilebutton:SetSize(32, 32)
		profilebutton:SetPlayer(ply)
		profilebutton.DoClick = function()
			ply:ShowProfile()
			surface.PlaySound("buttons/button9.wav")
		end

		local steambutton = panel:Add("DButton")
		steambutton:SetPos(343, 2)
		steambutton:SetSize(145 + conf.namemax, 32)
		steambutton:SetText("")
		steambutton:SetTooltip(string.format(conf.CopySteamIDText, ply:Nick(), ply:SteamID()))
		steambutton:SetPlayer(ply)
		steambutton.Color = conf.white
		steambutton.text = string.upper(ply:Nick() or "")
		steambutton.Paint = function(self, w, h)
			local nextColor = conf.white

			if self.Depressed then
				nextColor = conf.grey
			elseif self.Hovered then
				nextColor = conf.hover
			end

			self.Color = LerpColor(FrameTime() * 10, self.Color, nextColor)

			surface.SetDrawColor(self.Color)

			draw.DrawText(self.text, "player", 3, 6, self.Color)
		end

		steambutton.DoClick = function()
			SetClipboardText(ply:SteamID())
			surface.PlaySound("buttons/button9.wav")
		end

		local group = ply:GetUserGroup()

		local avatar = panel:Add("AvatarImage")
		avatar:SetSize(32, 32)
		avatar:SetPos(300, 2)
		avatar:SetPlayer(ply)
		avatar:SetMouseInputEnabled(false)
		avatar.PaintOver = function(self, w, h)
			surface.SetDrawColor(225, 225, 225)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		panel.Paint = function(self, w, h)
			if not IsValid(ply) then
				scoreboard:Update()
				return
			end

			local rankSetting = conf.showngroups[ply:GetNWString("usergroup", "")]
			local rankCol = rankSetting and rankSetting.GroupColor or Color(255, 255, 255)
			local rankName = rankSetting and rankSetting.ShownName or ""

			draw.SimpleText(string.upper(rankName), "player", 725, h / 2, rankCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			if table.HasValue(conf.commandgroups, group) then
				surface.SetDrawColor(conf.white)
				surface.SetMaterial(conf.star)
				surface.DrawTexturedRect(700, h / 2 - 8, 16, 16)
			end

			local ping = ply:Ping()

			draw.SimpleText(LVLS[ply:SteamID64()] or 0, "player", 1107, h / 2, conf.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(ping, "player", 1215, h / 2, conf.white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(200, 200, 200, 20)
			surface.SetMaterial(conf.fullping)
			surface.DrawTexturedRect(1170, h / 2 - 5, 20, 20)

			if ping > 259 then
				surface.SetDrawColor(conf.pingcol1)
				surface.SetMaterial(conf.ping1)
				surface.DrawTexturedRect(1170, h / 2 - 5, 20, 20)
			end

			if ping < 260 then
				surface.SetDrawColor(conf.pingcol2)
				surface.SetMaterial(conf.ping2)
				surface.DrawTexturedRect(1170, h / 2 - 5, 20, 20)

				if ping > 259 then conf.pingcol2 = Color(0, 0, 0, 0) end
			end

			if ping < 170 then
				surface.SetDrawColor(conf.pingcol3)
				surface.SetMaterial(conf.ping3)
				surface.DrawTexturedRect(1170, h / 2 - 5, 20, 20)

				if ping > 169 then conf.pingcol3 = Color(0, 0, 0, 0) end
			end

			if ping < 100 then
				surface.SetDrawColor(conf.pingcol4)
				surface.SetMaterial(conf.fullping)
				surface.DrawTexturedRect(1170, h / 2 - 5, 20, 20)

				if ping > 99 then conf.pingcol4 = Color(0, 0, 0, 0) end
			end
		end

		local mutebutton = panel:Add("DButton")
		mutebutton:SetSize(32, 32)
		mutebutton:SetPos(panel:GetWide() - 40, 2)
		mutebutton:SetText("")

		mutebutton.Paint = function(self, w, h)
			local muted = ply:IsMuted()
			local col = muted and Color(255, 80, 80) or Color(255, 255, 255)
			local icon = muted and conf.muted or conf.unmuted

			surface.SetDrawColor(col)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(6, 6, 20, 20)
		end

		mutebutton.DoClick = function()
			ply:SetMuted(not ply:IsMuted())
			surface.PlaySound("buttons/button9.wav")
		end

		return panel
	end

	local function CreateScoreboard()
		scoreboard = vgui.Create("DFrame")
		scoreboard:SetSize(ScrW(), ScrH())
		scoreboard:SetAlpha(0)
		scoreboard:AlphaTo(255, 0.1)
		scoreboard:Center()
		scoreboard:SetTitle("")
		scoreboard:ShowCloseButton(false)
		scoreboard:SetDraggable(false)
		scoreboard:MakePopup()

		scoreboard.Paint = function(self, w, h)
			DrawBlurRect(0, 0, ScrW(), ScrH(), 3, 6)

			surface.SetDrawColor(15, 15, 15, 50)
			surface.DrawRect(0, 0, w, h)

			draw.SimpleText(conf.servertitle, "title", w / 2, 100, conf.servertitlc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.format("Players: %i/%i", player.GetCount(), game.MaxPlayers()), "subtitle", w / 2, 150, conf.servertitlc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(conf.white)
			surface.DrawRect(w / 2 - 500, 202, 1000, 2)

			draw.SimpleText(conf.NameText, "score", w / 2 - 457, 185, conf.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			draw.SimpleText(conf.RankText, "score", w / 2 - 70, 185, conf.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			draw.SimpleText(conf.Levels, "score", w / 2 + 278, 185, conf.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(conf.Ping, "score", w / 2 + 385, 185, conf.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(conf.Mute, "score", w / 2 + 455, 185, conf.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local scrollpanel = scoreboard:Add("DScrollPanel")
		scrollpanel:Center()
		scrollpanel:SetPos(scoreboard:GetWide() / 2 - scrollW - adminWidth, 210)
		scrollpanel:SetSize(scrollW * 2 + adminWidth + 20, scoreboard:GetTall() - 215) --215
		scrollpanel.VBar:SetHideButtons(true)
		scrollpanel.VBar.Paint = function() end
		scrollpanel.VBar.btnUp.Paint = scrollpanel.VBar.Paint
		scrollpanel.VBar.btnDown.Paint = scrollpanel.VBar.Paint
		scrollpanel.VBar.btnGrip.Color = conf.grey
		scrollpanel.VBar.btnGrip.Paint = function(self, w, h)
			local nextColor = conf.grey
			if self.Depressed then
				nextColor = conf.white
			elseif self.Hovered then
				nextColor = conf.hover
			end

			self.Color = LerpColor(FrameTime() * 10, self.Color, nextColor)

			surface.SetDrawColor(0, 0, 0, 0)

			surface.DrawRect(0, 0, w, h)
		end

		scoreboard.Update = function()
			scrollpanel:Clear()

			for _, v in pairs(player.GetAll()) do
				local panel = CreatePlayerPanel(v)

				scrollpanel:AddItem(panel)

				panel:DockMargin(0, 0, 0, 4)
				panel:Dock(TOP)
			end
		end

		scoreboard:Update()
	end

	hook.Add("ScoreboardShow", "Beatrun_ScoreShow", function()
		hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
		hook.Remove("ScoreboardShow", "FAdmin_scoreboard")

		if scoreboard then
			scoreboard:Update()
			scoreboard:SetVisible(true)
			scoreboard:SetAlpha(0)
			scoreboard:AlphaTo(255, 0.1)
		else
			CreateScoreboard()
		end
	end)

	hook.Add("ScoreboardHide", "Beatrun_ScoreHide", function()
		if scoreboard then
			scoreboard:AlphaTo(0, 0.1, 0, function()
				scoreboard:SetVisible(false)
			end)
		end
	end)

	hook.Add("OnParkour", "ScoreboardBeatrunXP", function()
		local lvl = LocalPlayer():GetLevel()
		local steamId = LocalPlayer():SteamID64()

		if (LVLS[steamId] and tonumber(LVLS[steamId]) == tonumber(lvl)) then return end

		LVLS[steamId] = tonumber(lvl)

		net.Start("Scoreboard_SendLevel")
			net.WriteString(lvl)
		net.SendToServer()
	end)

	net.Receive("Scoreboard_ReceiveLevels", function()
		local levelsServer = net.ReadTable()

		LVLS = levelsServer
	end)
end

if SERVER then
	local LVLS = {}

	util.AddNetworkString("Scoreboard_SendLevel")
	util.AddNetworkString("Scoreboard_ReceiveLevels")

	net.Receive("Scoreboard_SendLevel", function(len, ply)
		local level = net.ReadString()

		LVLS[ply:SteamID64()] = tonumber(level)

		net.Start("Scoreboard_ReceiveLevels")
			net.WriteTable(LVLS)
		net.Broadcast()
	end)
end