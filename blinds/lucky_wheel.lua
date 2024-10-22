local NOPE_ODDS = 4

local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("lucky_wheel", false),
	dollars = 5,
	mult = 2,
	boss = { min = 2, max = 10 },
	config = {
		extra = { nope_odds = NOPE_ODDS },
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				return G.jokers and G.jokers.cards and #G.jokers.cards > 1
			end,
		},
	},
	pos = { x = 0, y = 27 },
	atlas = "twbl_blind_chips",
	boss_colour = HEX("00d231"),
})

function tw_blind:in_pool()
	-- Nope!
	return false
end

function tw_blind:loc_vars()
	return {
		vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), "" .. NOPE_ODDS },
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
		local edition = poll_edition("twbl_lucky_wheel", nil, false, true)
		v:set_edition(edition, true)
	end
end
