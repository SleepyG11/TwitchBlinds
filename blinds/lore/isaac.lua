local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("isaac"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 1 },
	config = {
		tw_bl = {
			twitch_blind = true,
			min = 4,
			max = 6,
			-- tags = { "twbl_cruel_blind" },
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("d82727"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	ease_background_colour_blind()

	local card = create_card("Joker", G.jokers, false, nil, nil, nil, "j_ceremonial", nil)
	card.pinned = true
	card:set_eternal(true)
	card:set_edition({ negative = true }, true)
	card:add_to_deck()
	G.jokers:emplace(card)
end
