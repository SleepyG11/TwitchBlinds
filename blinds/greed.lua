local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("greed", false),
	dollars = 8,
	mult = 2,
	boss = { min = 1, max = 10 },
	pos = { x = 0, y = 21 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("bcbcbc"),
})

-- Implementation in lovely/blinds_greed.toml

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	TW_BL.G.no_shop = true
end
