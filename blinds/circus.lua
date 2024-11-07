local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("circus"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 10 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("da2424"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind) and pseudorandom(pseudoseed("twbl_blind_circus_in_pool")) > 1 / 2
end

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	local card = create_card("Joker", G.jokers, false, nil, nil, nil, "j_ring_master", nil)
	card:set_edition({ negative = true }, true)
	card:set_eternal(true)
	card:add_to_deck()
	G.jokers:emplace(card)
end
