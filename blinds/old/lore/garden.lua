local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("garden"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 0 },
	config = {
		tw_bl = {
			twitch_blind = true,
			-- tags = { "twbl_run_direction" },
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("8e15ad"),
}))

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

	-- Real Flower Pot
	local pot_card = create_card("Joker", G.play, false, nil, nil, nil, "j_flower_pot", nil)
	pot_card:set_eternal(true)
	G.play:emplace(pot_card)
	pot_card:start_materialize()

	-- Real Doc
	local doc_card = create_card("Joker", G.play, false, nil, nil, nil, "j_scholar", nil)
	doc_card.states.visible = false
	doc_card:set_edition({ negative = true }, true, true)
	G.play:emplace(doc_card)

	-- Talking doc
	G.twbl_force_speedfactor = 1
	local talking_card = Card_Character({
		x = doc_card.T.x,
		y = doc_card.T.y,
		w = doc_card.T.w,
		h = doc_card.T.h,
		center = G.P_CENTERS.j_scholar,
	})
	doc_card:remove()
	talking_card.children.particles:set_role({
		role_type = "Minor",
		xy_bond = "Strong",
		r_bond = "Strong",
		major = talking_card,
	})
	local pseudo_card = talking_card.children.card
	pseudo_card:set_edition({ negative = true }, true, true)
	G.play:emplace(pseudo_card)

	talking_card:add_speech_bubble("twbl_blinds_garden_" .. math.random(4), nil, { quip = true })
	talking_card:say_stuff(5)

	delay(2)

	G.E_MANAGER:add_event(Event({
		func = function()
			G.twbl_force_speedfactor = nil

			talking_card:remove_speech_bubble()
			talking_card.children.particles:fade(0.2, 1)
			pseudo_card:start_dissolve()

			G.E_MANAGER:add_event(Event({
				func = function()
					G.play:remove_card(pot_card)
					G.jokers:emplace(pot_card)
					pot_card:add_to_deck(true)
					talking_card:remove()
					return true
				end,
			}))

			return true
		end,
	}))
end
