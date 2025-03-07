local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("chaos"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 17 },
	config = {
		tw_bl = { twitch_blind = true, min = 2 },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("55314b"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("toggle", nil, true)
	TW_BL.CHAT_COMMANDS.reset(false, "toggle")
	TW_BL.UI.set_panel("game_top", "command_info_1", true, true, {
		command = "toggle",
		status = "k_twbl_interact_ex",
		position = "twbl_position_Card_singular",
		text = "k_twbl_panel_toggle_chaos",
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("toggle", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("toggle", nil, true)
	TW_BL.CHAT_COMMANDS.reset(false, "toggle")
	TW_BL.UI.remove_panel("game_top", "command_info_1", true)
end

TW_BL.EVENTS.add_listener("twitch_command", TW_BL.BLINDS.get_key("chaos"), function(command, username, raw_index)
	if command ~= "toggle" or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("chaos") then
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
		for i = #G.hand.highlighted, 1, -1 do
			if G.hand.highlighted[i] == card then
				table.remove(G.hand.highlighted, i)
				card:highlight(false)
				G.hand:parse_highlighted()
				return
			end
		end
		G.hand.highlighted[#G.hand.highlighted + 1] = card
		card:highlight(true)
		G.hand:parse_highlighted()
	end
end)
