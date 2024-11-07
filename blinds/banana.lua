local REPLACE_ODDS = 6

local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("banana"),
	dollars = 5,
	mult = 2,
	boss = { min = 2, max = 10 },
	config = {
		extra = { odds = REPLACE_ODDS },
		tw_bl = { twitch_blind = true, min = 2 },
	},
	vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), "" .. REPLACE_ODDS },
	pos = { x = 0, y = 4 },
	atlas = "twbl_blind_chips",
	boss_colour = HEX("e2ce00"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind) and G.jokers and #G.jokers.cards > 2 and #G.jokers.cards <= 10
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind) and G.jokers and #G.jokers.cards > 2 and #G.jokers.cards <= 10
end

function tw_blind:loc_vars()
	return {
		vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), "" .. REPLACE_ODDS },
	}
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	local jokers_list = {}
	for _, v in ipairs(G.jokers.cards) do
		table.insert(jokers_list, v)
	end
	for _, v in ipairs(jokers_list) do
		if
			G.GAME.probabilities.normal / G.GAME.blind.config.blind.config.extra.odds
			> pseudorandom(pseudoseed("twbl_banana"))
		then
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound("tarot1")
					v.T.r = -0.2
					v:juice_up(0.3, 0.4)
					v.states.drag.is = true
					v.children.center.pinch.x = true
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.3,
						blockable = false,
						func = function()
							G.jokers:remove_card(v)
							v:remove()
							v = nil
							local card = create_card("Joker", G.jokers, false, nil, nil, nil, "j_gros_michel", nil)
							card:add_to_deck()
							G.jokers:emplace(card)
							return true
						end,
					}))
					return true
				end,
			}))
			card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_twbl_banana_ex") })
		else
			G.E_MANAGER:add_event(Event({
				func = function()
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
			card_eval_status_text(v, "extra", nil, nil, nil, { message = localize("k_safe_ex") })
		end
	end
end
