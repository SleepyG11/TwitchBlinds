local tw_blind = TW_BL.BLINDS.create({
	key = "vaporation",
	dollars = 5,
	mult = 2,
	boss = { min = 3, max = 10 },
	config = {
		tw_bl = {
			twitch_blind = true,
			min = 3,
		},
	},
	boss_colour = HEX("a7d2ce"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind) and G.jokers and #G.jokers.cards > 2 and #G.jokers.cards <= 15
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind) and G.jokers and #G.jokers.cards > 2 and #G.jokers.cards <= 15
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	ease_background_colour_blind()

	for k, v in ipairs(G.jokers.cards) do
		G.E_MANAGER:add_event(Event({
			func = function()
				v:juice_up(0.3, 0.4)
				v:set_perishable(true)
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
		card_eval_status_text(v, "extra", nil, nil, nil, { message = G.localization.misc.labels.perishable .. "!" })
	end
end
