local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("plum_hammer", true),
	dollars = 8,
	mult = 2,
	boss = { min = -1, max = -1, showdown = true },
	pos = { x = 0, y = 0 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_showdown_blind_chips",
	boss_colour = HEX("DDA0DD"),
})

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind(reset, silent)
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("toggle", 1, true)
	TW_BL.CHAT_COMMANDS.reset(false, "toggle")
	TW_BL.UI.set_panel("game_top", "command_info_1", true, true, {
		command = "toggle",
		status = "k_twbl_toggle_ex",
		position = "twbl_position_Joker_singular",
		text = "k_twbl_panel_toggle_plum_hammer",
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("toggle", nil, true)
	TW_BL.CHAT_COMMANDS.reset(false, "toggle")
	TW_BL.UI.remove_panel("game_top", "command_info_1", true)
end

TW_BL.EVENTS.add_listener("twitch_command", TW_BL.BLINDS.get_key("plum_hammer"), function(command, username, raw_index)
	if command ~= "toggle" or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("plum_hammer") then
		return
	end
	if G.STATE ~= G.STATES.SELECTING_HAND then
		TW_BL.CHAT_COMMANDS.decrement_command_use("toggle", username)
		return
	end
	local index = tonumber(raw_index)
	if index and G.jokers and G.jokers.cards and G.jokers.cards[index] then
		local card = G.jokers.cards[index]
		local initial_value = card.debuff
		card:set_debuff(not initial_value)
		if card.debuff ~= initial_value then
			G.GAME.blind:wiggle()
			card_eval_status_text(card, "extra", nil, nil, nil, { message = username })
			card:juice_up()
		else
			TW_BL.CHAT_COMMANDS.decrement_command_use("toggle", username)
		end
	else
		TW_BL.CHAT_COMMANDS.decrement_command_use("toggle", username)
	end
end)
