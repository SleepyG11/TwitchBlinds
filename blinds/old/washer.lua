local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("washer"),
	dollars = 8,
	mult = 2,
	boss = { min = 1, max = 10 },
	pos = { x = 0, y = 21 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("bcbcbc"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

function twbl_washer_wash_cards()
	local previous_limit = G.play.config.card_limit
	G.play.config.card_limit = #G.deck.cards
	G.E_MANAGER:add_event(Event({
		func = function()
			G.play.config.card_limit = #G.deck.cards
			local hand_count = #G.deck.cards
			print(hand_count)
			for i = 1, hand_count do
				draw_card(G.deck, G.play, i * 100 / hand_count, "up", nil, nil, 0.07)
			end
			return true
		end,
	}))
	-- G.E_MANAGER:add_event(Event({
	-- 	func = function()
	-- 		local discard_count = #G.play.cards
	-- 		for i = 1, discard_count do --draw cards from deck
	-- 			draw_card(
	-- 				G.play,
	-- 				G.deck,
	-- 				i * 100 / discard_count,
	-- 				"up",
	-- 				nil,
	-- 				nil,
	-- 				0.005,
	-- 				i % 2 == 0,
	-- 				nil,
	-- 				math.max((21 - i) / 20, 0.7)
	-- 			)
	-- 		end
	-- 		return true
	-- 	end,
	-- }))

	G.E_MANAGER:add_event(Event({
		func = function()
			G.play.config.card_limit = previous_limit
			return true
		end,
	}))
end

-- Implementation in lovely/blinds_washer.toml
