local tw_blind = TW_BL.BLINDS.create({
	key = "twitch_chat",
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	config = {
		tw_bl = { twitch_blind = true, ignore = true },
	},
	boss_colour = HEX("8e15ad"),
	discovered = true,
	ignore_showdown_check = true,
}, nil, true)

function tw_blind.config.tw_bl:in_pool()
	return false
end

function tw_blind:in_pool()
	-- The Chat
	return false
end
