local COUNT_MULTIPLIER = 0.5

local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("incrementor", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 26 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("423541"),
})

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("count", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("count", nil, true)
	TW_BL.CHAT_COMMANDS.reset(false, "count")
	TW_BL.UI.set_panel("game_top", "command_info_1", true, true, {
		command = "count",
		status = "k_twbl_count_ex",
		position = "twbl_argument_type_Number",
		text = "k_twbl_panel_toggle_incrementor",
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("count", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("count", nil, true)
	TW_BL.CHAT_COMMANDS.reset(false, "count")
	TW_BL.UI.remove_panel("game_top", "command_info_1", true)
end

TW_BL.EVENTS.add_listener("twitch_command", TW_BL.BLINDS.get_key("incrementor"), function(command, username, raw_number)
	if command ~= "count" or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("incrementor") then
		return
	end
	local number = tonumber(raw_number)
	if number and number >= 0 then
		number = math.floor(number)

		G.GAME.blind:wiggle()

		local current_number = G.GAME.blind.twbl_blind_incrementor_count or 0
		if number == current_number + 1 then
			G.GAME.blind.twbl_blind_incrementor_count = number
			G.GAME.blind.mult = G.GAME.blind.config.blind.mult + COUNT_MULTIPLIER * number

			attention_text({
				text = username .. ": " .. tostring(number),
				scale = 0.4,
				hold = 1,
				backdrop_colour = G.C.GOLD,
				align = "cmi",
				major = G.GAME.blind,
				offset = {
					x = 0,
					y = 0,
				},
			})
		else
			G.GAME.blind.twbl_blind_incrementor_count = 0
			G.GAME.blind.mult = G.GAME.blind.config.blind.mult

			attention_text({
				text = username .. ": " .. localize("k_twbl_nope_ex"),
				scale = 0.4,
				hold = 1,
				backdrop_colour = G.C.SECONDARY_SET.Tarot,
				align = "cmi",
				major = G.GAME.blind,
				offset = {
					x = 0,
					y = 0,
				},
			})
		end

		G.GAME.blind.chips = to_big(get_blind_amount(G.GAME.round_resets.ante))
			* to_big(G.GAME.starting_params.ante_scaling)
			* to_big(G.GAME.blind.mult)
		G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
		G.GAME.blind:set_text()
	end
end)
