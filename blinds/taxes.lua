local TRIGGER_ODDS = 2

local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("taxes"),
	dollars = 5,
	mult = 2,
	boss = { min = 3, max = 10 },
	pos = { x = 0, y = 14 },
	config = {
		extra = { odds = TRIGGER_ODDS },
		tw_bl = { twitch_blind = true, min = 3 },
	},
	vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), "" .. TRIGGER_ODDS },
	atlas = "twbl_blind_chips",
	boss_colour = HEX("d9c200"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind) and G.jokers and #G.jokers.cards > 2 and #G.jokers.cards <= 10
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind) and G.jokers and #G.jokers.cards > 2 and #G.jokers.cards <= 10
end

function tw_blind:loc_vars()
	return {
		vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), "" .. TRIGGER_ODDS },
	}
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	ease_background_colour_blind()

	for k, v in ipairs(G.jokers.cards) do
		local is_triggered = G.GAME.probabilities.normal / G.GAME.blind.config.blind.config.extra.odds
			> pseudorandom(pseudoseed("twbl_taxes"))
		G.E_MANAGER:add_event(Event({
			func = function()
				if is_triggered then
					v:juice_up(0.3, 0.4)
					v:set_rental(true)
				end
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.3,
					blockable = false,
					func = function()
						return true
					end,
				}))
				return true
			end,
		}))
		if is_triggered then
			card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_twbl_taxes_ex") })
		else
			card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_safe_ex") })
		end
	end
end
