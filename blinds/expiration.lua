local FOOD_JOKERS_KEYS = {
	["j_gros_michel"] = true,
	["j_egg"] = true,
	["j_ice_cream"] = true,
	["j_cavendish"] = true,
	["j_turtle_bean"] = true,
	["j_diet_cola"] = true,
	["j_popcorn"] = true,
	["j_ramen"] = true,
	["j_selzer"] = true,
	["j_cry_pickle"] = true,
	["j_cry_chili_pepper"] = true,
	["j_cry_oldcandy"] = true,
	["j_cry_caramel"] = true,
	["j_cry_foodm"] = true,
	["j_jank_cut_the_cheese"] = true,
	["j_cafeg"] = true,
	["j_cherry"] = true,
	["j_evo_full_sugar_cola"] = true,
	["j_bunc_starfruit"] = true,
	["j_bunc_fondue"] = true,
	["j_kcva_fortunecookie"] = true,
	["j_kcva_swiss"] = true,
	["j_olab_taliaferro"] = true,
	["j_olab_royal_gala"] = true,
	["j_olab_fine_wine"] = true,
	["j_olab_mystery_soda"] = true,
	["j_olab_popcorn_bag"] = true,
	["j_snow_turkey_dinner"] = true,
	["j_ssj_coffee"] = true,
	["j_twewy_candleService"] = true,
	["j_twewy_burningCherry"] = true,
	["j_twewy_burningMelon"] = true,
	["j_pape_soft_taco"] = true,
	["j_pape_crispy_taco"] = true,
	["j_pape_nachos"] = true,
	["j_pape_ghost_cola"] = true,
	["j_sdm_burger"] = true,
	["j_sdm_pizza"] = true,
}

local FOOD_JOKERS_NAMES = {}

local function create_food_jokers_table()
	for k, v in pairs(FOOD_JOKERS_KEYS) do
		if v and G.P_CENTERS[k] then
			FOOD_JOKERS_NAMES[G.P_CENTERS[k].name] = true
		end
	end
end

local function check_is_food_jokers()
	if not G.jokers then
		return false
	end

	if not next(FOOD_JOKERS_NAMES) then
		create_food_jokers_table()
	end

	for _, v in ipairs(G.jokers.cards) do
		if FOOD_JOKERS_NAMES[v.ability.name] then
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

	if not next(FOOD_JOKERS_NAMES) then
		create_food_jokers_table()
	end

	local cards_to_remove = {}
	for _, v in ipairs(G.jokers.cards) do
		if FOOD_JOKERS_NAMES[v.ability.name] then
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
