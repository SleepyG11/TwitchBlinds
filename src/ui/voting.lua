--- @alias TW_BL.voting_variant { item_func?: string, command_func?: string, text_func?: string, percent_func?: string, percent?: string | { ref_table: table, ref_value: string }, text: string, description?: string, command?: string, mystic?: boolean, minw?: number }

--- @param args { status?: boolean, connected_status_text?: string, status_func?: string, items: TW_BL.voting_variant[], w?: number | false }
function TW_BL.UI.voting_UIBox(args)
	args = args or {}
	local total_width = args.w or 14.95
	if args.w == false then
		total_width = nil
	end
	local width = total_width

	local content = {}
	if args.status then
		-- TODO: holy shit, DynaText sucks when we're working with text. Even regular text doesnt help.
		-- Somehow figure this out...
		local text_w = 2.5
		width = width and width - text_w
		local status_string = {
			ref_table = setmetatable({}, {
				__index = function()
					return (TW_BL.providers.connection_status == TW_BL.providers.CONNECTION_STATUS.CONNECTED)
							and args.connected_status_text
						or TW_BL.providers.connection_status_text
				end,
			}),
			ref_value = "vote_text",
		}
		table.insert(content, {
			n = G.UIT.C,
			config = {
				minw = text_w,
				maxw = text_w,
				padding = 0.1,
				func = args.status_func,
				twbl_args = args,
				align = "c",
			},
			nodes = {
				{
					n = G.UIT.O,
					config = {
						object = DynaText({
							string = { status_string },
							colours = { G.C.UI.TEXT_LIGHT },
							shadow = false,
							rotate = false,
							float = true,
							bump = true,
							silent = true,
							scale = 0.35,
							spacing = 1,
							maxw = 2,
						}),
						id = "twbl_status",
					},
				},
			},
		})
	end

	local items = args.items or {}
	local items_count = #items
	for index, item in ipairs(items) do
		local is_mystic = item.mystic and TW_BL.cc.mystic_variants.enabled
		local variant_w = width and width / items_count
		table.insert(content, {
			n = G.UIT.C,
			config = {
				minw = (item.minw and item.minw + 0.2) or variant_w,
				maxw = variant_w,
				align = "cm",
				func = item.item_func,
				twbl_item = item,
				twbl_args = args,
			},
			nodes = {
				{ n = G.UIT.C, config = { minw = 0.05 } },
				item.command and {
					n = G.UIT.C,
					config = {
						padding = 0.08,
						r = 0.3,
						align = "cm",
						colour = G.C.CHIPS,
						func = item.command_func,
						twbl_item = item,
						twbl_args = args,
					},
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = DynaText({
									string = { item.command },
									scale = 0.25,
									colours = { G.C.UI.TEXT_LIGHT },
									shadow = true,
									rotate = false,
									silent = true,
									bump = false,
									spacing = 0,
								}),
								id = "twbl_command_" .. index,
							},
						},
					},
				} or nil,
				item.command and { n = G.UIT.C, config = { minw = 0.1 } } or nil,
				{
					n = G.UIT.C,
					config = { align = "cm", func = item.text_func, twbl_item = item, twbl_args = args },
					nodes = is_mystic and {
						{
							n = G.UIT.R,
							config = {
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.O,
									config = {
										object = DynaText({
											string = { "???" },
											scale = 0.3,
											colours = { G.C.UI.TEXT_LIGHT },
											shadow = true,
											rotate = false,
											silent = true,
											bump = true,
											spacing = 0,
										}),
										id = "twbl_text_" .. index,
									},
								},
							},
						},
					} or {
						{
							n = G.UIT.R,
							config = {
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = item.text,
										scale = 0.3,
										colour = G.C.UI.TEXT_LIGHT,
										id = "twbl_text_" .. index,
									},
								},
							},
						},
						item.description and {
							n = G.UIT.R,
							config = {
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = item.description,
										scale = 0.2,
										colour = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
										id = "twbl_description_" .. index,
									},
								},
							},
						} or nil,
					},
				},
				item.percent and { n = G.UIT.C, config = { minw = 0.15 } } or nil,
				item.percent and {
					n = G.UIT.C,
					config = {
						align = "cm",
						func = item.percent_func,
						twbl_item = item,
						twbl_args = args,
					},
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = DynaText({
									string = { item.percent },
									scale = 0.3,
									colours = { G.C.UI.TEXT_LIGHT },
									shadow = false,
									rotate = false,
									silent = true,
									bump = false,
									spacing = 0,
								}),
								id = "twbl_percent_" .. index,
							},
						},
					},
				} or nil,
				{ n = G.UIT.C, config = { minw = 0.1 } },
			},
		})
	end

	local t = {
		n = G.UIT.ROOT,
		config = {
			colour = { 0, 0, 0, 0.75 },
			minw = total_width,
			maxw = total_width,
			minh = 0.5,
			r = 0.1,
			-- align = "cm",
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "c",
					minh = 0.5,
				},
				nodes = content,
			},
		},
	}

	return t
