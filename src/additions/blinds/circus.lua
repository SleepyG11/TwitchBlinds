SMODS.Atlas({
	key = "twbl_blind_atlas_circus",
	px = 34,
	py = 34,
	path = "blinds/circus.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "circus",
	dollars = 5,
	mult = 2,
	boss = { min = 2, max = 5 },
	boss_colour = HEX("da2424"),

	atlas = "twbl_blind_atlas_circus",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return TW_BL.blinds.is_in_range(self, true) and pseudorandom("twbl_circus_encounter") < 0.05
	end,
	twbl_once_per_run = true,

	set_blind = function(self)
		ease_background_colour_blind()

		local is_finished = false
		G.E_MANAGER:add_event(Event({
			func = function()
				return is_finished
			end,
		}))

		G.E_MANAGER.queues["twbl_cutscenes"] = G.E_MANAGER.queues["twbl_cutscenes"] or {}
		G.twbl_force_event_queue = "twbl_cutscenes"
		G.twbl_force_speedfactor = 1

		-- Real showman
		local jimbo_card = create_card("Joker", G.play, false, nil, nil, nil, "j_ring_master", nil)
		jimbo_card.states.visible = false
		jimbo_card:set_edition("e_negative", true, true)
		jimbo_card:set_eternal(true)
		G.play:emplace(jimbo_card)

		-- Talking showman
		local talking_card = Card_Character({
			x = jimbo_card.T.x,
			y = jimbo_card.T.y,
			w = jimbo_card.T.w,
			h = jimbo_card.T.h,
			center = "j_ring_master",
		})
		local pseudo_card = talking_card.children.card
		pseudo_card:set_eternal(true)
		pseudo_card:set_edition({ negative = true }, true)

		talking_card:add_speech_bubble("twbl_blinds_circus_" .. math.random(1), nil, { quip = true })
		talking_card:say_stuff(5)

		delay(2)
		G.E_MANAGER:add_event(Event({
			func = function()
				G.twbl_force_speedfactor = nil
				talking_card:remove_speech_bubble()
				talking_card.children.particles:fade(0.2, 1)
				pseudo_card.states.visible = false

				jimbo_card.states.visible = true
				G.play:remove_card(jimbo_card)
				G.jokers:emplace(jimbo_card)
				jimbo_card:add_to_deck()

				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.2,
					func = function()
						talking_card:remove()
						G.twbl_force_event_queue = nil
						G.twbl_force_speedfactor = nil
						is_finished = true
						return true
					end,
				}))

				return true
			end,
		}))
	end,
})
