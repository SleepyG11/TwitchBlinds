SMODS.Atlas({
	key = "twbl_blind_atlas_banana",
	px = 34,
	py = 34,
	path = "blinds/banana.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "banana",
	dollars = 5,
	mult = 2,
	boss = { min = 2 },
	boss_colour = HEX("e2ce00"),

	config = {
		extra = { gros_michel_odds = 6, cavendish_odds = 1000 },
	},

	atlas = "twbl_blind_atlas_banana",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return G.jokers and #G.jokers.cards > 2 and TW_BL.blinds.is_in_range(self)
	end,

	set_blind = function(self)
		local jokers_list = {}
		for _, v in ipairs(G.jokers.cards) do
			table.insert(jokers_list, v)
		end
		for index, v in ipairs(jokers_list) do
			if SMODS.pseudorandom_probability(v, "twbl_banana", 1, self.config.extra.gros_michel_odds) then
				card_eval_status_text(
					v,
					"extra",
					nil,
					nil,
					nil,
					{ message = localize("k_twbl_banana_ex"), colour = G.C.RED }
				)
				SMODS.destroy_cards({ v }, true, false, true)
				G.E_MANAGER:add_event(Event({
					func = function()
						SMODS.add_card({ key = "j_gros_michel", area = G.jokers })
						return true
					end,
				}))
			else
				card_eval_status_text(
					v,
					"extra",
					nil,
					nil,
					nil,
					{ message = localize("k_safe_ex"), colour = G.C.ORANGE }
				)
			end
		end
	end,

	loc_vars = function(self)
		return { vars = { SMODS.get_probability_vars(nil, 1, self.config.extra.gros_michel_odds, "twbl_banana") } }
	end,
	collection_loc_vars = function(self)
		return { vars = { SMODS.get_probability_vars(nil, 1, self.config.extra.gros_michel_odds, "twbl_banana", true) } }
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_always_pray_ex")
	end,
	command = "target",
	delay_load = true,
	command_max_uses = 1,
	command_use_refresh_timeout = 1,
	cards_voting = true,
	get_cardarea = function()
		return G.jokers
	end,
	on_new_provider_command = function(event, args, card)
		if
			G.STATE == G.STATES.SELECTING_HAND
			and card
			and TW_BL.chat_commands.default_command_check(event, {
				command = args.command,
				can_use_command = true,
				increment_command_use = true,
			})
		then
			if SMODS.pseudorandom_probability(card, "twbl_banana_extinct", 1, blind.config.extra.cavendish_odds) then
				G.GAME.blind:wiggle()
				TW_BL.UI.notify({
					target = "card",
					card = card,
					message = event.username .. ": " .. localize("k_extinct_ex"),
					colour = G.C.RED,
					hold = 3,
				})
				SMODS.destroy_cards({ card }, true, true, true)
				if card.config.center.key ~= "j_cavendish" then
					SMODS.add_card({ key = "j_cavendish", area = G.jokers })
				end
			else
				TW_BL.utils.vote_for_card(card, event)
			end
			return true
		end
	end,

	get_items = function(_, args)
		return {
			{
				command = TW_BL.L.command_with_arg(args.command, "pos_Joker_singular"),
				text = TW_BL.L.blind_interaction_text(blind),
				description = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
			},
		}
	end,
})
