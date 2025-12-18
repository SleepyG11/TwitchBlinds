SMODS.Atlas({
	key = "twbl_blind_atlas_acceptance",
	px = 34,
	py = 34,
	path = "blinds/acceptance.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local spectrals_to_pool = {
	["c_wraith"] = true,
	["c_ouija"] = true,
	["c_ectoplasm"] = true,
	["c_immolate"] = true,
	["c_ankh"] = true,
	["c_hex"] = true,
	["c_incantation"] = true,
}

local blind = SMODS.Blind({
	key = "acceptance",
	dollars = 5,
	mult = 2,
	boss = { min = 1 },
	boss_colour = HEX("8cacdc"),

	in_pool = function(self)
		return false
	end,

	atlas = "twbl_blind_atlas_acceptance",

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return TW_BL.blinds.is_in_range(self, true) and pseudorandom("twbl_acceptance_encounter") < 0.25
	end,
	twbl_once_per_run = true,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	command = "vote",
	command_max_uses = 1,
	connected_status_text = function()
		return localize("k_twbl_choose_ex")
	end,
	voting = true,
	set_vote_variants = function()
		return { "1", "2", "3" }
	end,
	set_effects = function()
		local result = {}
		local pool = TW_BL.utils.table_shallow_copy(spectrals_to_pool)
		for i = 1, 3 do
			local _, key = pseudorandom_element(pool, "twbl_acceptance_pool" .. G.GAME.round_resets.ante)
			table.insert(result, {
				key = key,
			})
			pool[key] = nil
		end
		return result
	end,
	get_items = function(effects)
		local items = {}
		for index, effect in ipairs(effects) do
			table.insert(items, {
				text = localize({ type = "name_text", set = "Spectral", key = effect.key, vars = {} }),
				mystic = index == 1,
				-- TODO: UI for displaying spectral info_queue
			})
		end
		return items
	end,
	apply_effect = function(effect)
		local card = SMODS.add_card({
			key = effect.key,
			area = G.consumeables,
		})
		card.ability.twb_cannot_sell_eternal = true
		card.ability.eternal = true
	end,
})

local pk_can_sell = Card.can_sell_card
function Card:can_sell_card(context)
	if self.ability.twb_cannot_sell_eternal and self.ability.eternal then
		return false
	end
	return pk_can_sell(self, context)
end
