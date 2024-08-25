-- Several part of code taken from https://github.com/OceanRamen/Saturn

local PANEL_VISIBLE_Y = -6.1
local PANEL_HIDDEN_Y = -9.1
local PANEL_ANIMATION_DELAY = 0.75

function twitch_blinds_init_ui()
	local UI = {
		PARTS = {},

		current_panel = {
			config = nil,
			name = nil,
		},

		panels = {},

		settings = {
			element = nil,
		},
	}

	-- Parts
	------------------------------

	function UI.PARTS.create_toggle(args)
		args = args or {}
		args.active_colour = args.active_colour or G.C.RED
		args.inactive_colour = args.inactive_colour or G.C.BLACK
		args.w = args.w or 3
		args.h = args.h or 0.5
		args.scale = args.scale or 1
		args.label = args.label or nil
		args.label_scale = args.label_scale or 0.4
		args.ref_table = args.ref_table or {}
		args.ref_value = args.ref_value or "test"

		local check = Sprite(0, 0, 0.5 * args.scale, 0.5 * args.scale, G.ASSET_ATLAS["icons"], { x = 1, y = 0 })
		check.states.drag.can = false
		check.states.visible = false

		local info = nil
		if args.info then
			info = {}
			for k, v in ipairs(args.info) do
				table.insert(info, {
					n = G.UIT.R,
					config = { align = "cm", minh = 0.05 },
					nodes = {
						{ n = G.UIT.T, config = { text = v, scale = 0.25, colour = G.C.UI.TEXT_LIGHT } },
					},
				})
			end
			info = { n = G.UIT.R, config = { align = "cm", minh = 0.05 }, nodes = info }
		end

		local t = {
			n = args.col and G.UIT.C or G.UIT.R,
			config = { align = "cm", padding = 0.1, r = 0.1, colour = G.C.CLEAR, focus_args = { funnel_from = true } },
			nodes = {
				{
					n = G.UIT.C,
					config = { align = "cl", minw = 0.3 * args.w },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm", r = 0.1, colour = G.C.BLACK },
							nodes = {
								{
									n = G.UIT.C,
									config = {
										align = "cm",
										r = 0.1,
										padding = 0.03,
										minw = 0.4 * args.scale,
										minh = 0.4 * args.scale,
										outline_colour = G.C.WHITE,
										outline = 1.2 * args.scale,
										line_emboss = 0.5 * args.scale,
										ref_table = args,
										colour = args.inactive_colour,
										button = "toggle_button",
										button_dist = 0.2,
										hover = true,
										toggle_callback = args.callback,
										func = "toggle",
										focus_args = { funnel_to = true },
									},
									nodes = {
										{ n = G.UIT.O, config = { object = check } },
									},
								},
							},
						},
					},
				},
			},
		}
		if args.label then
			ins = {
				n = G.UIT.C,
				config = { align = "cr", minw = args.w },
				nodes = {
					{
						n = G.UIT.T,
						config = { text = args.label, scale = args.label_scale, colour = G.C.UI.TEXT_LIGHT },
					},
					{ n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
				},
			}
			table.insert(t.nodes, 1, ins)
		end
		if args.info then
			t = {
				n = args.col and G.UIT.C or G.UIT.R,
				config = { align = "cm" },
				nodes = {
					t,
					info,
				},
			}
		end
		return t
	end

	function UI.PARTS.create_option_toggle(args)
		local name = args.name or ""
		local box_colour = args.box_colour or G.C.L_BLACK
		local toggle_ref = args.toggle_ref
		local toggle_value = args.toggle_value or "enabled"
		local config_button = args.config_button or nil

		local t = {
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
					config = { align = "cm", padding = 0.1 },
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = DynaText({
									string = name,
									colours = { G.C.WHITE },
									shadow = false,
									scale = 0.5,
								}),
							},
						},
					},
				},
				{
					n = G.UIT.C,
					config = { align = "cm", padding = 0.1 },
					nodes = {
						UI.PARTS.create_toggle({
							ref_table = toggle_ref,
							ref_value = toggle_value,
							active_colour = G.C.BOOSTER,
							callback = args.callback or function(x) end,
							col = true,
						}),
					},
				},
				config_button and {
					n = G.UIT.C,
					config = { align = "cm", padding = 0.1 },
					nodes = {
						UIBox_button({
							label = { "Config" },
							button = config_button,
							minw = 2,
							minh = 0.75,
							scale = 0.5,
							colour = G.C.BOOSTER,
							col = true,
						}),
					},
				},
			},
		}
		return t
	end

	-- Settings
	------------------------------
	-- TODO: localize settings
	function UI.settings.get_settings_tab(_tab)
		local forcing_labels = { "None" }

		for i = 1, #TW_BL.BLINDS.regular do
			table.insert(forcing_labels, TW_BL.BLINDS.regular[i])
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
								text = "Twitch channel name",
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
									prompt_text = "Enter channel name",
									ref_table = TW_BL.SETTINGS.temp,
									ref_value = "channel_name",
									extended_corpus = true,
									keyboard_offset = 1,
								}),
								{ n = G.UIT.C, config = { align = "cm", minw = 0.1 }, nodes = {} },
								UIBox_button({
									label = { "Paste name", "or url" },
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
							label = { "Apply" },
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
										id = "twitch_settings_status",
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
							label = "Twitch Blind frequency",
							scale = 0.8,
							options = { "None", "One after one", "Every one" },
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
							label = "Blinds pool to vote",
							scale = 0.8,
							options = { "Twitch Blinds", "All other", "All" },
							opt_callback = "twbl_settings_change_pool_type",
							current_option = TW_BL.SETTINGS.temp.pool_type,
						}),
					},
				},
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
			local status_element = G.OVERLAY_MENU:get_UIE_by_ID("twitch_settings_status")
			if status_element then
				status_element.config.object.config.string = { text }
				status_element.config.object:update_text(true)
			end
		end
	end

	TW_BL.current_mod.config_tab = function()
		return UI.settings.get_settings_tab("Settings")
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
			local blinds_to_vote = TW_BL.BLINDS.get_twitch_blinds_from_game(TW_BL.SETTINGS.current.pool_type, false)
			if blinds_to_vote then
				local vote_status = TW_BL.CHAT_COMMANDS.get_vote_status()
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

	UI.panels.command_info_1 = {
		localize_status = function(panel, status)
			if status == TW_BL.CHAT_COMMANDS.collector.STATUS.CONNECTED then
				local args_array = G.GAME.pool_flags.twitch_panel_toggle_args or { status = "k_twbl_toggle_ex" }
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
								config = { minw = 4.25 * 3, align = "cm" },
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
			local args_array = G.GAME.pool_flags.twitch_panel_toggle_args
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
				G.GAME.pool_flags.twitch_panel_toggle_args = args_array
			end

			local element = panel.element
			-- TODO: make it less bad?
			local command_element = element:get_UIE_by_ID("twbl_toggle_command")
			if command_element then
				command_element.config.text = args_array.command .. " <" .. localize(args_array.position) .. ">"
			end
			local text_element = element:get_UIE_by_ID("twbl_toggle_text")
			if text_element then
				text_element.config.text = localize(args_array.text)
			end
			element:recalculate()
		end,
	}

	for k, v in pairs(UI.panels) do
		v.name = k
	end

	-- Current panel management
	------------------------------

	function UI.current_panel.set(panel_name, ...)
		local args = { ... }
		if panel_name == UI.current_panel.name then
			UI.current_panel.update(panel_name, unpack(args))
			return panel_name
		end

		local previous_panel = UI.current_panel.config or nil
		local target_panel = panel_name and UI.panels[panel_name] or nil

		local continue = function()
			UI.current_panel.name = panel_name or nil
			UI.current_panel.config = target_panel or nil
			if target_panel and type(target_panel.UIBox_definition) == "function" then
				target_panel.element = UIBox({
					definition = target_panel.UIBox_definition(UI.current_panel.config),
					config = {
						align = "cmri",
						offset = { x = -0.2857, y = PANEL_HIDDEN_Y },
						major = G.ROOM_ATTACH,
						id = "twbl_panel",
					},
				})
				UI.current_panel.update(panel_name, unpack(args))
				UI.current_panel.update_status(TW_BL.CHAT_COMMANDS.collector.connection_status)
				G.E_MANAGER:add_event(Event({
					trigger = "ease",
					blockable = false,
					ref_table = target_panel.element.config.offset,
					ref_value = "y",
					ease_to = PANEL_VISIBLE_Y,
					delay = PANEL_ANIMATION_DELAY,
					func = function(t)
						return t
					end,
				}))
			end
		end

		if previous_panel and previous_panel.element then
			G.E_MANAGER:add_event(Event({
				trigger = "ease",
				blockable = false,
				ref_table = previous_panel.element.config.offset,
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
					UI.reset_panels()
					continue()
					return true
				end,
			}))
		else
			continue()
		end

		return UI.panels[panel_name] and panel_name or nil
	end

	function UI.current_panel.remove(panel_name)
		if not UI.current_panel.config then
			return
		end
		if panel_name ~= UI.current_panel.name then
			return
		end
		return UI.current_panel.set(nil)
	end

	function UI.current_panel.update(panel_name, ...)
		if not UI.current_panel.config then
			return
		end
		if panel_name and panel_name ~= UI.current_panel.name then
			return
		end
		if UI.current_panel.config.element and type(UI.current_panel.config.update) == "function" then
			UI.current_panel.config.update(UI.current_panel.config, ...)
		end
	end

	function UI.current_panel.notify(panel_name, username)
		if not UI.current_panel.config then
			return
		end
		if panel_name and panel_name ~= UI.current_panel.name then
			return
		end
		if UI.current_panel.config.element then
			attention_text({
				text = username,
				scale = 0.3,
				hold = 0.5,
				backdrop_colour = G.C.MONEY,
				align = "rc",
				major = UI.current_panel.config.element,
				offset = { x = 0.15, y = 0 },
			})
		end
	end

	function UI.current_panel.update_status(status)
		local panel = UI.current_panel.config
		if not panel or not panel.element then
			return
		end

		local text = type(panel.localize_status) == "function"
			and panel.localize_status(UI.current_panel.config, status)
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

		local status_element = panel.element:get_UIE_by_ID("twbl_voting_status")
		if status_element then
			status_element.config.object.config.string = { text }
			status_element.config.object:update_text(true)
			panel.element:recalculate()
		end
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

	-- Functions
	------------------------------

	function UI.set_panel(panel_name, write, ...)
		local result = UI.current_panel.set(panel_name, ...)
		if write then
			G.GAME.pool_flags.twitch_current_panel = result
		end
		return result
	end

	function UI.remove_panel(panel_name, write)
		local result = UI.current_panel.remove(panel_name)
		if write then
			G.GAME.pool_flags.twitch_current_panel = result
		end
		return result
	end

	function UI.update_panel(panel_name, ...)
		return UI.current_panel.update(panel_name, ...)
	end

	function UI.create_panel_notify(panel_name, ...)
		return UI.current_panel.notify(panel_name, ...)
	end

	function UI.reset_panels()
		UI.current_panel.config = nil
		UI.current_panel.name = nil
		for k, v in pairs(UI.panels) do
			if v.element then
				v.element:remove()
			end
			v.element = nil
		end
	end

	function UI.set_panel_from_save()
		UI.reset_panels()
		UI.set_panel(G.GAME.pool_flags.twitch_current_panel or nil, false, true)
	end

	-- Events
	------------------------------

	TW_BL.EVENTS.add_listener("new_connection_status", "ui_update_status", function(status, channel_name)
		UI.current_panel.update_status(status)
		UI.settings.update_status(status)
	end)

	return UI
end
