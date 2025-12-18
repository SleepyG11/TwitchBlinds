SMODS.Atlas({
	key = "twbl_blind_atlas_stock_market",
	px = 34,
	py = 34,
	path = "blinds/stock_market.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "stock_market",
	dollars = 5,
	mult = 2,
	boss = { min = 1 },
	boss_colour = HEX("3a5055"),

	in_pool = function(self)
		return false
	end,

	atlas = "twbl_blind_atlas_stock_market",

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return G.jokers and #G.jokers.cards > 1 and TW_BL.blinds.is_in_range(self)
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_invest_ex")
	end,
	command = "target",
	command_max_uses = 1,
	cards_voting = true,
	get_cardarea = function()
		return G.jokers
	end,
	on_new_provider_command = function(event, args, card)
		if
			card
			and card.set_cost
			and G.GAME.dollars > (G.GAME.bankrupt_at - 20)
			and TW_BL.chat_commands.default_command_check(event, {
				command = args.command,
				can_use_command = true,
				increment_command_use = true,
			})
		then
			ease_dollars(-1, true)
			card.ability.extra_value = (card.ability.extra_value or 0) + 1
			card:set_cost()
			TW_BL.utils.vote_for_card(card, event, G.C.MONEY)
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
