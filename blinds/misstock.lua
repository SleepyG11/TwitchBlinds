local POOLS_TO_IGNORE = {
	["Edition"] = true,
	["Back"] = true,
	["Tag"] = true,
	["Seal"] = true,
	["Stake"] = true,
	["Demo"] = true,
}

local POOLS_TO_PICK = {
	["Tarot"] = "b_tarot_cards",
	["Planet"] = "b_planet_cards",
	["Booster"] = "b_booster_packs",
	["Enhanced"] = "b_enhanced_cards",
	["Joker"] = "b_jokers",
	["Spectral"] = "b_spectral_cards",
}

local tw_blind = SMODS.Blind({
	key = register_twitch_blind("misstock", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 16 },
	config = {
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				-- Incompatible with Cryptid's equilibrium deck (wait for Steamodded update)
				return not G.GAME.modifiers.cry_equilibrium
			end,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("3dabff"),
})

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function twitch_misstock_set_type(v)
	local _type = v.type
	if G.GAME.pool_flags.twitch_misstock_pool and not POOLS_TO_IGNORE[_type] then
		return {
			type = G.GAME.pool_flags.twitch_misstock_pool,
			val = 0,
		}
	end
	return v
end

local get_pack_ref = get_pack
function get_pack(_key, _type)
	if G.GAME.pool_flags.twitch_misstock_pool then
		if G.GAME.pool_flags.twitch_misstock_pool == "Enhanced" then
			-- TODO: place playing cards somehow
			return G.P_CENTERS["p_standard_normal_" .. math.random(1, 4)]
		else
			local POOL_ITEMS = {}
			for k, v in pairs(G.P_CENTER_POOLS[G.GAME.pool_flags.twitch_misstock_pool]) do
				if not v.no_doe then
					POOL_ITEMS[#POOL_ITEMS + 1] = v.key
				end
			end
			return G.P_CENTERS[pseudorandom_element(POOL_ITEMS, pseudoseed("twbl_misstock" .. G.GAME.round_resets.ante))]
		end
	end
	return get_pack_ref(_key, _type)
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.set_vote_variants({ "1", "2", "3" }, true)
	TW_BL.CHAT_COMMANDS.reset()

	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", true, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("vote", true, true)

	local pools_to_pick = table_copy(POOLS_TO_PICK)

	local result_pools = {}
	local result_variants = {}
	for i = 1, 3 do
		local loc_key, pool = pseudorandom_element(pools_to_pick, pseudoseed("twbl_misstock_pool"))
		table.insert(result_pools, pool)
		table.insert(result_variants, loc_key)
		pools_to_pick[pool] = nil
	end

	G.GAME.pool_flags.twitch_misstock_pools = result_pools

	TW_BL.UI.set_panel("voting_process_3", true, true, {
		command = "vote",
		status = "k_twbl_vote_ex",
		variants = result_variants,
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", false, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("vote", false, true)
	TW_BL.UI.remove_panel("voting_process_3", true)

	local win_index = TW_BL.CHAT_COMMANDS.get_vote_winner()
	G.GAME.pool_flags.twitch_misstock_pool = G.GAME.pool_flags.twitch_misstock_pools[tonumber(win_index or "1")]
	G.GAME.pool_flags.twitch_misstock_pools = nil
end
