local MEGA_FORWARD_ODDS = 3

local function get_ante_dx()
	return {
		1,
		-1,
		(1 / MEGA_FORWARD_ODDS > pseudorandom(pseudoseed("twbl_spiral"))) and 2 or -2,
	}
end

local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("spiral"),
	dollars = 5,
	mult = 2,
	boss = {
		min = -1,
		max = -1,
	},
	pos = { x = 0, y = 28 },
	config = {
		tw_bl = {
			twitch_blind = true,
			min = 4,
			max = 5,
			tags = { "twbl_run_direction" },
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("a17040"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.set_vote_variants("blind_spiral_ante", { "1", "2", "3" }, true)
	TW_BL.CHAT_COMMANDS.reset("blind_spiral_ante", "vote")
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("vote", 1, true)

	local dx_to_pick = get_ante_dx()
	TW_BL.G.blind_spiral_dx_variants = dx_to_pick

	local result_variants = {}
	for _, dx in ipairs(dx_to_pick) do
		table.insert(result_variants, "k_twbl_spiral_" .. (dx >= 0 and "p_" or "m_") .. tostring(math.abs(dx)))
	end

	TW_BL.UI.set_panel("game_top", "voting_process_3", true, true, {
		command = "vote",
		status = "k_twbl_vote_ex",
		id = "blind_spiral_ante",
		variants = result_variants,
		mystic_variants = { [3] = true },
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("vote", nil, true)
	TW_BL.UI.remove_panel("game_top", "voting_process_3", true)

	local win_index = TW_BL.CHAT_COMMANDS.get_vote_winner("blind_spiral_ante")
	local win_dx = TW_BL.G.blind_spiral_dx_variants[tonumber(win_index or "1")]

	ease_ante(win_dx)
	G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
	G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - win_dx
	TW_BL.G.blind_spiral_dx_variants = nil

	TW_BL.CHAT_COMMANDS.set_vote_variants("blind_spiral_ante", {}, true)
	TW_BL.CHAT_COMMANDS.reset("blind_spiral_ante", "vote")
end

TW_BL.EVENTS.add_listener("twitch_command", "blind_spiral", function(command, username, variant)
	if command ~= "vote" or not G.GAME.blind or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("spiral") then
		return
	end

	if TW_BL.CHAT_COMMANDS.can_vote_for_variant("blind_spiral_ante", variant) then
		TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
		TW_BL.CHAT_COMMANDS.increment_vote_score("blind_spiral_ante", variant)
		TW_BL.UI.update_panel("game_top", nil, false)
		TW_BL.UI.create_panel_notify("game_top", nil, username)
	end
end)
