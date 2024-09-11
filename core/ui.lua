local PANEL_VISIBLE_Y = -6.1
local PANEL_HIDDEN_Y = -9.1
local PANEL_ANIMATION_DELAY = 0.75

function twbl_init_ui()
	local UI = {
		PARTS = {},

		panels = {},
		--- @type table<string, PanelController>
		controllers = {},

		settings = {
			element = nil,
		},
	}

	TW_BL.UI = UI

	-- PanelController class
	------------------------------

	--- @class PanelController
	local PanelController = Object:extend()

	function PanelController:init(key_append)
		self.key_append = key_append

		self.panel = nil
		self.panel_key = nil

		self.previous_panel = nil
		self.previous_panel_key = nil

		return self
	end

	function PanelController:get_panel_UIBox(definition)
		return UIBox({
			definition = definition,
			config = {
				align = "cmri",
				offset = { x = 0, y = 0 },
				major = G.ROOM_ATTACH,
				id = "twbl_panel",
			},
		})
	end

	function PanelController:before_remove(panel, panel_name, continue)
		continue()
	end
	function PanelController:remove(panel_name, write)
		if not self.panel or (panel_name and panel_name ~= self.panel_key) then
			return
		end
		return self:set(nil, write, true)
	end
	function PanelController:reset(full)
		if full then
			self.panel = nil
			self.panel_key = nil
			self.previous_panel = nil
			self.previous_panel_key = nil
		end
		for _, v in pairs(UI.panels) do
			if v.parent == self then
				v.parent = nil
				if v.element then
					v.element:remove()
				end
				v.element = nil
			end
		end
	end
	function PanelController:set(panel_name, write, full_reload, ...)
		local args = { panel_name, full_reload, ... }
		if panel_name == self.panel_key then
			if self.panel_key then
				self:update(unpack(args))
			end
			return panel_name
		end

		local previous_panel = self.panel or nil
		local target_panel = panel_name and UI.panels[panel_name] or nil

		self.previous_panel = self.panel
		self.previous_panel_key = self.panel_key
		self.panel_key = panel_name or nil
		self.panel = target_panel or nil

		if write then
			self:save()
		end

		local continue = function()
			self:reset()
			if target_panel then
				target_panel.parent = self
				if type(target_panel.UIBox_definition) == "function" then
					target_panel.element = self:get_panel_UIBox(target_panel.UIBox_definition(target_panel))
					self:update(unpack(args))
					self:update_status(TW_BL.CHAT_COMMANDS.collector.connection_status)
					self:after_set(target_panel, panel_name, function() end)
				end
			end
		end

		if previous_panel and previous_panel.element then
			self:before_remove(previous_panel, previous_panel_key, continue)
		else
			continue()
		end

		return target_panel and panel_name or nil
	end
	function PanelController:after_set(panel, panel_name, continue)
		continue()
	end

	function PanelController:notify(panel_name, message)
		if not self.panel or (panel_name and panel_name ~= self.panel_key) then
			return
		end
		if self.panel.element then
			attention_text({
				text = message,
				scale = 0.3,
				hold = 0.5,
				backdrop_colour = G.C.MONEY,
				align = "rc",
				major = self.panel.element,
				offset = { x = 0.15, y = 0 },
			})
		end
	end
	function PanelController:update(panel_name, full_reload, ...)
		if not self.panel or (panel_name and panel_name ~= self.panel_key) then
			return
		end
		if self.panel.element and type(self.panel.update) == "function" then
			self.panel.update(self.panel, full_reload, ...)
		end
	end
	function PanelController:update_status(status)
		if not self.panel or not self.panel.element then
			return
		end

		local text = type(self.panel.localize_status) == "function" and self.panel.localize_status(self.panel, status)
		if not text then
			text = G.localization.misc.dictionary.k_twbl_status_unknown
			local STATUS = TW_BL.CHAT_COMMANDS.collector.STATUS
			if status == STATUS.NO_CHANNEL_NAME then
				text = G.localization.misc.dictionary.k_twbl_status_no_channel_name
			elseif status == STATUS.CONNECTED then
				text = G.localization.misc.dictionary.k_twbl_status_connected
			elseif status == STATUS.CONNECTING then
				text = G.localization.misc.dictionary.k_twbl_status_connecting
			elseif status == STATUS.DISCONNECTED then
				text = G.localization.misc.dictionary.k_twbl_status_disconnected
			end
		end

		local status_element = self.panel.element:get_UIE_by_ID("twbl_voting_status")
		if status_element then
			status_element.config.object.config.string = { text }
			status_element.config.object:update_text(true)
			self.panel.element:recalculate()
		end
	end

	function PanelController:save()
		if G.GAME then
			TW_BL.G["ui_controller_" .. self.key_append .. "_panel"] = self.panel_key
			TW_BL.G["ui_controller_" .. self.key_append .. "_prev_panel"] = self.previous_panel_key
		end
	end
	function PanelController:load()
		if G.GAME then
			self.previous_panel_key = TW_BL.G["ui_controller_" .. self.key_append .. "_prev_panel"]
			self:set(TW_BL.G["ui_controller_" .. self.key_append .. "_panel"], false, true)
		end
	end

	-- Settings
	------------------------------

	function UI.settings.get_settings_tab(_tab)
		local forcing_labels = { "None" }

		for i = 1, #TW_BL.BLINDS.regular do
			table.insert(forcing_labels, TW_BL.BLINDS.regular[i])
		end
		for i = 1, #TW_BL.BLINDS.showdown do
			table.insert(forcing_labels, TW_BL.BLINDS.showdown[i])
		end

		local result = {
			n = G.UIT.ROOT,
			config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, minh = 5, minw = 5 },
			nodes = {},
		}
		if _tab == "Settings" then
			result.nodes = {
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = localize("twbl_settings_twitch_channel_name"),
								scale = 0.4,
								colour = G.C.UI.TEXT_LIGHT,
								shadow = false,
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm", minw = 0.1 },
							nodes = {
								create_text_input({
									w = 4,
									max_length = 32,
									prompt_text = localize("twbl_settings_enter_channel_name"),
									ref_table = TW_BL.SETTINGS.temp,
									ref_value = "channel_name",
									extended_corpus = true,
									keyboard_offset = 1,
								}),
								{ n = G.UIT.C, config = { align = "cm", minw = 0.1 }, nodes = {} },
								UIBox_button({
									label = {
										localize("twbl_settings_paste_name_or_url_1"),
										localize("twbl_settings_paste_name_or_url_2"),
									},
									minw = 2,
									minh = 0.6,
									button = "twbl_settings_paste_channel_name",
									colour = G.C.BLUE,
									scale = 0.3,
									col = true,
								}),
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {},
				},
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {
						UIBox_button({
							label = { localize("b_set_apply") },
							minw = 2,
							minh = 0.6,
							button = "twbl_settings_save_channel_name",
							colour = G.C.GREEN,
							scale = 0.4,
							col = true,
						}),
						{ n = G.UIT.C, config = { align = "cm", minw = 0.1 }, nodes = {} },
						{
							n = G.UIT.C,
							config = {
								align = "cm",
								padding = 0.05,
								colour = nil,
								r = 0.3,
								minw = 3,
							},
							nodes = {
								{
									n = G.UIT.O,
									config = {
										id = "twbl_settings_status",
										object = DynaText({
											string = UI.settings.get_status_text(),
											colours = { G.C.WHITE },
											shadow = false,
											scale = 0.4,
										}),
									},
								},
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {},
				},
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {
						create_option_cycle({
							w = 4,
							label = localize("twbl_settings_blind_frequency"),
							scale = 0.8,
							options = {
								localize("twbl_settings_blind_frequency_1"),
								localize("twbl_settings_blind_frequency_2"),
								localize("twbl_settings_blind_frequency_3"),
							},
							opt_callback = "twbl_settings_change_blind_frequency",
							current_option = TW_BL.SETTINGS.temp.blind_frequency,
						}),
					},
				},
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {
						create_option_cycle({
							w = 4,
							label = "Blinds available for voting",
							scale = 0.8,
							options = {
								localize("twbl_settings_blind_pool_1"),
								localize("twbl_settings_blind_pool_2"),
								localize("twbl_settings_blind_pool_3"),
							},
							opt_callback = "twbl_settings_change_pool_type",
							current_option = TW_BL.SETTINGS.temp.pool_type,
						}),
					},
				},
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {},
				},
				create_toggle({
					callback = G.FUNCS.twbl_settings_toggle_natural_chat_booster_sticker,
					label_scale = 0.4,
					label = localize("twbl_settings_natural_chat_booster_sticker"),
					ref_table = TW_BL.SETTINGS.temp,
					ref_value = "natural_chat_booster_sticker",
				}),
			}
			if TW_BL.__DEV_MODE then
				table.insert(result.nodes, {
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
						minh = 0.1,
					},
					nodes = {},
				})
				table.insert(result.nodes, {
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.05,
						colour = box_colour,
						r = 0.3,
					},
					nodes = {
						create_option_cycle({
							w = 6,
							label = "[DEV] Forced blind",
							scale = 0.8,
							options = forcing_labels,
							opt_callback = "twbl_settings_change_forced_blind",
							current_option = (TW_BL.SETTINGS.temp.forced_blind or 0) + 1,
						}),
					},
				})
			end
		end

		return result
	end

	function UI.settings.get_status_text()
		local status = TW_BL.CHAT_COMMANDS.collector.connection_status
		local text = G.localization.misc.dictionary.k_twbl_status_unknown

		local STATUS = TW_BL.CHAT_COMMANDS.collector.STATUS
		if status == STATUS.NO_CHANNEL_NAME then
			text = G.localization.misc.dictionary.k_twbl_status_no_channel_name
		elseif status == STATUS.CONNECTED then
			text = G.localization.misc.dictionary.k_twbl_status_connected
		elseif status == STATUS.CONNECTING then
			text = G.localization.misc.dictionary.k_twbl_status_connecting
		elseif status == STATUS.DISCONNECTED then
			text = G.localization.misc.dictionary.k_twbl_status_disconnected
		end
		return text
	end

	function UI.settings.update_status(status)
		if G.OVERLAY_MENU then
			local text = UI.settings.get_status_text()
			local status_element = G.OVERLAY_MENU:get_UIE_by_ID("twbl_settings_status")
			if status_element then
				status_element.config.object.config.string = { text }
				status_element.config.object:update_text(true)
			end
		end
	end

	TW_BL.current_mod.config_tab = function()
		return UI.settings.get_settings_tab("Settings")
	end

	-- Callbacks
	------------------------------

	function G.FUNCS.twbl_settings_change_blind_frequency(args)
		TW_BL.SETTINGS.temp.blind_frequency = args.to_key
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_change_pool_type(args)
		TW_BL.SETTINGS.temp.pool_type = args.to_key
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_change_forced_blind(args)
		TW_BL.SETTINGS.temp.forced_blind = args.to_key > 1 and args.to_key - 1 or nil
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_toggle_natural_chat_booster_sticker(args)
		TW_BL.SETTINGS.temp.natural_chat_booster_sticker = args
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_paste_channel_name(e)
		G.CONTROLLER.text_input_hook = e.UIBox:get_UIE_by_ID("text_input").children[1].children[1]
		for i = 1, 32 do
			G.FUNCS.text_input_key({ key = "right" })
		end
		for i = 1, 32 do
			G.FUNCS.text_input_key({ key = "backspace" })
		end

		local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ""
		local channel_name = clipboard:match("twitch%.tv/([%w_]+)") or clipboard

		for i = 1, #channel_name do
			local c = channel_name:sub(i, i)
			G.FUNCS.text_input_key({ key = c })
		end

		G.FUNCS.text_input_key({ key = "return" })
	end

	function G.FUNCS.twbl_settings_save_channel_name()
		TW_BL.SETTINGS.save()
		TW_BL.CHAT_COMMANDS.collector:connect(TW_BL.SETTINGS.current.channel_name, true)
	end

	-- Panels definitions
	------------------------------

	UI.panels.blind_voting_process = {
		localize_status = function(panel, status)
			if status == TW_BL.CHAT_COMMANDS.collector.STATUS.CONNECTED then
				return G.localization.misc.dictionary.k_twbl_vote_ex
			end
		end,
		UIBox_definition = function(panel)
			return {
				n = G.UIT.ROOT,
				config = { padding = 0.04, r = 0.3, colour = G.C.BLACK },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							padding = 0.04,
						},
						nodes = {
							{
								n = G.UIT.C,
								config = { minw = 1.915, align = "c" },
								nodes = {
									{
										n = G.UIT.O,
										config = {
											id = "twbl_voting_status",
											object = DynaText({
												string = { "" },
												colours = { G.C.UI.TEXT_LIGHT },
												shadow = false,
												rotate = false,
												float = true,
												bump = true,
												scale = 0.35,
												spacing = 1,
												pop_in = 1,
											}),
										},
									},
								},
							},
							{
								n = G.UIT.C,
								config = { minw = 4.25, align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "vote 1",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_1_blind_name",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
									{
										n = G.UIT.T,
										config = {
											text = "0%",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_1_percent",
										},
									},
								},
							},
							{
								n = G.UIT.C,
								config = { minw = 4.25, align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "vote 2",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_2_blind_name",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
									{
										n = G.UIT.T,
										config = {
											text = "0%",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_2_percent",
										},
									},
								},
							},
							{
								n = G.UIT.C,
								config = { minw = 4.25, align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "vote 3",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_3_blind_name",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
									{
										n = G.UIT.T,
										config = {
											text = "0%",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_3_percent",
										},
									},
								},
							},
						},
					},
				},
			}
		end,
		update = function(panel, full_update)
			local element = panel.element
			local blinds_to_vote = TW_BL.BLINDS.get_voting_blinds_from_game(TW_BL.SETTINGS.current.pool_type, false)
			if blinds_to_vote then
				local vote_status = TW_BL.CHAT_COMMANDS.get_vote_status("voting_blind")
				for i = 1, TW_BL.BLINDS.blinds_to_vote do
					if full_update then
						local boss_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_blind_name")
						if boss_element then
							boss_element.config.text = blinds_to_vote[i]
									and localize({ type = "name_text", key = blinds_to_vote[i], set = "Blind" })
								or "-"
						end
					end
					local percent_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_percent")
					if percent_element then
						local variant_status = vote_status[tostring(i)]
						percent_element.config.text = math.floor(variant_status and variant_status.percent or 0) .. "%"
					end
				end
			end
			element:recalculate()
		end,
	}

	UI.panels.voting_process_3 = {
		localize_status = function(panel, status)
			if status == TW_BL.CHAT_COMMANDS.collector.STATUS.CONNECTED then
				local args_array = TW_BL.G["ui_voting_process_3_" .. panel.parent.key_append .. "_args"]
					or { status = "k_twbl_toggle_ex" }
				return localize(args_array.status)
			end
		end,
		UIBox_definition = function(panel)
			return {
				n = G.UIT.ROOT,
				config = { padding = 0.04, r = 0.3, colour = G.C.BLACK },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							padding = 0.04,
						},
						nodes = {
							{
								n = G.UIT.C,
								config = { minw = 1.915, align = "c" },
								nodes = {
									{
										n = G.UIT.O,
										config = {
											id = "twbl_voting_status",
											object = DynaText({
												string = { "" },
												colours = { G.C.UI.TEXT_LIGHT },
												shadow = false,
												rotate = false,
												float = true,
												bump = true,
												scale = 0.35,
												spacing = 1,
												pop_in = 1,
											}),
										},
									},
								},
							},
							{
								n = G.UIT.C,
								config = { minw = 4.25, align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "vote 1",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
													id = "twbl_vote_1_command",
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_1_text",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
									{
										n = G.UIT.T,
										config = {
											text = "0%",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_1_percent",
										},
									},
								},
							},
							{
								n = G.UIT.C,
								config = { minw = 4.25, align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "vote 2",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
													id = "twbl_vote_2_command",
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_2_text",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
									{
										n = G.UIT.T,
										config = {
											text = "0%",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_2_percent",
										},
									},
								},
							},
							{
								n = G.UIT.C,
								config = { minw = 4.25, align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "vote 3",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
													id = "twbl_vote_3_command",
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_3_text",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
									{
										n = G.UIT.T,
										config = {
											text = "0%",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_3_percent",
										},
									},
								},
							},
						},
					},
				},
			}
		end,
		update = function(panel, full_update, args)
			local args_array = TW_BL.G["ui_voting_process_3_" .. panel.parent.key_append .. "_args"]
			local do_update = false
			if args then
				do_update = true
				args_array = args
			end
			if not args_array then
				do_update = true
				args_array = {
					command = "vote",
					status = "k_twbl_vote_ex",
					variants = { "", "", "" },
				}
			end
			if do_update then
				TW_BL.G["ui_voting_process_3_" .. panel.parent.key_append .. "_args"] = args_array
			end

			local element = panel.element
			if args_array.id then
				local vote_status = TW_BL.CHAT_COMMANDS.get_vote_status(args_array.id)
				for i = 1, 3 do
					if full_update then
						local text_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_text")
						if text_element then
							text_element.config.text = localize(args_array.variants[i])
						end

						local command_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_command")
						if command_element then
							command_element.config.text = args_array.command .. " " .. tostring(i)
						end
					end
					local percent_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_percent")
					if percent_element then
						local variant_status = vote_status[tostring(i)]
						percent_element.config.text = math.floor(variant_status and variant_status.percent or 0) .. "%"
					end
				end
			end

			element:recalculate()
		end,
	}

	UI.panels.command_info_1 = {
		localize_status = function(panel, status)
			if status == TW_BL.CHAT_COMMANDS.collector.STATUS.CONNECTED then
				local args_array = TW_BL.G["ui_command_info_1_" .. panel.parent.key_append .. "_args"]
					or { status = "k_twbl_toggle_ex" }
				return localize(args_array.status)
			end
		end,
		UIBox_definition = function(panel)
			return {
				n = G.UIT.ROOT,
				config = { padding = 0.04, r = 0.3, colour = G.C.BLACK },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							padding = 0.04,
						},
						nodes = {
							{
								n = G.UIT.C,
								config = { minw = 1.915, align = "c" },
								nodes = {
									{
										n = G.UIT.O,
										config = {
											id = "twbl_voting_status",
											object = DynaText({
												string = { "" },
												colours = { G.C.UI.TEXT_LIGHT },
												shadow = false,
												rotate = false,
												float = true,
												bump = true,
												scale = 0.35,
												spacing = 1,
												pop_in = 1,
											}),
										},
									},
								},
							},
							{
								n = G.UIT.C,
								config = { minw = 4.25 * 3 + 0.1, align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "toggle",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
													id = "twbl_toggle_command",
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_toggle_text",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
								},
							},
						},
					},
				},
			}
		end,
		update = function(panel, full_update, args)
			local args_array = TW_BL.G["ui_command_info_1_" .. panel.parent.key_append .. "_args"]
			local do_update = false
			if args then
				do_update = true
				args_array = args
			end
			if not args_array then
				do_update = true
				args_array = {
					command = "toggle",
					status = "k_twbl_toggle_ex",
					position = "twbl_position_singular",
					text = "k_twbl_panel_toggle_default",
				}
			end
			if do_update then
				TW_BL.G["ui_command_info_1_" .. panel.parent.key_append .. "_args"] = args_array
			end

			local element = panel.element
			local command_element = element:get_UIE_by_ID("twbl_toggle_command")
			if command_element then
				if args_array.position then
					command_element.config.text = args_array.command .. " <" .. localize(args_array.position) .. ">"
				else
					command_element.config.text = args_array.command
				end
			end
			local text_element = element:get_UIE_by_ID("twbl_toggle_text")
			if text_element then
				text_element.config.text = localize(args_array.text)
			end
			element:recalculate()
		end,
	}

	UI.panels.command_info_1_short = {
		UIBox_definition = function(panel)
			return {
				n = G.UIT.ROOT,
				config = { padding = 0.04, r = 0.3, colour = G.C.BLACK },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							padding = 0.04,
						},
						nodes = {
							{
								n = G.UIT.C,
								config = { align = "cm" },
								nodes = {
									{
										n = G.UIT.C,
										config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "toggle",
													scale = 0.25,
													colour = G.C.UI.TEXT_LIGHT,
													shadow = false,
													id = "twbl_toggle_command",
												},
											},
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
									{
										n = G.UIT.T,
										config = {
											text = "-",
											scale = 0.3,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_toggle_text",
										},
									},
									{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
								},
							},
						},
					},
				},
			}
		end,
		update = function(panel, full_update, args)
			local args_array = TW_BL.G["ui_command_info_1_short_" .. panel.parent.key_append .. "_args"]
			local do_update = false
			if args then
				do_update = true
				args_array = args
			end
			if not args_array then
				do_update = true
				args_array = {
					command = "toggle",
					position = "twbl_position_singular",
					text = "k_twbl_panel_toggle_default",
				}
			end
			if do_update then
				TW_BL.G["ui_command_info_1_short_" .. panel.parent.key_append .. "_args"] = args_array
			end

			local element = panel.element
			local command_element = element:get_UIE_by_ID("twbl_toggle_command")
			if command_element then
				if args_array.position then
					command_element.config.text = args_array.command .. " <" .. localize(args_array.position) .. ">"
				else
					command_element.config.text = args_array.command
				end
			end
			local text_element = element:get_UIE_by_ID("twbl_toggle_text")
			if text_element then
				text_element.config.text = localize(args_array.text)
			end
			element:recalculate()
		end,
	}

	for k, v in pairs(UI.panels) do
		v.key = k
	end

	-- Controllers
	------------------------------

	UI.controllers.game_top = PanelController("game_top")
	function UI.controllers.game_top:get_panel_UIBox(definition)
		return UIBox({
			definition = definition,
			config = {
				align = "cmri",
				offset = { x = -0.2857, y = PANEL_HIDDEN_Y },
				major = G.ROOM_ATTACH,
				id = "twbl_panel",
			},
		})
	end
	function UI.controllers.game_top:before_remove(panel, panel_name, continue)
		G.E_MANAGER:add_event(Event({
			trigger = "ease",
			blockable = false,
			ref_table = panel.element.config.offset,
			ref_value = "y",
			ease_to = PANEL_HIDDEN_Y,
			delay = PANEL_ANIMATION_DELAY,
			func = function(t)
				return t
			end,
		}))
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				continue()
				return true
			end,
		}))
	end
	function UI.controllers.game_top:after_set(panel, panel_name, continue)
		G.E_MANAGER:add_event(Event({
			trigger = "ease",
			blockable = false,
			ref_table = panel.element.config.offset,
			ref_value = "y",
			ease_to = PANEL_VISIBLE_Y,
			delay = PANEL_ANIMATION_DELAY,
			func = function(t)
				return t
			end,
		}))
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				continue()
				return true
			end,
		}))
	end

	UI.controllers.booster_top = PanelController("booster_top")
	function UI.controllers.booster_top:get_panel_UIBox(definition)
		return UIBox({
			definition = definition,
			config = {
				align = "cm",
				offset = { x = 0, y = -7.12 },
				major = G.hand,
				id = "twbl_panel",
			},
		})
	end
	function UI.controllers.booster_top:after_set(panel, panel_name, continue)
		panel.element.states.visible = false
		G.E_MANAGER:add_event(Event({
			func = function()
				G.E_MANAGER:add_event(Event({
					func = function()
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 1.3 * math.sqrt(G.SETTINGS.GAMESPEED),
							blockable = false,
							func = function()
								panel.element.states.visible = true
								if G.twbl_chat_booster_cards then
									G.twbl_chat_booster_cards:hard_set_T(
										panel.element.T.x + panel.element.T.w,
										panel.element.T.y - panel.element.T.h,
										nil,
										nil
									)
								elseif G.twbl_chat_booster_planets then
									G.twbl_chat_booster_planets:hard_set_T(
										panel.element.T.x,
										panel.element.T.y + panel.element.T.h,
										panel.element.T.w,
										nil
									)
								end
								
								continue()
								return true
							end,
						}))
						return true
					end,
				}))
				return true
			end,
		}))
	end

	-- Functions
	------------------------------

	function UI.set_panel(controller, panel_name, write, full_reload, ...)
		return UI.controllers[controller]:set(panel_name, write, full_reload, ...)
	end

	function UI.remove_panel(controller, panel_name, write)
		return UI.controllers[controller]:remove(panel_name, write)
	end

	function UI.update_panel(controller, panel_name, full_reload, ...)
		return UI.controllers[controller]:update(panel_name, full_reload, ...)
	end

	function UI.create_panel_notify(controller, panel_name, message)
		return UI.controllers[controller]:notify(panel_name, message)
	end

	function UI.reset()
		for k, v in pairs(UI.controllers) do
			v:reset(true)
		end
	end

	function UI.get_panels_from_game()
		for k, v in pairs(UI.controllers) do
			v:load()
		end
	end

	-- Events
	------------------------------

	TW_BL.EVENTS.add_listener("new_connection_status", "ui_update_status", function(status, channel_name)
		for k, v in pairs(UI.controllers) do
			v:update_status(status)
		end
		UI.settings.update_status(status)
	end)

	return UI
end
