SMODS.Atlas({
	key = "twbl_blind_atlas_lock",
	px = 34,
	py = 34,
	path = "blinds/lock.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "lock",
	dollars = 5,
	mult = 2,
	boss = { min = 2 },
	boss_colour = HEX("c0c0c0"),

	atlas = "twbl_blind_atlas_lock",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return G.jokers and #G.jokers.cards > 2 and #G.jokers.cards <= 15 and TW_BL.blinds.is_in_range(self)
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_toggle_ex")
	end,
	command = "toggle",
	command_max_uses = 1,
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
			})
		then
			local initial_value = card.ability.eternal
			card:set_eternal(not initial_value)
			if card.ability.eternal ~= initial_value then
				TW_BL.chat_commands.increment_command_use(event.command, event.username)
				G.GAME.blind:wiggle()
				TW_BL.utils.vote_for_card(card, event, card.ability.eternal and G.C.RED or G.C.ORANGE)
				return true
			end
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