end

function TW_BL.UI.blind_voting_UIBox()
	local items = {}

	local vote_stats = TW_BL.chat_commands.get_vote_status("blind_voting")
	local blinds_to_vote = TW_BL.G.blind_voting_blinds or {}

	for i = 1, 3 do
		local blind = blinds_to_vote[i]
		local stats = vote_stats[i]

		if stats then
			table.insert(items, {
				command = "vote " .. i,
				text = blind and localize({ type = "name_text", key = blind, set = "Blind" }) or "-",
				mystic = i == 3,

				item_func = "twbl_setup_blind_preview",
				blind = blind,

				percent = {
					ref_table = stats,
					ref_value = "percent",
					suffix = "%",
				},
			})
		end
	end
	return TW_BL.UI.voting_UIBox({
		status = true,
		connected_status_text = "Vote!",
		items = items,
	})
end

G.FUNCS.twbl_setup_blind_preview = function(e)
	local args = e.config.twbl_args
	local item = e.config.twbl_item

	e.config.func = nil

	if not (item.mystic and TW_BL.cc.mystic_variants.enabled) then
		e.float = true
		e.states.hover.can = true
		e.states.collide.can = true
		function e:hover(...)
			self.config.h_popup = create_UIBox_blind_popup(
				G.P_BLINDS[item.blind],
				TW_BL.cc.bypass_discovery_check.enabled or G.P_BLINDS[item.blind].discovered
			)
			self.config.h_popup_config = { align = "mb", offset = { x = 0, y = 0.2 }, parent = e }
			Node.hover(self, ...)
		end
	end
end

G.FUNCS.twbl_setup_center_preview = function(e)
	local args = e.config.twbl_args
	local item = e.config.twbl_item

	e.config.func = nil

	if not (item.mystic and TW_BL.cc.mystic_variants.enabled) then
		e.float = true
		e.states.hover.can = true
		e.states.collide.can = true
		function e:hover(...)
			local center = G.P_CENTERS[item.center]
			if center then
				-- TODO: this thing does not include info_queue, fix this?
				self.config.h_popup = create_UIBox_detailed_tooltip(center)
				self.config.h_popup_config = { align = "mb", offset = { x = 0, y = 0.2 }, parent = e }
			end
			Node.hover(self, ...)
		end
	end
end

--- @param args { status?: boolean, command: string, connected_status_text?: string, status_func?: string, items: TW_BL.voting_variant[] }
function TW_BL.UI.blind_action_voting_UIBox(args)
	args = args or {}
	local items = {}

	local vote_stats = TW_BL.chat_commands.get_vote_status("blind_action")
	local items_to_vote = args.items or {}

	for i = 1, math.max(#vote_stats, #items_to_vote) do
		local item = items_to_vote[i]
		local stats = vote_stats[i]

		if item and stats then
			table.insert(
				items,
				TW_BL.utils.table_shallow_merge({}, item, {
					command = args.command .. " " .. i,
					text = item.text or "-",
					percent = {
						ref_table = stats,
						ref_value = "percent",
						suffix = "%",
					},
				})
			)
		end
	end
	return TW_BL.UI.voting_UIBox({
		status = args.status,
		connected_status_text = args.connected_status_text,
		status_func = args.status_func,
		items = items,
	})
end

--- @param args { status?: boolean, connected_status_text?: string, status_func?: string, items: TW_BL.voting_variant[], w?: number, minw?: number, area?: CardArea, area_position?: "bottom" | "right" }
function TW_BL.UI.voting_with_area_UIBox(args)
	args = args or {}
	local voting_UIBox = TW_BL.UI.voting_UIBox(args)
	if not args.area then
		return voting_UIBox
	end
	if args.area_position == "bottom" then
		voting_UIBox.n = G.UIT.R
		return {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR, align = "cm" },
			nodes = {
				{ n = G.UIT.R, config = { align = "cm" }, nodes = {
					voting_UIBox,
				} },
				{ n = G.UIT.R, config = { minh = 0.1 } },
				{
					n = G.UIT.R,
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = args.area,
							},
						},
					},
				},
			},
		}
	elseif args.area_position == "right" then
		voting_UIBox.n = G.UIT.R
		return {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR, align = "cm" },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						{ n = G.UIT.C, config = { align = "cm" }, nodes = {
							voting_UIBox,
						} },
						{ n = G.UIT.C, config = { minh = 0.1 } },
						{
							n = G.UIT.C,
							nodes = {
								{
									n = G.UIT.O,
									config = {
										object = args.area,
									},
								},
							},
						},
					},
				},
			},
		}
	end
