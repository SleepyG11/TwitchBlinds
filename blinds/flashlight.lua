local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("flashlight", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 3 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("e9db00"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("toggle", 2, true)
	TW_BL.CHAT_COMMANDS.reset(false, "toggle")
	TW_BL.UI.set_panel("game_top", "command_info_1", true, true, {
		command = "toggle",
		status = "k_twbl_flip_ex",
		position = "twbl_position_Card_singular",
		text = "k_twbl_panel_toggle_flashlight",
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("toggle", nil, true)
	TW_BL.CHAT_COMMANDS.reset(false, "toggle")
	TW_BL.UI.remove_panel("game_top", "command_info_1", true)
end

TW_BL.EVENTS.add_listener("twitch_command", TW_BL.BLINDS.get_key("flashlight"), function(command, username, raw_index)
	if command ~= "toggle" or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("flashlight") then
		return
	end
	if G.STATE ~= G.STATES.SELECTING_HAND then
		return
	end
	local index = tonumber(raw_index)
	if index and G.hand and G.hand.cards and G.hand.cards[index] then
		TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
		G.GAME.blind:wiggle()
		local card = G.hand.cards[index]
		card_eval_status_text(card, "extra", nil, nil, nil, { message = username, instant = true })
		card:flip()
	end
end)

function tw_blind:stay_flipped()
	return true
end
