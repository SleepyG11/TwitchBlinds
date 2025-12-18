SMODS.Atlas({
	key = "twbl_blind_atlas_precision",
	px = 34,
	py = 34,
	path = "blinds/precision.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "precision",
	dollars = 5,
	mult = 2,
	boss = { min = 1 },
	boss_colour = HEX("90c8c2"),

	atlas = "twbl_blind_atlas_precision",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
})
