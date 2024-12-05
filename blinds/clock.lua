local TIME_DELAY = 1

local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("clock"),
	dollars = 5,
	mult = 1,
	boss = { min = 2, max = 10 },
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

local function increment_clock_chips(current_chips, base_chips)
	local mult = to_big(current_chips) / to_big(base_chips)

	local increment = to_big(0.2)
	if mult >= to_big(2) then
		increment = increment / 2
	end
	if mult >= to_big(3) then
		increment = increment / 2
	end
	if mult >= to_big(4) then
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
				G.GAME.blind.chips,
				to_big(get_blind_amount(G.GAME.round_resets.ante)) * to_big(G.GAME.starting_params.ante_scaling)
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
end

function tw_blind:defeat()
	TW_BL.G.clock_block = nil
end
