local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("vaporation", false),
	dollars = 5,
	mult = 2,
	boss = { min = 2, max = 10 },
	pos = { x = 0, y = 5 },
	config = {
		tw_bl = { twitch_blind = true, min = 2 },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("a7d2ce"),
})

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
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
