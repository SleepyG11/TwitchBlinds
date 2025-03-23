local TIME_DELAY = 1
local CHAT_MULT = 1

local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("clock"),
	dollars = 5,
	mult = 1,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 13 },
	config = {
		tw_bl = { twitch_blind = true, min = 2 },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("896665"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

local timeout = TIME_DELAY

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

TW_BL.EVENTS.add_listener("game_update", TW_BL.BLINDS.get_key("clock"), function(dt)
	if not G.GAME or G.SETTINGS.paused or TW_BL.G.clock_block then
		return
	end
	timeout = timeout - dt
	if timeout <= 0 then
		timeout = timeout + TIME_DELAY
		if
			G.GAME
			and G.GAME.blind
			and G.GAME.blind.name == TW_BL.BLINDS.get_key("clock")
			and G.GAME.round_resets.blind_states.Boss == "Current"
		then
			G.GAME.blind:wiggle()
			-- TODO: need to fix a problem with no chips saving
			G.GAME.blind.chips = increment_clock_chips(
				to_big(G.GAME.blind.chips),
				to_big(get_blind_amount(G.GAME.round_resets.ante)) * to_big(G.GAME.starting_params.ante_scaling),
				1
			)
			G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
			G.GAME.blind:set_text()
		end
	end
end)

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	TW_BL.G.clock_block = nil
	timeout = TIME_DELAY * 2 -- reset + preparation time + animations time

	TW_BL.CHAT_COMMANDS.toggle_can_collect("count", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("count", 1, true)
	TW_BL.CHAT_COMMANDS.reset(false, "count")
	TW_BL.UI.set_panel("game_top", "command_info_2", true, true, {
		command = "count",
		status = "k_twbl_interact_ex",
		id = "blind_clock_time",
		variants = { "up", "down" },
		localize_variants = { false, false },
		texts = { "k_twbl_clock_count_up", "k_twbl_clock_count_down" },
	})
	TW_BL.CHAT_COMMANDS.reset("blind_clock_time", "count")
end

function tw_blind:defeat()
	TW_BL.G.clock_block = nil

	TW_BL.CHAT_COMMANDS.toggle_can_collect("count", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("count", nil, true)

	TW_BL.UI.remove_panel("game_top", "command_info_2", true)

	TW_BL.CHAT_COMMANDS.reset("blind_clock_time", "count")
end

TW_BL.EVENTS.add_listener("twitch_command", "blind_clock", function(command, username, variant)
	if command ~= "count" or not G.GAME.blind or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("clock") then
		return
	end

	if G.SETTINGS.paused or TW_BL.G.clock_block then
		return
	end

	if variant == "up" or variant == "down" then
		TW_BL.CHAT_COMMANDS.increment_command_use(command, username)

		local command_mult = variant == "up" and 0.5 or -1

		G.GAME.blind:wiggle()
		G.GAME.blind.chips = increment_clock_chips(
			to_big(G.GAME.blind.chips),
			to_big(get_blind_amount(G.GAME.round_resets.ante)) * to_big(G.GAME.starting_params.ante_scaling),
			CHAT_MULT * command_mult
		)
		G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
		G.GAME.blind:set_text()

		attention_text({
			text = username .. ": " .. tostring(CHAT_MULT * command_mult),
			scale = 0.3,
			hold = 1,
			backdrop_colour = command_mult > 0 and G.C.MULT or G.C.CHIPS,
			align = "cmi",
			major = G.GAME.blind,
			offset = {
				x = 0,
				y = 0,
			},
		})
	end
end)
