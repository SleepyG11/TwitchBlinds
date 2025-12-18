SMODS.Atlas({
	key = "twbl_blind_atlas_plum_hammer",
	px = 34,
	py = 34,
	path = "blinds/plum_hammer.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local debuffed_list = {}

local blind = SMODS.Blind({
	key = "plum_hammer",
	dollars = 8,
	mult = 2,
	boss = { showdown = true, min = 2 },
	config = {
		extra = {
			debuff_limit = 2,
		},
	},

	boss_colour = HEX("DDA0DD"),

	atlas = "twbl_blind_atlas_plum_hammer",

	in_pool = function()
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function()
		return G.jokers and #G.jokers.cards > 4
	end,

	loc_vars = function(self)
		return {
			vars = { self.config.extra.debuff_limit },
		}
	end,
	collection_loc_vars = function(self)
		return {
			vars = { self.config.extra.debuff_limit },
		}
	end,

	twbl_load = function(self)
		debuffed_list = {}
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_showdown_ex")
	end,
	command = "toggle",
	command_max_uses = 1,
	command_use_refresh_timeout = 5,
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
			local initial_value = card.debuff
			card:set_debuff(not initial_value)
			if card.debuff ~= initial_value then
				G.GAME.blind:wiggle()
				TW_BL.chat_commands.increment_command_use(event.command, event.username)
				if card.debuff then
					while blind.config.extra.debuff_limit > 0 and #debuffed_list >= blind.config.extra.debuff_limit do
						local old_card = table.remove(debuffed_list, 1)
						if old_card and not old_card.removed then
							old_card:set_debuff(false)
							card_eval_status_text(
								old_card,
								"extra",
								nil,
								nil,
								nil,
								{ message = localize("k_twbl_unbanned_ex"), instant = true }
							)
						end
					end
					table.insert(debuffed_list, card)
				else
					for i = 1, #debuffed_list do
						if debuffed_list[i] == card then
							table.remove(debuffed_list, i)
							break
						end
					end
				end
				TW_BL.utils.vote_for_card(card, event, card.debuff and G.C.RED or G.C.ORANGE)
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
