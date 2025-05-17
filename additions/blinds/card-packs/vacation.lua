local variants = {
	touch_grass = {
		jokers = {
			"j_green_joker",
			"j_gluttenous_joker",
			"j_zany",
			"j_wily",
			"j_turtle_bean",
		},
		limit = 2,
		descriptions = 1,
	},
	buy_flowers = {
		jokers = {
			"j_flower_pot",
		},
		consumeables = {
			"c_lovers",
			"c_lovers",
			"c_lovers",
		},
		limit = 4,
		descriptions = 1,
	},
	visit_circus = {
		jokers = {
			"j_ring_master",
			"j_mime",
			"j_acrobat",
			"j_merry_andy",
			"j_chaos",
			"j_juggler",
		},
		consumeables = {
			"c_wheel_of_fortune",
			"c_wheel_of_fortune",
		},
		limit = 2,
		descriptions = 1,
	},
	go_camping = {
		jokers = {
			"j_hiker",
			"j_dusk",
			"j_campfire",
			"j_hit_the_road",
			"j_ride_the_bus",
		},
		limit = 2,
		descriptions = 1,
	},
	go_mining = {
		jokers = {
			"j_rough_gem",
			"j_bloodstone",
			"j_arrowhead",
			"j_onyx_agate",
			"j_ancient",
			"j_erosion",
			"j_stone",
			"j_golden",
			"j_marble",
			"j_glass",
		},
		consumeables = {
			"c_chariot",
			"c_devil",
			"c_tower",
		},
		limit = 2,
		descriptions = 1,
	},
	worldwide_trip = {
		jokers = {
			"j_hit_the_road",
			"j_shortcut",
			"J_obelisk",
			"j_castle",
			"j_idol",
			"j_ride_the_bus",
			"j_ancient",
		},
		consumeables = {
			"c_tower",
		},
		limit = 2,
		descriptions = 1,
	},
	be_creative = {
		jokers = {
			"j_abstract",
			"j_fibonacci",
			"j_delayed_grat",
			"j_stencil",
			"j_square",
			"j_madness",
			"j_hallucination",
			"j_brainstorm",
			"j_misprint",
		},
		consumeables = {
			"c_trance",
		},
		limit = 2,
		descriptions = 1,
	},
	explore_space = {
		jokers = {
			"j_rocket",
			"j_space",
			"j_satellite",
			"j_supernova",
			"j_constellation",
			"j_astronomer",
		},
		consumeables = {
			"c_black_hole",
			"c_moon",
			"c_star",
		},
		limit = 2,
		descriptions = 1,
	},
	predict_future = {
		jokers = {
			"j_seance",
			"j_8_ball",
			"j_fortune_teller",
			"j_sixth_sense",
		},
		limit = 1,
		descriptions = 1,
	},
	be_successful = {
		jokers = {
			"j_card_sharp",
			"j_to_the_moon",
			"j_credit_card",
			"j_business",
			"j_ticket",
			"j_baron",
			"j_luchador",
			"j_shoot_the_moon",
			"j_baseball",
			"j_throwback",
			"j_stuntman",
		},
		limit = 2,
		descriptions = 1,
	},
	play_balatro = {
		jokers = {
			"j_joker",
		},
		consumeables = {
			"c_wheel_of_fortune",
			"c_wheel_of_fortune",
			"c_wheel_of_fortune",
			"c_wheel_of_fortune",
		},
		limit = 5,
		descriptions = 1,
	},
}

local function get_variants_for_voting()
	local temp_table = {}
	for key, variant in pairs(variants) do
		temp_table[key] = true
	end

	local result = {}
	for i = 1, 3 do
		local _, key = pseudorandom_element(temp_table, pseudoseed("twbl_vacation_variants"))
		table.insert(result, key)
		temp_table[key] = nil
	end

	return result
end

