local TIME_DELAY = 1

local function increment_clock_chips(current_chips, base_chips, increment_mult)
	local mult = to_big(current_chips) / to_big(base_chips)

	local increment = to_big(0.2) * to_big(increment_mult or 1)
	if mult >= to_big(2) then
		increment = increment / 2
	end
	if mult >= to_big(3) then
		increment = increment / 2
	end
	if mult >= to_big(4) then
		increment = increment / 2
	end
	if mult >= to_big(6) then
		increment = increment / 2
	end
	if mult >= to_big(8) then
		increment = increment / 2
	end

	return to_big(base_chips) * to_big(mult + increment)
end

SMODS.Atlas({
	key = "twbl_blind_atlas_hourglass",
	px = 34,
	py = 34,
	path = "blinds/hourglass.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "hourglass",
	dollars = 5,
	mult = 2,
	boss = { min = 2 },
	boss_colour = HEX("896665"),

	atlas = "twbl_blind_atlas_hourglass",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,

	twbl_load = function()
		TW_BL.e_mitter.on("game_update", function(dt)
			if not G.GAME.blind.twbl_clock_time then
				G.GAME.blind.twbl_clock_time = G.TIMERS.REAL
			end
			if G.SETTINGS.paused or not (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED) then
				G.GAME.blind.twbl_clock_time = G.GAME.blind.twbl_clock_time + dt
			end
			if G.TIMERS.REAL - G.GAME.blind.twbl_clock_time > TIME_DELAY then
				G.GAME.blind.twbl_clock_time = G.TIMERS.REAL
				-- TODO: need to fix a problem with no chips saving
				G.GAME.blind.chips = increment_clock_chips(
					to_big(G.GAME.blind.chips),
					to_big(get_blind_amount(G.GAME.round_resets.ante)) * to_big(G.GAME.starting_params.ante_scaling),
					1
				)
				G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
				G.GAME.blind:set_text()
			end
		end, {
			key = "boss_hourglass_update",
			tags = {
				in_run = true,
			},
		})
	end,
	defeat = function()
		TW_BL.e_mitter.off("game_update", "boss_hourglass_update")
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_time_is_ticking_ex")
	end,
	command = "clock",
	command_max_uses = 1,
	command_use_refresh_timeout = 5,
	get_items = function(_, args)
		return {
			{
				command = args.command .. " down",
				text = localize({
					type = "variable",
					key = "twbl_seconds_diff_singular",
					vars = { "-1" },
				}),
				description = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
			},
			{
				command = args.command .. " up",
				text = localize({
					type = "variable",
					key = "twbl_seconds_diff_singular",
					vars = { "+1" },
				}),
				description = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
			},
		}
	end,

	on_new_provider_command = function(event, args)
		if
			not G.SETTINGS.paused
			and (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED)
			and TW_BL.chat_commands.default_command_check(event, {
				command = args.command,
				can_use_command = true,
			})
		then
			local arg = event.words[1]
			local mult = 0
			if arg == "down" then
				mult = -1
			elseif arg == "up" then
				mult = 1
			end
			if mult ~= 0 then
				-- silent buff + prevent from instant double scale
				if not G.GAME.blind.twbl_clock_time then
					G.GAME.blind.twbl_clock_time = G.TIMERS.REAL
				end
				G.GAME.blind.twbl_clock_time = G.GAME.blind.twbl_clock_time + 0.05

				TW_BL.chat_commands.increment_command_use(event.command, event.username)
				G.GAME.blind:wiggle()
				G.GAME.blind.chips = increment_clock_chips(
					to_big(G.GAME.blind.chips),
					to_big(get_blind_amount(G.GAME.round_resets.ante)) * to_big(G.GAME.starting_params.ante_scaling),
					mult
				)
				G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
				G.GAME.blind:set_text()

				-- TODO: custom notify for blind
				attention_text({
					text = event.username .. ": " .. tostring(mult),
					scale = 0.3,
					hold = 1,
					backdrop_colour = mult > 0 and G.C.MULT or G.C.CHIPS,
					align = "cmi",
					major = G.GAME.blind,
					offset = {
						x = 0,
						y = 0,
					},
				})
				return true
			end
		end
	end,
})
