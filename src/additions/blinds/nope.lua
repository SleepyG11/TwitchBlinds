SMODS.Atlas({
	key = "twbl_blind_atlas_nope",
	px = 34,
	py = 34,
	path = "blinds/nope.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "nope",
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	boss_colour = G.C.SECONDARY_SET.Tarot,

	config = {
		extra = { min_mult = 1, max_mult = 4 },
	},

	atlas = "twbl_blind_atlas_nope",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_ignore = true,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_nope_ex")
	end,
	command = "nope",
	command_max_uses = 1,
	command_use_refresh_timeout = 1,
	on_new_provider_command = function(event, args)
		if
			TW_BL.chat_commands.default_command_check(event, {
				command = args.command,
				can_use_command = true,
				increment_command_use = true,
			})
		then
			for i = 1, 3 do
				G.E_MANAGER:add_event(Event({
					blocking = false,
					blockable = false,
					trigger = "after",
					delay = math.random(8, 16) / 10 * i,
					func = function()
						if i == 1 then
							if G.STATE == G.STATES.SELECTING_HAND then
								G.GAME.blind.mult = math.random(
									blind.config.extra.min_mult * 100,
									blind.config.extra.max_mult * 100
								) / 100
								G.GAME.blind.chips = to_big(get_blind_amount(G.GAME.round_resets.ante))
									* to_big(G.GAME.starting_params.ante_scaling)
									* to_big(G.GAME.blind.mult)
								G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
								G.GAME.blind:set_text()
							end
						end
						attention_text({
							text = localize(math.random(1, 100) == 1 and "k_twbl_never_lucky_ex" or "k_twbl_nope_ex"),
							scale = math.random(15, 45) / 10,
							hold = math.random(25, 80) / 10,
							backdrop_colour = G.C.SECONDARY_SET.Tarot,
							align = "cmi",
							major = G.ROOM_ATTACH,
							offset = {
								x = math.random(-80, 80) / 10,
								y = math.random(-50, 50) / 10,
							},
						})
						play_sound("tarot2", 0.9 + math.random() * 0.2, 0.4)
						return true
					end,
				}))
			end
			return true
		end
	end,

	get_items = function(_, args)
		return {
			{
				command = args.command,
				text = TW_BL.L.blind_interaction_text(blind),
				description = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
			},
		}
	end,
})
