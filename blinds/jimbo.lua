local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("jimbo", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 12 },
	config = {
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				return pseudorandom(pseudoseed("twbl_blind_jimbo_in_pool")) > 3 / 4
			end,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("0077e8"),
})

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	local card = create_card("Joker", G.jokers, false, nil, nil, nil, "j_joker", nil)
	card:set_eternal(true)
	card:add_to_deck()
	G.jokers:emplace(card)
end
