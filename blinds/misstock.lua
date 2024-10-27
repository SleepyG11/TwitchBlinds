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
	key = TW_BL.BLINDS.register("misstock", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 25 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("cf2f3f"),
})

-- Implementation in lovely/blinds_misstock.toml

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind) and not G.GAME.modifiers.cry_equilibrium
end

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function twbl_blind_misstock_set_type(v)
	local _type = v.type
	if TW_BL.G.blind_misstock_pool and not POOLS_TO_IGNORE[_type] then
		return {
			type = TW_BL.G.blind_misstock_pool,
			val = 0,
		}
	end
	return v
end

local get_pack_ref = get_pack
function get_pack(_key, _type)
	if TW_BL.G.blind_misstock_pool then
		if TW_BL.G.blind_misstock_pool == "Enhanced" then
			-- TODO: place playing cards somehow
			return G.P_CENTERS["p_standard_normal_" .. math.random(1, 4)]
		else
			local POOL_ITEMS = {}
			for k, v in pairs(G.P_CENTER_POOLS[TW_BL.G.blind_misstock_pool]) do
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
	TW_BL.EVENTS.set_delay_threshold("voting_misstock", 5)
	TW_BL.CHAT_COMMANDS.set_vote_variants("blind_misstock_pool", { "1", "2", "3" }, true)
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("vote", 1, true)
	TW_BL.CHAT_COMMANDS.reset("blind_misstock_pool", "vote")

	local pools_to_pick = table_copy(POOLS_TO_PICK)

	local result_pools = {}
	local result_variants = {}
	for i = 1, 3 do
		local loc_key, pool = pseudorandom_element(pools_to_pick, pseudoseed("twbl_misstock_pool"))
		table.insert(result_pools, pool)
		table.insert(result_variants, loc_key)
		pools_to_pick[pool] = nil
	end

	TW_BL.G.blind_misstock_pools = result_pools

	TW_BL.UI.set_panel("game_top", "voting_process_3", true, true, {
		command = "vote",
		status = "k_twbl_vote_ex",
		id = "blind_misstock_pool",
		variants = result_variants,
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("vote", nil, true)

	TW_BL.UI.remove_panel("game_top", "voting_process_3", true)

	local win_index = TW_BL.CHAT_COMMANDS.get_vote_winner("blind_misstock_pool")
	TW_BL.G.blind_misstock_pool = TW_BL.G.blind_misstock_pools[tonumber(win_index or "1")]
	TW_BL.G.blind_misstock_pools = nil

	TW_BL.CHAT_COMMANDS.set_vote_variants("blind_misstock_pool", {}, true)
	TW_BL.CHAT_COMMANDS.reset("blind_misstock_pool", "vote")
end

TW_BL.EVENTS.add_listener("twitch_command", "blind_misstock", function(command, username, variant)
	if command ~= "vote" or not G.GAME.blind or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("misstock") then
		return
	end

	if TW_BL.CHAT_COMMANDS.can_vote_for_variant("blind_misstock_pool", variant) then
		TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
		TW_BL.CHAT_COMMANDS.increment_vote_score("blind_misstock_pool", variant)
		TW_BL.UI.update_panel("game_top", nil, false)
		TW_BL.UI.create_panel_notify("game_top", nil, username)
	end
end)