end

--- @alias TW_BL.weight_func fun(left: number, right: number): number

--- @param args { status?: boolean, connected_status_text?: string, status_func?: string, left_item: TW_BL.voting_variant, right_item: TW_BL.voting_variant, w?: number | false, progress_w?: number, progress_items?: table }
function TW_BL.UI.voting_weighted_UIBox(args)
	args = args or {}
	local total_width = args.w or 14.95
	if args.w == false then
		total_width = nil
	end
	local width = total_width

	local content = {}
	if args.status then
		-- TODO: holy shit, DynaText sucks when we're working with text. Even regular text doesnt help.
		-- Somehow figure this out...
		local text_w = 2.5
		width = width and width - text_w
		local status_string = {
			ref_table = setmetatable({}, {
				__index = function()
					return (TW_BL.providers.connection_status == TW_BL.providers.CONNECTION_STATUS.CONNECTED)
							and args.connected_status_text
						or TW_BL.providers.connection_status_text
				end,
			}),
			ref_value = "vote_text",
		}
		table.insert(content, {
			n = G.UIT.C,
			config = {
				minw = text_w,
				maxw = text_w,
				padding = 0.1,
				func = args.status_func,
				twbl_args = args,
				align = "c",
			},
			nodes = {
				{
					n = G.UIT.O,
					config = {
						object = DynaText({
							string = { status_string },
							colours = { G.C.UI.TEXT_LIGHT },
							shadow = false,
							rotate = false,
							float = true,
							bump = true,
							silent = true,
							scale = 0.35,
							spacing = 1,
							maxw = 2,
						}),
						id = "twbl_status",
					},
				},
			},
		})
	end

	local items_content = {}

	local items_count = 0
	if args.left_item then
		items_count = items_count + 1
	end
	if args.right_item then
		items_count = items_count + 1
	end

	local add_item = function(index, item, colour)
		local variant_w = width and width / 3
		table.insert(items_content, {
			n = G.UIT.C,
			config = {
				minw = (item.minw and item.minw + 0.2) or nil,
				maxw = variant_w,
				align = "cm",
				func = item.item_func,
				twbl_item = item,
				twbl_args = args,
			},
			nodes = {
				{ n = G.UIT.C, config = { minw = 0.05 } },
				item.command and {
					n = G.UIT.C,
					config = {
						padding = 0.08,
						r = 0.3,
						align = "cm",
						colour = colour or G.C.CHIPS,
						func = item.command_func,
						twbl_item = item,
						twbl_args = args,
					},
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = DynaText({
									string = { item.command },
									scale = 0.25,
									colours = { G.C.UI.TEXT_LIGHT },
									shadow = true,
									rotate = false,
									silent = true,
									bump = false,
									spacing = 0,
								}),
								id = "twbl_command_" .. index,
							},
						},
					},
				} or nil,
				item.command and { n = G.UIT.C, config = { minw = 0.1 } } or nil,
				item.text and {
					n = G.UIT.C,
					config = { align = "cm", func = item.text_func, twbl_item = item, twbl_args = args },
					nodes = is_mystic and {
						{
							n = G.UIT.R,
							config = {
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.O,
									config = {
										object = DynaText({
											string = { "???" },
											scale = 0.3,
											colours = { G.C.UI.TEXT_LIGHT },
											shadow = true,
											rotate = false,
											silent = true,
											bump = true,
											spacing = 0,
										}),
										id = "twbl_text_" .. index,
									},
								},
							},
						},
					} or {
						{
							n = G.UIT.R,
							config = {
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = item.text,
										scale = 0.3,
										colour = G.C.UI.TEXT_LIGHT,
										id = "twbl_text_" .. index,
									},
								},
							},
						},
						item.description and {
							n = G.UIT.R,
							config = {
								align = "cm",
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = item.description,
										scale = 0.2,
										colour = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
										id = "twbl_description_" .. index,
									},
								},
							},
						} or nil,
					},
				} or nil,
				{ n = G.UIT.C, config = { minw = 0.1 } },
			},
		})
	end

	if args.left_item then
		add_item(1, args.left_item, HEX("f5009b"))
	end

	local progressbar_width = args.progress_w
	if not progressbar_width then
		progressbar_width = width and width / 3 or 3
		if progressbar_width and items_count == 1 then
			progressbar_width = progressbar_width * 2
		end
	end

	table.insert(items_content, {
		n = G.UIT.C,
		config = {
			minw = progressbar_width,
			align = "cm",
		},
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							colour = HEX("387aff"),
							minh = 0.15,
							r = 0.3,
							minw = progressbar_width - 0.4,
							func = "twbl_setup_voting_progress_bar",
							twbl_progress_items = args.progress_items,
						},
						nodes = {
							{
								n = G.UIT.R,
								config = {
									colour = HEX("f5009b"),
									minh = 0.15,
									r = 0.3,
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { minh = 0.225 },
					},
				},
			},
			{ n = G.UIT.C, config = { minw = 0.1 } },
		},
	})

	if args.right_item then
		add_item(2, args.right_item, HEX("387aff"))
	end

	table.insert(content, {
		n = G.UIT.C,
		config = {
			minw = width,
			maxw = width,
			align = "cm",
		},
		nodes = items_content,
	})

	local t = {
		n = G.UIT.ROOT,
		config = {
			colour = { 0, 0, 0, 0.75 },
			minw = total_width,
			maxw = total_width,
			minh = 0.5,
			r = 0.1,
			-- align = "cm",
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "c",
					minh = 0.5,
				},
				nodes = content,
			},
		},
	}

	return t
