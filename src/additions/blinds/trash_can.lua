local effect_options = {
	remove_card = {
		action = "remove",
		vars_list = {
			{ filter = "all_discarded" },
			{ filter = "all_played" },
			{ filter = "random", amount = 8 },
		},
	},
	duplicate_card = {
		action = "duplicate",
		vars_list = {
			{ filter = "all_discarded" },
			{ filter = "all_played" },
			{ filter = "random", amount = 8 },
		},
	},

	remove_suit = {
		action = "remove",
		vars_list = {
			{ filter = "most_common_type", type = "suit" },
			{ filter = "least_common_type", type = "suit" },
			{ filter = "random_type", type = "suit" },
		},
	},
	duplicate_suit = {
		action = "duplicate",
		vars_list = {
			{ filter = "most_common_type", type = "suit" },
			{ filter = "least_common_type", type = "suit" },
			{ filter = "random_type", type = "suit" },
		},
	},
	randomize_suit = {
		action = "randomize",
		action_type = "suit",
		vars_list = {
			{ filter = "all" },
		},
	},

	remove_rank = {
		action = "remove",
		vars_list = {
			{ filter = "most_common_type", type = "rank" },
			{ filter = "least_common_type", type = "rank" },
			{ filter = "random_type", type = "rank" },
		},
	},
	duplicate_rank = {
		action = "duplicate",
		vars_list = {
			{ filter = "most_common_type", type = "rank" },
			{ filter = "least_common_type", type = "rank" },
			{ filter = "random_type", type = "rank" },
		},
	},
	randomize_rank = {
		action = "randomize",
		action_type = "rank",
		vars_list = {
			{ filter = "all" },
		},
	},

	remove_seal = {
		action = "remove_field",
		action_type = "seal",
		vars_list = {
			{ filter = "all" },
		},
	},
	randomize_seal = {
		action = "randomize",
		action_type = "seal",
		vars_list = {
			{ filter = "all" },
		},
	},

	remove_edition = {
		action = "remove_field",
		action_type = "edition",
		vars_list = {
			{ filter = "all" },
		},
	},
	randomize_edition = {
		action = "randomize",
		action_type = "edition",
		vars_list = {
			{ filter = "all" },
		},
	},

	make_a_stone = {
		action = "make_a_stone",
		vars_list = {
			{ filter = "least_common_type", type = "suit" },
			{ filter = "least_common_type", type = "rank" },
			{ filter = "most_common_type", type = "suit" },
			{ filter = "most_common_type", type = "rank" },
			{ filter = "random", amount = 8 },
		},
	},
}

