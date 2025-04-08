local tw_blind = TW_BL.BLINDS.create({
	key = "greed",
	dollars = 8,
	mult = 2,
	boss = { min = 1, max = 10 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	boss_colour = HEX("bcbcbc"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

-- Implementation in lovely/blinds_greed.toml

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	TW_BL.G.greed_no_shop = true
end
