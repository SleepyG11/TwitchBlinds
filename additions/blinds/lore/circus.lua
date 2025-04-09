local tw_blind = TW_BL.BLINDS.create({
	key = "circus",
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	config = {
		tw_bl = {
			twitch_blind = true,
			one_time = true,
			-- tags = { "twbl_run_direction" }
		},
	},
	boss_colour = HEX("da2424"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	ease_background_colour_blind()

	G.twbl_force_speedfactor = 1

	-- Real showman
	local jimbo_card = create_card("Joker", G.play, false, nil, nil, nil, "j_ring_master", nil)
	jimbo_card.states.visible = false
	jimbo_card:set_edition({ negative = true }, true)
	jimbo_card:set_eternal(true)
	G.play:emplace(jimbo_card)

	-- Talking showman
	local talking_card = Card_Character({
		x = jimbo_card.T.x,
		y = jimbo_card.T.y,
		w = jimbo_card.T.w,
		h = jimbo_card.T.h,
		center = G.P_CENTERS.j_ring_master,
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
					return true
				end,
			}))

			return true
		end,
	}))
end
