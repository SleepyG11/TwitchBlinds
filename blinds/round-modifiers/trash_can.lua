local tw_blind = TW_BL.BLINDS.create({
	key = "trash_can",
	dollars = 5,
	mult = 2,
	boss = { min = 4, max = 10 },
	config = {
		tw_bl = { twitch_blind = true, min = 3 },
	},
	boss_colour = HEX("dc6a10"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

-- Implementation in lovely/blinds_trash_can.toml

function blind_trash_can_remove_scored_cards(scoring_hand)
	G.GAME.blind:wiggle()
	play_sound("cancel", 0.8, 1.7)
	attention_text({
		scale = 1.4,
		text = localize("k_twbl_trash_ex"),
		hold = 2,
		align = "cm",
		offset = { x = 0, y = -2.7 },
		major = G.play,
	})
	for i = #scoring_hand, 1, -1 do
		local card = scoring_hand[i]
		if card.ability.name == "Glass Card" then
			card:shatter()
		else
			card:start_dissolve(nil, i == #scoring_hand)
		end
	end
	SMODS.calculate_context({ remove_playing_cards = true, removed = scoring_hand })
	delay(1)
end
