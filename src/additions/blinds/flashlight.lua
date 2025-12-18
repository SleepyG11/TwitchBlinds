SMODS.Atlas({
	key = "twbl_blind_atlas_flashlight",
	px = 34,
	py = 34,
	path = "blinds/flashlight.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "flashlight",
	dollars = 5,
	mult = 2,
	boss = { min = 1 },
	boss_colour = HEX("e9db00"),

	atlas = "twbl_blind_atlas_flashlight",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,

	stay_flipped = function(self, area, card, from_area)
		-- flip card 3 in 4 chance
		if from_area == G.deck and area == G.hand and pseudorandom("twbl_flashlight_draw") > 0.25 then
			return true
		end
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_interact_ex")
	end,
	command = "toggle",
	command_max_uses = 1,
	command_use_refresh_timeout = 5,
	cards_voting = true,
	get_cardarea = function()
		return G.hand
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
			card:flip()
			G.GAME.blind:wiggle()
			TW_BL.utils.vote_for_card(card, event, card.facing == "front" and G.C.ORANGE or G.C.RED)
			return true
		end
	end,

	get_items = function(_, args)
		return {
			{
				command = TW_BL.L.command_with_arg(args.command, "pos_Card_singular"),
				text = TW_BL.L.blind_interaction_text(blind),
				description = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
			},
		}
	end,
})
