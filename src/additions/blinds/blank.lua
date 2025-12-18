SMODS.Atlas({
	key = "twbl_blind_atlas_blank",
	px = 34,
	py = 34,
	path = "blinds/blank.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

SMODS.Blind({
	key = "blank",
	dollars = 0,
	mult = 0,
	boss = { min = -1, max = -1 },

	boss_colour = HEX("636c81"),

	atlas = "twbl_blind_atlas_blank",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_ignore = true,
})