local function get_cards_to_affect(vars)
	local result = {}
	if vars.filter == "all" or vars.filter == "random" then
		result = TW_BL.utils.table_shallow_copy(G.playing_cards)
	elseif vars.filter == "all_discarded" then
		result = TW_BL.utils.table_filter(G.playing_cards, function(card)
			return card.ability.twbl_discarded
		end)
	elseif vars.filter == "all_played" then
		result = TW_BL.utils.table_filter(G.playing_cards, function(card)
			return card.ability.twbl_played
		end)
	else
		local field = vars.type
		if field == "rank" then
			field = "value"
		end
		local stats = {
			value = {},
			suit = {},
		}
		for _, card in ipairs(G.playing_cards) do
			if card.base then
				if card.base.value then
					stats.value[card.base.value] = (stats.value[card.base.value] or 0) + 1
				end
				if card.base.suit then
					stats.suit[card.base.suit] = (stats.suit[card.base.suit] or 0) + 1
				end
			end
		end

		local result_field
		if vars.filter == "most_common_type" or vars.filter == "least_common_type" then
			local least_count, least_field = math.huge, nil
			local most_count, most_field = 0, nil
			for key, count in pairs(stats[field]) do
				if not most_field then
					most_field = key
				end
				if not least_field then
					least_field = key
				end
				if count > most_count then
					most_field = key
					most_count = count
				end
				if count < least_count then
					least_field = key
					least_count = count
				end
			end
			result_field = vars.filter == "most_common_type" and most_field or least_field
		elseif vars.filter == "random_type" then
			local _, _result_field =
				pseudorandom_element(stats[field], "twbl_trash_can_random_type" .. G.GAME.round_resets.ante)
			result_field = _result_field
		end
		result = TW_BL.utils.table_filter(G.playing_cards, function(card)
			return card.base and card.base[field] == result_field
		end)
	end

	if not vars.amount then
		return result
	end
	local amount_result = {}
	for i = 1, math.min(#result, vars.amount) do
		local card, index = pseudorandom_element(result, "twbl_trash_can_amount_filter" .. G.GAME.round_resets.ante)
		if not card then
			break
		end
		table.remove(result, index)
		table.insert(amount_result, card)
	end
	return amount_result
end
local function get_effect_function(effect)
	local effect_func = function(card) end
	local new_cards, cards_to_destroy = {}, {}
	if effect.action == "remove" then
		effect_func = function(card)
			table.insert(cards_to_destroy, card)
		end
	elseif effect.action == "duplicate" then
		effect_func = function(card)
			G.playing_card = (G.playing_card and G.playing_card + 1) or 1
			local _card = copy_card(card, nil, nil, G.playing_card)
			_card:add_to_deck()
			G.deck.config.card_limit = G.deck.config.card_limit + 1
			table.insert(G.playing_cards, _card)
			G.deck:emplace(_card)
			new_cards[#new_cards + 1] = _card
		end
	elseif effect.action == "make_a_stone" then
		effect_func = function(card)
			card:set_ability("m_stone")
		end
	elseif effect.action == "remove_field" then
		if effect.action_type == "edition" then
			effect_func = function(card)
				card:set_edition(nil, true, true)
			end
		elseif effect.action_type == "seal" then
			effect_func = function(card)
				card:set_seal(nil, true, true)
			end
		end
	elseif effect.action == "randomize" then
		if effect.action_type == "suit" then
			effect_func = function(card)
				local _suit = pseudorandom_element(SMODS.Suits, "twbl_trash_can_suit")
				assert(SMODS.change_base(card, _suit.key))
			end
		elseif effect.action_type == "rank" then
			effect_func = function(card)
				local _rank = pseudorandom_element(SMODS.Ranks, "twbl_trash_can_rank")
				assert(SMODS.change_base(card, nil, _rank.key))
			end
		elseif effect.action_type == "edition" then
			effect_func = function(card)
				local _edition = SMODS.poll_edition({
					key = "twbl_trash_can_edition",
					mod = 6,
					no_negative = true,
				})
				card:set_edition(_edition, true, true)
			end
		elseif effect.action_type == "seal" then
			effect_func = function(card)
				local seal = SMODS.poll_seal({
					key = "twbl_trash_can_seal",
					mod = 6,
				})
				card:set_seal(seal, true, true)
			end
		end
	end
	return effect_func, new_cards, cards_to_destroy
end
local function apply_effect(effect, vars)
	local cards = get_cards_to_affect(vars)
	local effect_func, new_cards, cards_to_destroy = get_effect_function(effect)
	for _, card in ipairs(cards) do
		effect_func(card)
	end
	if #cards_to_destroy > 0 then
		TW_BL.FLAGS.silent_card_dissolve = true
		SMODS.destroy_cards(cards_to_destroy, false, true)
		TW_BL.FLAGS.silent_card_dissolve = nil
	end
	if #new_cards > 0 then
		SMODS.calculate_context({ playing_card_added = true, cards = new_cards })
	end
end

SMODS.Atlas({
	key = "twbl_blind_atlas_trash_can",
	px = 34,
	py = 34,
	path = "blinds/trash_can.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "trash_can",
	dollars = 5,
	mult = 2,
	boss = { min = 3 },
	boss_colour = HEX("dc6a10"),

	atlas = "twbl_blind_atlas_trash_can",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,

	calculate = function(self, blind, context)
		if context.discard then
			context.other_card.ability.twbl_discarded = true
		elseif context.after then
			for _, card in ipairs(context.full_hand) do
				card.ability.twbl_played = true
			end
		end
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_choose_ex")
	end,
	command = "vote",
	command_max_uses = 1,
	voting = true,
	set_vote_variants = function()
		return { "1", "2", "3" }
	end,

	get_items = function(effects)
		local items = {}
		for index, effect in ipairs(effects) do
			local effect_def = effect_options[effect.key]

			table.insert(items, {
				text = localize({
					type = "variable",
					key = "twbl_trash_can_effect_" .. effect_def.action,
					vars = { effect_def.action_type and localize("twbl_arg_type_" .. effect_def.action_type) },
				}),
				description = localize({
					type = "variable",
					key = "twbl_trash_can_filter_" .. effect.vars.filter,
					vars = { effect.vars.type and localize("k_" .. effect.vars.type) or "", effect.vars.amount },
				}),
				mystic = index == 3,
			})
		end
		return items
	end,

	set_effects = function()
		return TW_BL.utils.poll_blind_effects(effect_options, 3, "twbl_trash_can")
	end,
	apply_effect = function(effect)
		apply_effect(effect_options[effect.key], effect.vars)

		for _, card in ipairs(G.playing_cards) do
			card.ability.twbl_played = nil
			card.ability.twbl_discarded = nil
		end
	end,
})
