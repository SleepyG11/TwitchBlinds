local effect_options = {
	-- skip shop entirely
	no_shop = {
		vars_list = {
			{ shops = 1 },
			{ shops = 2 },
			{ antes = 1 },
		},
	},
	-- can reroll in shop at all
	no_reroll = {
		vars_list = {
			{ shops = 2 },
			{ shops = 3 },
		},
	},

	change_shop_slots = {
		vars_list = {
			{ shops = 2, value = -1 },
			{ shops = 2, value = 1 },
			{ shops = 3, value = -1 },
			{ shops = 3, value = 1 },
		},
	},
	change_booster_slots = {
		vars_list = {
			{ shops = 2, value = -1 },
			{ shops = 2, value = 1 },
			{ shops = 3, value = -1 },
			{ shops = 3, value = 1 },
		},
	},
	change_voucher_slots = {
		vars_list = {
			{ antes = 1, value = -1 },
			{ antes = 1, value = 1 },
		},
	},

	-- like clearance sale
	multiply_price = {
		vars_list = {
			{ shops = 2, value = -50 },
			{ shops = 2, value = 50 },
			{ shops = 3, value = -25 },
			{ shops = 3, value = 25 },
		},
	},
	-- inflation
	increase_price = {
		vars_list = {
			{ shops = 2, value = -2 },
			{ shops = 2, value = 2 },
			{ shops = 3, value = -1 },
			{ shops = 3, value = 1 },
		},
	},
}

local function apply_effect(effect)
	local key = effect.key
	if not effect.applied then
		if key == "change_shop_slots" then
			change_shop_size(effect.value)
		elseif key == "change_booster_slots" then
			SMODS.change_booster_limit(effect.value)
		elseif key == "change_voucher_slots" then
			SMODS.change_voucher_limit(effect.value)
		elseif key == "multiply_price" then
			G.GAME.discount_percent = (G.GAME.discount_percent or 0) + effect.value * -1
			for k, v in pairs(G.I.CARD) do
				if v.set_cost then
					v:set_cost()
				end
			end
		elseif key == "increase_price" then
			G.GAME.inflation = (G.GAME.inflation or 0) + effect.value
			for k, v in pairs(G.I.CARD) do
				if v.set_cost then
					v:set_cost()
				end
			end
		end
		effect.applied = true
	end
end
local function cancel_effect(effect)
	local key = effect.key
	if effect.applied then
		if key == "change_shop_slots" then
			change_shop_size(-1 * effect.value)
		elseif key == "change_booster_slots" then
			SMODS.change_booster_limit(-1 * effect.value)
		elseif key == "change_voucher_slots" then
			SMODS.change_voucher_limit(-1 * effect.value)
		elseif key == "multiply_price" then
			G.GAME.discount_percent = (G.GAME.discount_percent or 0) - effect.value * -1
			for k, v in pairs(G.I.CARD) do
				if v.set_cost then
					v:set_cost()
				end
			end
		elseif key == "increase_price" then
			G.GAME.inflation = (G.GAME.inflation or 0) - effect.value
			for k, v in pairs(G.I.CARD) do
				if v.set_cost then
					v:set_cost()
				end
			end
		end
	end
end

SMODS.Atlas({
	key = "twbl_blind_atlas_greed",
	px = 34,
	py = 34,
	path = "blinds/greed.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "greed",
	dollars = 5,
	mult = 2,
	boss = { min = 2 },
	boss_colour = HEX("bcbcbc"),

	atlas = "twbl_blind_atlas_greed",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_be_greedy_ex")
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
			local description
			if effect.vars.antes then
				description = localize({
					type = "variable",
					key = "twbl_for_antes",
					vars = { effect.vars.antes },
				})
			elseif effect.vars.shops then
				description = localize({
					type = "variable",
					key = "twbl_for_shops",
					vars = { effect.vars.shops },
				})
			end
			local loc_vars = { "" }
			if effect.vars.value then
				local sign = effect.vars.value > 0 and "+" or "-"
				loc_vars = { sign .. math.abs(effect.vars.value) }
			end
			table.insert(items, {
				text = localize({
					type = "variable",
					key = "twbl_greed_effect_" .. effect.key,
					vars = loc_vars,
				}),
				description = description,
				mystic = index == 3,
			})
		end

		return items
	end,

	set_effects = function()
		return TW_BL.utils.poll_blind_effects(effect_options, 3, "twbl_greed")
	end,
	apply_effect = function(effect)
		if G.GAME.twbl_greed_effect then
			cancel_effect(G.GAME.twbl_greed_effect)
		end
		G.GAME.twbl_greed_effect = {
			key = effect.key,
			value = effect.vars.value,
			shops = effect.vars.shops,
			antes = effect.vars.antes,
		}
	end,
})

--

-- no_shop implementation
local old_update_shop = Game.update_shop
function Game:update_shop(...)
	local effect = G.GAME.twbl_greed_effect
	if effect and effect.key == "no_shop" then
		if effect.shops then
			effect.shops = effect.shops - 1
			if effect.shops < 1 then
				cancel_effect(effect)
				G.GAME.twbl_greed_effect = nil
			end
		end
		G.STATE_COMPLETE = false
		G.STATE = G.STATES.BLIND_SELECT
		return
	end
	return old_update_shop(self, ...)
end

-- no_reroll implementation
local old_can_reroll = G.FUNCS.can_reroll
function G.FUNCS.can_reroll(e, ...)
	if G.GAME.twbl_greed_effect and G.GAME.twbl_greed_effect.key == "no_reroll" then
		e.config.button = nil
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		return
	end
	return old_can_reroll(e, ...)
end

local old_ease_ante = ease_ante
function ease_ante(amount, ...)
	local result = old_ease_ante(amount, ...)
	local effect = G.GAME.twbl_greed_effect
	if effect and effect.antes and SMODS.ante_end then
		effect.antes = effect.antes - amount
		if effect.antes < 1 then
			cancel_effect(effect)
			G.GAME.twbl_greed_effect = nil
		end
	end
	return result
end

local old_calculate = TW_BL.current_mod.calculate or function() end
function TW_BL.current_mod.calculate(self, context)
	local effect = G.GAME.twbl_greed_effect
	if effect then
		if context.starting_shop then
			apply_effect(effect)
		elseif context.ending_shop and effect.shops then
			effect.shops = effect.shops - 1
			if effect.shops < 1 then
				G.E_MANAGER:add_event(Event({
					func = function()
						cancel_effect(effect)
						G.GAME.twbl_greed_effect = nil
						return true
					end,
				}))
			end
		end
	end
	return old_calculate(self, context)
end
