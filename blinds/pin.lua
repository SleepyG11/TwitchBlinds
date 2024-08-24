local tw_blind = SMODS.Blind({
	key = register_twitch_blind("pin", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 19 },
	config = {
		tw_bl = { twitch_blind = true, min = 2 },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("af365a"),
})

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind(reset, silent)
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", true, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("toggle", true, true)
	TW_BL.UI.set_panel("blind_action_toggle", true, true, {
		"dictionary",
		"k_twbl_pin_ex",
		"twbl_position_singular",
		"Joker",
		"dictionary",
		"k_twbl_panel_toggle_pin",
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", false, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("toggle", false, true)
	TW_BL.UI.remove_panel("blind_action_toggle", true)
end

TW_BL.EVENTS.add_listener("twitch_command", get_twitch_blind_key("pin"), function(command, username, index)
	if command ~= "toggle" then
		return
	end
	if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= get_twitch_blind_key("pin") then
		return
	end
	if G.jokers and G.jokers.cards and G.jokers.cards[index] then
		G.GAME.blind:wiggle()
		local card = G.jokers.cards[index]
		card_eval_status_text(card, "extra", nil, nil, nil, { message = username })
		card.pinned = not card.pinned
		card:juice_up()
	else
		TW_BL.CHAT_COMMANDS.decrement_command_use("toggle", username)
	end
end)
