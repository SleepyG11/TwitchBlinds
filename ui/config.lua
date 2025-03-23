function TW_BL.UI.PARTS.create_settings_section(label, nodes)
	local result_nodes = {
		{
			n = G.UIT.R,
			config = { align = "cm", padding = 0.1 },
			nodes = {
				{
					n = G.UIT.T,
					config = {
						align = "cm",
						text = label,
						colour = G.C.WHITE,
						scale = 0.45,
						shadow = true,
					},
				},
			},
		},
	}
	for k, v in ipairs(nodes) do
		table.insert(result_nodes, {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				v,
			},
		})
	end

	return {
		n = G.UIT.R,
		config = { align = "cm", padding = 0.1, colour = G.C.BLACK, r = 0.5, minw = 5 },
		nodes = result_nodes,
	}
end

function TW_BL.UI.PARTS.create_description_text(text, center)
	local desc_lines = {}
	for i = 1, #text do
		table.insert(desc_lines, {
			n = G.UIT.R,
			config = { padding = 0.025, align = center and "cm" or "" },
			nodes = {
				{
					n = G.UIT.T,
					config = {
						text = text[i],
						scale = 0.3,
						colour = { 1, 1, 1, 0.75 },
					},
				},
			},
		})
	end
	table.insert(desc_lines, {
		n = G.UIT.R,
		config = { padding = 0.025 },
	})

	return {
		n = G.UIT.R,
		config = { align = "cm" },
		nodes = desc_lines,
	}
end

function TW_BL.UI.PARTS.create_settings_channel_name_component()
	TW_BL.SETTINGS.temp.channel_name = TW_BL.SETTINGS.current.channel_name
	return {
		n = G.UIT.R,
		config = { align = "cm", padding = 0.1 },
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					padding = 0.06,
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = localize("twbl_settings_twitch_channel_name"),
							scale = 0.4,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					padding = 0.06,
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
								callback = function() end,
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
					padding = 0.06,
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
										string = TW_BL.UI.settings.get_status_text(),
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
		},
	}
end

function TW_BL.UI.settings.get_general_tab()
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
	result.nodes = {
		TW_BL.UI.PARTS.create_settings_section("Connection", {
			TW_BL.UI.PARTS.create_settings_channel_name_component(),
		}),
		{
			n = G.UIT.R,
			config = {
				align = "cm",
				padding = 0.05,
			},
		},
		TW_BL.UI.PARTS.create_settings_section("Interactions", {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					padding = 0.05,
				},
				nodes = {
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									padding = 0.05,
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
										current_option = TW_BL.SETTINGS.current.blind_frequency,
									}),
									TW_BL.UI.PARTS.create_description_text(
										localize("twbl_settings_blind_frequency_desc"),
										true
									),
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { padding = 0.1 },
					},
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									padding = 0.05,
								},
								nodes = {
									create_option_cycle({
										w = 4,
										label = localize("twbl_settings_delay_for_chat"),
										scale = 0.8,
										options = {
											localize("twbl_settings_delay_for_chat_1"),
											localize("twbl_settings_delay_for_chat_2"),
											localize("twbl_settings_delay_for_chat_3"),
											localize("twbl_settings_delay_for_chat_4"),
											localize("twbl_settings_delay_for_chat_5"),
										},
										opt_callback = "twbl_settings_change_delay_for_chat",
										current_option = TW_BL.SETTINGS.current.delay_for_chat,
									}),
									TW_BL.UI.PARTS.create_description_text(
										localize("twbl_settings_delay_for_chat_desc"),
										true
									),
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
				},
				nodes = {
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									padding = 0.05,
								},
								nodes = {
									create_toggle({
										callback = G.FUNCS.twbl_settings_toggle_mystic_variants,
										label_scale = 0.35,
										label = localize("twbl_settings_mystic_variants"),
										ref_table = TW_BL.SETTINGS.current,
										ref_value = "mystic_variants",
									}),
									TW_BL.UI.PARTS.create_description_text(
										localize("twbl_settings_mystic_variants_desc"),
										true
									),
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { padding = 0.1 },
					},
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									padding = 0.05,
								},
								nodes = {
									create_toggle({
										callback = G.FUNCS.twbl_settings_toggle_discovery_bypass,
										label_scale = 0.35,
										label = localize("twbl_settings_discovery_bypass"),
										ref_table = TW_BL.SETTINGS.current,
										ref_value = "discovery_bypass",
									}),
									TW_BL.UI.PARTS.create_description_text(
										localize("twbl_settings_discovery_bypass_desc"),
										true
									),
								},
							},
						},
					},
				},
			},
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
					current_option = (TW_BL.SETTINGS.current.forced_blind or 0) + 1,
				}),
			},
		})
	end

	return result
