local MEGA_FORWARD_ODDS = 2

local function get_ante_dx()
	return {
		1,
		-1,
		(1 / MEGA_FORWARD_ODDS > pseudorandom(pseudoseed("twbl_spiral"))) and 2 or -2,
	}
end

local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("spiral", false),
	dollars = 5,
	mult = 2,
	boss = {
		min = 999,
		max = 999,
	},
	pos = { x = 0, y = 6 },
	config = {
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				return G.GAME
					and not G.GAME.pool_flags.twbl_spiral_used
					-- min = 5
					and G.GAME.round_resets.ante >= 5
					-- max - 7
					and G.GAME.round_resets.ante <= 7
			end,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("be35b0"),
})

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind()
	G.GAME.pool_flags.twbl_spiral_used = true
	TW_BL.CHAT_COMMANDS.set_vote_variants({ "1", "2", "3" }, true)

	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", true, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("vote", true, true)
	TW_BL.CHAT_COMMANDS.reset(true, "vote")

	local dx_to_pick = get_ante_dx()
	G.GAME.twbl.blind_spiral_dx_variants = dx_to_pick

	local result_variants = {}
	for _, dx in ipairs(dx_to_pick) do
		table.insert(result_variants, "k_twbl_spiral_" .. (dx >= 0 and "p_" or "m_") .. tostring(math.abs(dx)))
	end

	TW_BL.UI.set_panel("game_top", "voting_process_3", true, true, {
		command = "vote",
		status = "k_twbl_vote_ex",
		variants = result_variants,
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", false, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("vote", false, true)
	TW_BL.CHAT_COMMANDS.reset(true, "vote")
	TW_BL.UI.remove_panel("game_top", "voting_process_3", true)

	local win_index = TW_BL.CHAT_COMMANDS.get_vote_winner()
	local win_dx = G.GAME.twbl.blind_spiral_dx_variants[tonumber(win_index or "1")]

	ease_ante(win_dx)
	G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
	G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - win_dx
	G.GAME.twbl.blind_spiral_dx_variants = nil
end