local tw_blind = TW_BL.BLINDS.create({
	key = "vacation",
	dollars = 1,
	mult = 2,
	boss = {
		min = -1,
		max = -1,
	},
	config = {
		tw_bl = {
			twitch_blind = true,
			min = 4,
			max = 6,
			one_time = true,
		},
	},
	boss_colour = HEX("ff7f50"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	TW_BL.CHAT_COMMANDS.set_vote_variants("blind_vacation_variant", { "1", "2", "3" }, true)
	TW_BL.CHAT_COMMANDS.reset("blind_vacation_variant", "vote")
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("vote", 1, true)

	local variants_to_pick = get_variants_for_voting()
	TW_BL.G.blind_vacation_variants = variants_to_pick

	local result_variants = {}
	for _, variant in ipairs(variants_to_pick) do
		table.insert(result_variants, "k_twbl_vacation_" .. variant)
	end

	TW_BL.UI.set_panel("game_top", "voting_process_3", true, true, {
		command = "vote",
		status = "k_twbl_vote_ex",
		id = "blind_vacation_variant",
		variants = result_variants,
		mystic_variants = { [3] = true },
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("vote", nil, true)
	TW_BL.UI.remove_panel("game_top", "voting_process_3", true)

	local win_index = TW_BL.CHAT_COMMANDS.get_vote_winner("blind_vacation_variant")
	local win_variant = TW_BL.G.blind_vacation_variants[tonumber(win_index or "1")]

	local variant_config = variants[win_variant]
	local callbacks = {}

	for _, joker in ipairs(variant_config.jokers or {}) do
		local center = G.P_CENTERS[joker]
		if center then
			table.insert(callbacks, function(first)
				G.E_MANAGER:add_event(Event({
					func = function()
						local card = SMODS.create_card({
							set = "Joker",
							key = joker,
						})
						if first then
							card:set_eternal(true)
						end
						if 1 / 3 > pseudorandom(pseudoseed("twbl_vacation_apply_rental")) then
							card:set_rental(true)
						end
						if 1 / 3 > pseudorandom(pseudoseed("twbl_vacation_apply_perishable")) then
							card:set_perishable(true)
						end
						G.jokers:emplace(card)
						card:add_to_deck()
						return true
					end,
				}))
				return "joker"
			end)
		end
	end
	for _, consumeable in ipairs(variant_config.consumeables or {}) do
		local center = G.P_CENTERS[consumeable]
		if center then
			table.insert(callbacks, function()
				G.E_MANAGER:add_event(Event({
					func = function()
						local card = SMODS.create_card({
							set = center.set,
							key = consumeable,
						})
						G.consumeables:emplace(card)
						return true
					end,
				}))
				return "consumeable"
			end)
		end
	end

	local result_callbacks = {}
	for i = 1, variant_config.limit or 2 do
		local callback, index = pseudorandom_element(callbacks, pseudoseed("twbl_vacation_callbacks"))
		table.insert(result_callbacks, callback)
		table.remove(callbacks, index)
	end

	if variant_config.descriptions > 0 then
		local text_to_display =
			localize("k_twbl_vacation_" .. win_variant .. "_description_" .. math.random(variant_config.descriptions))
		attention_text({
			text = text_to_display,
			scale = 0.5,
			hold = 6,
			align = "cm",
			offset = { x = 0, y = -3.5 },
			major = G.play,
		})
	end

	local apply_eternal = true
	for index, callback in ipairs(result_callbacks) do
		local returned_type = callback(apply_eternal)
		if returned_type == "joker" then
			apply_eternal = false
		end
	end
	TW_BL.G.blind_vacation_variants = nil

	TW_BL.CHAT_COMMANDS.set_vote_variants("blind_vacation_variant", {}, true)
	TW_BL.CHAT_COMMANDS.reset("blind_vacation_variant", "vote")
end

TW_BL.EVENTS.add_listener("twitch_command", "blind_vacation_variant", function(command, username, variant)
	if command ~= "vote" or not G.GAME.blind or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("vacation") then
		return
	end

	if TW_BL.CHAT_COMMANDS.can_vote_for_variant("blind_vacation_variant", variant) then
		TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
		TW_BL.CHAT_COMMANDS.increment_vote_score("blind_vacation_variant", variant)
		TW_BL.UI.update_panel("game_top", nil, false)
		TW_BL.UI.create_panel_notify("game_top", nil, username)
	end
end)
