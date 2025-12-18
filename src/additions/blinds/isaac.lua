-- Actually no idea how make this blind interactive

SMODS.Atlas({
	key = "twbl_blind_atlas_isaac",
	px = 34,
	py = 34,
	path = "blinds/isaac.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "isaac",
	dollars = 5,
	mult = 2,
	boss = { min = 4, max = 5 },
	boss_colour = HEX("d82727"),

	atlas = "twbl_blind_atlas_isaac",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return TW_BL.blinds.is_in_range(self, true) and pseudorandom("twbl_isaac_encounter") < 0.05
	end,
	twbl_once_per_run = true,

	set_blind = function(self)
		ease_background_colour_blind()

		-- SMODS.add_card too slow
		local card = SMODS.create_card({
			key = "j_ceremonial",
			area = G.jokers,
		})
		card.pinned = true
		card:set_eternal(true)
		card:set_edition("e_negative", true, true)
		card:add_to_deck()
		G.jokers:emplace(card)
	end,
})
