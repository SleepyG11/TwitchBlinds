-- WIP

local tw_blind = SMODS.Blind({
	key = register_twitch_blind("spiral", false),
	dollars = 5,
	mult = 2,
	boss = {
		min = 999,
		max = 999,
	},
	pos = { x = 0, y = 6 },
	config = { tw_bl = { in_pool = true } },
	atlas = "twbl_blind_chips",
	boss_colour = HEX("be35b0"),
})
