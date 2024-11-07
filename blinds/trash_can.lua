local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("trash_can"),
	dollars = 5,
	mult = 2,
	boss = { min = 4, max = 10 },
	pos = { x = 0, y = 2 },
	config = {
		tw_bl = { twitch_blind = true, min = 3 },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("dc6a10"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

-- Implementation in lovely/blinds_trash_can.toml

function blind_trash_can_remove_scored_cards(scoring_hand)
	G.GAME.blind:wiggle()
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.2,
		func = function()
			play_sound("tarot1")
			for i = #scoring_hand, 1, -1 do
				local card = scoring_hand[i]
				if card.ability.name == "Glass Card" then
					card:shatter()
				else
					card:start_dissolve(nil, i == #scoring_hand)
				end
			end
			for i = 1, #G.jokers.cards do
				G.jokers.cards[i]:calculate_joker({ remove_playing_cards = true, removed = scoring_hand })
			end
			return true
		end,
	}))
end
