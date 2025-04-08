local tw_blind = TW_BL.BLINDS.create({
	key = "precision",
	dollars = 5,
	mult = 2,
	boss = { min = 1, max = 10 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	boss_colour = HEX("90c8c2"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

-- Implementation in lovely/blinds_precision.toml