end

G.FUNCS.twbl_setup_voting_progress_bar = function(e)
	e.config.func = nil
	local set = function(percent)
		local w = e.T.w * percent
		e.children[1].config.minw = w
		e.children[1].T.w = w
	end
	TW_BL.e_mitter.on("new_provider_command", function()
		set(TW_BL.chat_commands.get_weighted_vote_score("blind_action"))
	end, {
		key = "weighted_voting_action",
		tags = {
			in_run = true,
		},
	})
	local old_remove = e.remove
	function e:remove(...)
		old_remove(self, ...)
		TW_BL.e_mitter.off("new_provider_command", "weighted_voting_action")
	end
	set(TW_BL.chat_commands.get_weighted_vote_score("blind_action"))

	for index, item in ipairs(e.config.twbl_progress_items or {}) do
		if item.line then
			local box = UIBox({
				definition = {
					n = G.UIT.ROOT,
					config = {
						colour = G.C.CLEAR,
					},
					nodes = {
						{
							n = G.UIT.C,
							config = {
								colour = item.colour or G.C.UI.TEXT_LIGHT,
								minw = 0.035,
								maxw = 0.035,
								minh = e.T.h,
								maxh = e.T.h,
							},
						},
					},
				},
				config = {
					parent = e,
					offset = {
						x = e.T.w * item.pos,
						y = 0,
					},
					align = "cl",
					major = e,
				},
			})
			e.children["twbl_progress_item_line_" .. index] = box
		end
		if item.text then
			local pos = item.pos
			local align
			if item.center then
				align = "bmi"
				pos = 0.5 - pos
			elseif pos < 0.35 then
				align = "bli"
			elseif pos > 0.65 then
				align = "bri"
				pos = pos - 1
			else
				align = "bmi"
				pos = 0.5 - pos
			end

			local box = UIBox({
				definition = {
					n = G.UIT.ROOT,
					config = {
						colour = G.C.CLEAR,
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = item.text,
								scale = 0.225,
								colour = item.colour or G.C.UI.TEXT_LIGHT,
							},
						},
					},
				},
				config = {
					parent = e,
					offset = {
						y = 0.25,
						x = e.T.w * pos,
					},
					align = align,
					major = e,
				},
			})
			e.children["twbl_progress_item_text_" .. index] = box
		end
	end

	-- TODO: arrow
end
