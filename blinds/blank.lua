local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("blank", false),
	dollars = 0,
	mult = 0,
	boss = { min = 1, max = 4 },
	config = {
		tw_bl = { twitch_blind = true, min = 1, max = 4 },
	},
	pos = { x = 0, y = 16 },
	atlas = "twbl_blind_chips",
	boss_colour = HEX("636c81"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end
