local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("twitch_chat"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 0 },
	config = {
		tw_bl = { twitch_blind = true, ignore = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("8e15ad"),
	discovered = true,
	ignore_showdown_check = true,
})

function tw_blind.config.tw_bl:in_pool()
	return false
end

function tw_blind:in_pool()
	-- The Chat
	return false
end
