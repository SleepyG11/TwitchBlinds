SMODS.Atlas({
	key = "twbl_blind_atlas_chaos",
	px = 34,
	py = 34,
	path = "blinds/chaos.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "chaos",
	dollars = 5,
	mult = 2,
	boss = { min = 1 },
	boss_colour = HEX("55314b"),

	atlas = "twbl_blind_atlas_chaos",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_chaos_ex")
	end,
	command = "toggle",
	command_max_uses = 1,
	command_use_refresh_timeout = 1,
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
			G.GAME.blind:wiggle()
			TW_BL.utils.vote_for_card(card, event)

			-- this shit needed to bypass selection limit (which is intented)
			for i = #G.hand.highlighted, 1, -1 do
				if G.hand.highlighted[i] == card then
					table.remove(G.hand.highlighted, i)
					card:highlight(false)
					G.hand:parse_highlighted()
					return true
				end
			end
			G.hand.highlighted[#G.hand.highlighted + 1] = card
			card:highlight(true)
			G.hand:parse_highlighted()
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