end

function TW_BL.UI.settings.get_appearance_tab()
	local result = {
		n = G.UIT.ROOT,
		config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, minh = 5, minw = 5 },
		nodes = {},
	}
	result.nodes = {
		TW_BL.UI.PARTS.create_settings_section("Blinds", {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					padding = 0.05,
				},
				nodes = {
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									padding = 0.05,
								},
								nodes = {
									create_option_cycle({
										w = 5,
										label = localize("twbl_settings_blind_pool"),
										scale = 0.8,
										options = {
											localize("twbl_settings_blind_pool_1"),
											localize("twbl_settings_blind_pool_2"),
											localize("twbl_settings_blind_pool_3"),
										},
										opt_callback = "twbl_settings_change_pool_type",
										current_option = TW_BL.SETTINGS.current.pool_type,
									}),
									TW_BL.UI.PARTS.create_description_text(localize("twbl_settings_blind_pool_desc")),
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { padding = 0.1 },
					},
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									padding = 0.05,
								},
								nodes = {
									create_option_cycle({
										w = 5,
										label = localize("twbl_settings_blind_pool_type"),
										scale = 0.8,
										options = {
											localize("twbl_settings_blind_pool_type_1"),
											localize("twbl_settings_blind_pool_type_2"),
											localize("twbl_settings_blind_pool_type_3"),
										},
										opt_callback = "twbl_settings_change_blind_pool_type",
										current_option = TW_BL.SETTINGS.current.blind_pool_type,
									}),
									TW_BL.UI.PARTS.create_description_text(
										localize("twbl_settings_blind_pool_type_desc")
									),
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
				},
				nodes = {
					create_toggle({
						callback = G.FUNCS.twbl_settings_toggle_natural_blinds,
						label_scale = 0.35,
						label = localize("twbl_settings_natural_blinds"),
						ref_table = TW_BL.SETTINGS.current,
						ref_value = "natural_blinds",
					}),
					TW_BL.UI.PARTS.create_description_text(localize("twbl_settings_natural_blinds_desc"), true),
				},
			},
		}),
		{
			n = G.UIT.R,
			config = {
				align = "cm",
				padding = 0.05,
			},
		},
		TW_BL.UI.PARTS.create_settings_section("Stickers", {
			create_option_cycle({
				w = 4,
				label = localize("twbl_settings_chat_booster_sticker_appearance"),
				scale = 0.8,
				options = {
					localize("twbl_settings_chat_booster_sticker_appearance_1"),
					localize("twbl_settings_chat_booster_sticker_appearance_2"),
					localize("twbl_settings_chat_booster_sticker_appearance_3"),
				},
				opt_callback = "twbl_settings_change_chat_booster_sticker_appearance",
				current_option = TW_BL.SETTINGS.current.chat_booster_sticker_appearance,
			}),
			TW_BL.UI.PARTS.create_description_text(
				localize("twbl_settings_chat_booster_sticker_appearance_desc"),
				true
			),
		}),
	}

	return result
end

function TW_BL.UI.settings.get_status_text()
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

function TW_BL.UI.settings.update_status(status)
	if G.OVERLAY_MENU then
		local text = TW_BL.UI.settings.get_status_text()
		local status_element = G.OVERLAY_MENU:get_UIE_by_ID("twbl_settings_status")
		if status_element then
			status_element.config.object.config.string = { text }
			status_element.config.object:update_text(true)
		end
	end
end

TW_BL.current_mod.config_tab = true
TW_BL.current_mod.extra_tabs = function()
	return {
		{
			label = "General",
			tab_definition_function = function()
				return TW_BL.UI.settings.get_general_tab()
			end,
		},
		{
			label = "Appearance",
			tab_definition_function = function()
				return TW_BL.UI.settings.get_appearance_tab()
			end,
		},
	}
end
