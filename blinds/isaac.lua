local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("isaac", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 1 },
	config = {
		tw_bl = { twitch_blind = true, min = 4, max = 5 },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("d82727"),
})

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	G.GAME.blind:wiggle()
	local card = create_card("Joker", G.jokers, false, nil, nil, nil, "j_ceremonial", nil)
	card.pinned = true
	card:set_edition({ negative = true })
	card:set_eternal(true)
	card:add_to_deck()
	G.jokers:emplace(card)
end
