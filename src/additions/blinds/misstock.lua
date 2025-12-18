local effect_options = {
	["Tarot"] = {
		key = "b_tarot_cards",
		vars_list = {
			{ shops = 2 },
			{ shops = 3 },
		},
	},
	["Planet"] = {
		key = "b_planet_cards",
		booster_kind = "Celestial",
		vars_list = {
			{ shops = 2 },
			{ shops = 3 },
		},
	},
	["Booster"] = {
		key = "b_booster_packs",
		vars_list = {
			{ shops = 1 },
		},
	},
	["Enhanced"] = {
		key = "b_enhanced_cards",
		booster_kind = "Standard",
		vars_list = {
			{ shops = 2 },
			{ shops = 3 },
		},
	},
	["Joker"] = {
		key = "b_jokers",
		vars_list = {
			{ shops = 2 },
			{ shops = 3 },
		},
	},
	["Spectral"] = {
		key = "b_spectral_cards",
		vars_list = {
			{ shops = 1 },
		},
	},
}

SMODS.Atlas({
	key = "twbl_blind_atlas_misstock",
	px = 34,
	py = 34,
	path = "blinds/misstock.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "misstock",
	dollars = 5,
	mult = 2,
	boss = { min = 2 },
	boss_colour = HEX("cf2f3f"),

	atlas = "twbl_blind_atlas_misstock",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_choose_ex")
	end,
	command = "vote",
	command_max_uses = 1,
	voting = true,
	set_vote_variants = function()
		return { "1", "2", "3" }
	end,

	get_items = function(effects)
		local items = {}
		for index, effect in ipairs(effects) do
			local effect_def = effect_options[effect.key]
			table.insert(items, {
				text = localize(effect_def.key),
				description = localize({
					type = "variable",
					key = "twbl_for_shops",
					vars = { effect.vars.shops },
				}),
				mystic = index == 3,
			})
		end
		return items
	end,

	set_effects = function()
		return TW_BL.utils.poll_blind_effects(effect_options, 3, "twbl_misstock")
	end,
	apply_effect = function(effect)
		local effect_def = effect_options[effect.key]
		G.GAME.twbl_misstock_effect = {
			set = effect.key,
			booster_kind = effect_def.booster_kind,
			shops = effect.vars.shops or 1,
		}
	end,
})

--

local get_pack_ref = get_pack
function get_pack(_key, _type, ...)
	if G.GAME.twbl_misstock_effect then
		local booster_kind = G.GAME.twbl_misstock_effect.booster_kind
		local set = G.GAME.twbl_misstock_effect.set
		if booster_kind then
			return get_pack_ref(_key, booster_kind, ...)
		else
			local _pool, _pool_key = get_current_pool(set, nil, nil, "twbl_misstock_shop_override")
			local center =
				pseudorandom_element(_pool, pseudoseed("twbl_misstock_shop_item" .. G.GAME.round_resets.ante))
			local it = 1
			while center == "UNAVAILABLE" do
				it = it + 1
				center = pseudorandom_element(_pool, pseudoseed(_pool_key .. "_resample" .. it))
			end

			return G.P_CENTERS[center]
		end
	end
	return get_pack_ref(_key, _type, ...)
end

local old_calculate = TW_BL.current_mod.calculate or function() end
function TW_BL.current_mod.calculate(self, context)
	if G.GAME.twbl_misstock_effect then
		if context.create_shop_card then
			return {
				shop_create_flags = { set = G.GAME.twbl_misstock_effect.set, soulable = true },
			}
		elseif context.ending_shop then
			G.GAME.twbl_misstock_effect.shops = G.GAME.twbl_misstock_effect.shops - 1
			if G.GAME.twbl_misstock_effect.shops < 1 then
				G.GAME.twbl_misstock_effect = nil
			end
		end
	end
	return old_calculate(self, context)
end
