function TW_BL.UI.provider_connection_config(provider)
	local config_key = provider.key .. "_channel_name"
	TW_BL.TEMP[config_key] = TW_BL.utils.table_merge({}, TW_BL.cc[config_key])
	return {
		n = G.UIT.R,
		config = { align = "cm", padding = 0.2, r = 0.25, colour = { 0, 0, 0, 0.2 } },
		nodes = {
			{
				n = G.UIT.C,
				config = {
					padding = 0.05,
				},
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
									text = provider.loc_key,
									scale = 0.5,
									colour = G.C.UI.TEXT_LIGHT,
									shadow = true,
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
										ref_table = TW_BL.TEMP[config_key],
										ref_value = "value",
										extended_corpus = true,
										keyboard_offset = 1,
										id = "twbl_set_channel_name_" .. provider.key,
										callback = function() end,
										twbl_keep_real = true,
									}),
									{ n = G.UIT.C, config = { align = "cm", minw = 0.1 }, nodes = {} },
									UIBox_button({
										label = localize("twbl_settings_paste_name_or_url"),
										minw = 2,
										minh = 0.6,
										button = "twbl_settings_paste_channel_name",
										ref_table = {
											twbl_provider = provider,
										},
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
								label = { localize("b_twbl_apply_and_connect") },
								minw = 2.4,
								minh = 0.6,
								button = "twbl_settings_apply_channel_name",
								ref_table = {
									twbl_provider = provider,
								},
								colour = G.C.GREEN,
								scale = 0.3,
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
											id = "twbl_settings_status_" .. provider.key,
											object = DynaText({
												string = {
													{
														ref_table = provider,
														ref_value = "connection_status_text",
													},
												},
												colours = { G.C.WHITE },
												shadow = true,
												silent = true,
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
						config = { minh = 0.1 },
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							{
								n = G.UIT.C,
								nodes = TW_BL.L.parse_lines(
									localize("twbl_settings_channel_name_description_" .. provider.key),
									{
										default_col = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
										align = "c",
									}
								),
							},
						},
					},
				},
			},
		},
	}
end

G.FUNCS.twbl_settings_paste_channel_name = function(e)
	e.config.ref_table.twbl_provider:paste(e)
end
G.FUNCS.twbl_settings_apply_channel_name = function(e)
	local provider = e.config.ref_table.twbl_provider
	local config_key = provider.key .. "_channel_name"
	TW_BL.cc[config_key].value = TW_BL.TEMP[config_key].value
	TW_BL.config.request_save()
	provider:set_channel_name(TW_BL.cc[config_key].value, true)
end

function TW_BL.UI.tab_connections_UIBox()
	return {
		n = G.UIT.ROOT,
		config = { align = "cm", padding = 0.1, colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cm", r = 0.1, padding = 0.1, colour = { 0, 0, 0, 0.2 } },
				nodes = {
					TW_BL.UI.provider_connection_config(TW_BL.Twitch),
					TW_BL.UI.provider_connection_config(TW_BL.Youtube),
				},
			},
		},
	}
end

--

function TW_BL.UI.module_option_cycle(key)
	return {
		n = G.UIT.R,
		config = { padding = 0.15, r = 0.1, colour = { 0, 0, 0, 0.2 } },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					create_option_cycle({
						w = 6,
						scale = 0.8,
						label = localize("twbl_settings_" .. key),
						options = localize("twbl_settings_" .. key .. "_opt"),
						current_option = TW_BL.cc[key].value,
						opt_callback = "twbl_option_cycle",
						twbl_module = TW_BL.cc[key],
					}),
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							{
								n = G.UIT.C,
								nodes = TW_BL.L.parse_lines(localize("twbl_settings_" .. key .. "_desc"), {
									default_col = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
									align = "cm",
								}),
							},
						},
					},
				},
			},
		},
	}
end

function TW_BL.UI.create_toggle(args)
	args = args or {}
	args.active_colour = args.active_colour or G.C.RED
	args.inactive_colour = args.inactive_colour or G.C.BLACK
	args.w = args.w or 3
	args.h = args.h or 0.5
	args.scale = args.scale or 1
	args.label = args.label or "TEST?"
	args.label_scale = args.label_scale or 0.4
	args.ref_table = args.ref_table or {}
	args.ref_value = args.ref_value or "test"

	local check = Sprite(0, 0, 0.5 * args.scale, 0.5 * args.scale, G.ASSET_ATLAS["icons"], { x = 1, y = 0 })
	check.states.drag.can = false
	check.states.visible = false

	local info = nil

	local t = {
		n = args.col and G.UIT.C or G.UIT.R,
		config = {
			align = "cm",
			padding = 0.1,
			r = 0.1,
			colour = G.C.CLEAR,
			focus_args = { funnel_from = true },
			minw = args.minw,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cr", minw = args.w },
				nodes = {
					{
						n = G.UIT.T,
						config = { text = args.label, scale = args.label_scale, colour = G.C.UI.TEXT_LIGHT },
					},
					{ n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
				},
			},
			{
				n = G.UIT.C,
				config = { align = "cl" },
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
	return t
end

function TW_BL.UI.module_toggle(key)
	return {
		n = G.UIT.R,
		config = { padding = 0.15, r = 0.1, colour = { 0, 0, 0, 0.2 } },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							TW_BL.UI.create_toggle({
								minw = 6.3,
								label_scale = 0.4,
								scale = 0.8,
								label = localize("twbl_settings_" .. key),
								ref_table = TW_BL.cc[key],
								ref_value = "enabled",
								callback = function()
									TW_BL.config.request_save()
								end,
								twbl_module = TW_BL.cc[key],
							}),
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							{
								n = G.UIT.C,
								nodes = TW_BL.L.parse_lines(localize("twbl_settings_" .. key .. "_desc"), {
									default_col = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
									align = "cm",
								}),
							},
						},
					},
				},
			},
		},
	}
end
G.FUNCS.twbl_option_cycle = function(arg)
	arg.cycle_config.twbl_module.value = arg.to_key
	TW_BL.config.request_save()
end

function TW_BL.UI.tab_config_UIBox()
	return {
		n = G.UIT.ROOT,
		config = { padding = 0.1, colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.C,
				config = { padding = 0.1, align = "cm", colour = { 0, 0, 0, 0.2 }, r = 0.1 },
				nodes = {
					TW_BL.UI.module_option_cycle("blind_voting_frequency"),
					TW_BL.UI.module_option_cycle("blind_voting_pool_type"),
					TW_BL.UI.module_option_cycle("blind_voting_allow_repeats"),
				},
			},
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						config = { padding = 0.1, align = "cm", colour = { 0, 0, 0, 0.2 }, r = 0.1 },
						nodes = {
							TW_BL.UI.module_toggle("mystic_variants"),
							TW_BL.UI.module_toggle("bypass_discovery_check"),
						},
					},
					{ n = G.UIT.R, config = { minh = 0.1 } },
					{
						n = G.UIT.R,
						config = { padding = 0.1, align = "cm", colour = { 0, 0, 0, 0.2 }, r = 0.1 },
						nodes = {
							TW_BL.UI.module_option_cycle("interactive_sticker"),
						},
					},
				},
			},
		},
	}
end
