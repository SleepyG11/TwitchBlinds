local FOOL_JOKERS = {
	["Gros Michel"] = true,
	["Egg"] = true,
	["Ice Cream"] = true,
	["Cavendish"] = true,
	["Turtle Bean"] = true,
	["Diet Cola"] = true,
	["Popcorn"] = true,
	["Ramen"] = true,
	["Seltzer"] = true,
}

local function check_is_food_jokers()
	if not G.jokers then
		return false
	end
	for _, v in ipairs(G.jokers.cards) do
		if FOOL_JOKERS[v.ability.name] then
			return true
		end
	end
	return false
end

local tw_blind = SMODS.Blind({
	key = register_twitch_blind("expiration", false),
	dollars = 5,
	mult = 2,
	boss = { min = 1, max = 10 },
	pos = { x = 0, y = 9 },
	config = {
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				return check_is_food_jokers()
			end,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("b35216"),
})

function tw_blind:in_pool()
	return check_is_food_jokers()
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	local cards_to_remove = {}
	for _, v in ipairs(G.jokers.cards) do
		if FOOL_JOKERS[v.ability.name] then
			table.insert(cards_to_remove, v)
		end
	end
	for _, v in ipairs(cards_to_remove) do
		G.GAME.blind:wiggle()
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
						return true
					end,
				}))
				return true
			end,
		}))
		-- TODO: localization
		card_eval_status_text(v, "extra", nil, nil, nil, { message = G.localization.misc.dictionary.k_twbl_tumors_ex })
	end
end
