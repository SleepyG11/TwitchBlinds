local tw_blind = SMODS.Blind({
	key = register_twitch_blind("sketch", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 16 },
	config = {
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				return G.jokers and G.jokers.cards and #G.jokers.cards > 1
			end,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("E2DAD1"),
})

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)
	TW_BL.UI.set_panel("command_info_1", true, true, {
		command = "target",
		status = "k_twbl_vote_ex",
		position = "twbl_position_Joker_singular",
		text = "k_twbl_panel_toggle_sketch",
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("target", false, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)
	TW_BL.UI.remove_panel("command_info_1", true)

	if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
		local max_score = 0
		local result_target = pseudorandom_element(G.jokers.cards, pseudoseed("twbl_sketch"))
		for _, card in ipairs(G.jokers.cards) do
			if card.ability.twitch_target and card.ability.twitch_target > max_score then
				result_target = card
				max_score = card.ability.twitch_target
			end
			card.ability.twitch_target = nil
		end

		local v = result_target

		G.E_MANAGER:add_event(Event({
			func = function()
				card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_twbl_sketch_ex") })
				local card = copy_card(v, nil, nil, nil, v.edition and v.edition.negative)
				card:add_to_deck()
				G.jokers:emplace(card)
				return true
			end,
		}))
	end
end

TW_BL.EVENTS.add_listener("twitch_command", get_twitch_blind_key("sketch"), function(command, username, raw_index)
	if command ~= "target" or G.GAME.blind.name ~= get_twitch_blind_key("sketch") then
		return
	end
	local index = tonumber(raw_index)
	if index and G.jokers and G.jokers.cards and G.jokers.cards[index] then
		G.GAME.blind:wiggle()
		local card = G.jokers.cards[index]
		card.ability.twitch_target = (card.ability.twitch_target or 0) + 1
		card_eval_status_text(card, "extra", nil, nil, nil, { message = username, colour = G.C.CHIPS })
	else
		TW_BL.CHAT_COMMANDS.decrement_command_use("target", username)
	end
end)
