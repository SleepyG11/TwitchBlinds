local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("jimbo"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 12 },
	config = {
		tw_bl = {
			twitch_blind = true,
			-- tags = { "twbl_run_direction" },
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("0077e8"),
}))

function tw_blind.config.tw_bl:in_pool()
	return not TW_BL.G.blind_jimbo_encountered and TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	TW_BL.G.blind_jimbo_encountered = true
	local is_finished = false
	G.E_MANAGER:add_event(Event({
		func = function()
			return is_finished
		end,
	}))

	ease_background_colour_blind()

	G.twbl_force_event_queue = "twbl_cutscenes"
	G.twbl_force_speedfactor = 1

	-- Real doc
	local jimbo_card = create_card("Joker", G.play, false, nil, nil, nil, "j_joker", nil)
	jimbo_card.states.visible = false
	jimbo_card:set_eternal(true)
	G.play:emplace(jimbo_card)

	-- Talking doc

	local talking_card = Card_Character({
		x = jimbo_card.T.x,
		y = jimbo_card.T.y,
		w = jimbo_card.T.w,
		h = jimbo_card.T.h,
		center = G.P_CENTERS.j_joker,
	})
	local pseudo_card = talking_card.children.card
	pseudo_card:set_eternal(true)

	talking_card:add_speech_bubble("twbl_blinds_jimbo_" .. math.random(7), nil, { quip = true })
	talking_card:say_stuff(5)

	delay(2)
	G.E_MANAGER:add_event(Event({
		func = function()
			G.twbl_force_event_queue = "twbl_cutscenes"
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
					G.twbl_force_event_queue = "twbl_cutscenes"
					talking_card:remove()
					G.twbl_force_event_queue = nil
					is_finished = true
					return true
				end,
			}))
			G.twbl_force_event_queue = nil
			return true
		end,
	}))
	G.twbl_force_event_queue = nil
end
