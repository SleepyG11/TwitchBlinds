SMODS.Atlas({
	key = "twbl_blind_atlas_lucky_wheel",
	px = 34,
	py = 34,
	path = "blinds/lucky_wheel.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

SMODS.Blind({
	key = "lucky_wheel",
	dollars = 5,
	mult = 2,
	boss = { min = 2 },

	config = {
		extra = { nope_odds = 4 },
	},

	boss_colour = HEX("00d231"),

	atlas = "twbl_blind_atlas_lucky_wheel",

	in_pool = function()
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return G.jokers and #G.jokers.cards > 1 and TW_BL.blinds.is_in_range(self)
	end,

	loc_vars = function(self)
		return { vars = { SMODS.get_probability_vars(nil, 1, self.config.extra.nope_odds, "twbl_lucky_wheel_select") } }
	end,
	collection_loc_vars = function(self)
		return {
			vars = { SMODS.get_probability_vars(nil, 1, self.config.extra.nope_odds, "twbl_lucky_wheel_select", true) },
		}
	end,

	set_blind = function(self)
		ease_background_colour_blind()

		for _, card in ipairs(G.jokers.cards) do
			local edition = SMODS.poll_edition({
				key = "twbl_lucky_wheel_edition",
				no_negative = false,
				guaranteed = true,
			})
			card:set_edition(edition, false)
		end
	end,

	twbl_select_blind = function(self, e)
		if not SMODS.pseudorandom_probability(nil, "twbl_lucky_wheel_select", 1, self.config.extra.nope_odds) then
			-- TODO: show Nope! attention_text
			-- implement later ig
			discover_card(self)
			TW_BL.blinds.replace_blind(G.GAME.blind_on_deck, "bl_twbl_nope")
			return true
		end
	end,
})
