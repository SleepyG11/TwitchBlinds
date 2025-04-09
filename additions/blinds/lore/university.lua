local tw_blind = TW_BL.BLINDS.create({
	key = "university",
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	config = {
		tw_bl = {
			twitch_blind = true,
			one_time = true,
			-- tags = { "twbl_run_direction" },
		},
	},
	boss_colour = HEX("8e15ad"),
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

	-- Real doc
	local doc_card = create_card("Joker", G.play, false, nil, nil, nil, "j_scholar", nil)
	doc_card.states.visible = false
	doc_card:set_edition({ negative = true }, true, true)
	doc_card:set_eternal(true)
	G.play:emplace(doc_card)

	-- Talking doc

	local talking_card = Card_Character({
		x = doc_card.T.x,
		y = doc_card.T.y,
		w = doc_card.T.w,
		h = doc_card.T.h,
		center = G.P_CENTERS.j_scholar,
	})
	local pseudo_card = talking_card.children.card
	pseudo_card:set_edition({ negative = true }, true, true)
	pseudo_card:set_eternal(true)

	talking_card:add_speech_bubble("twbl_blinds_university_" .. math.random(4), nil, { quip = true })
	talking_card:say_stuff(5)

	delay(2)
	G.E_MANAGER:add_event(Event({
		func = function()
			G.twbl_force_speedfactor = nil
			talking_card:remove_speech_bubble()
			talking_card.children.particles:fade(0.2, 1)
			pseudo_card.states.visible = false

			doc_card.states.visible = true
			G.play:remove_card(doc_card)
			G.jokers:emplace(doc_card)
			doc_card:add_to_deck(true)

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
