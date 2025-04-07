local NOPE_ODDS = 4

local tw_blind = TW_BL.BLINDS.create({
	key = "lucky_wheel",
	dollars = 5,
	mult = 2,
	boss = { min = 2, max = 10 },
	config = {
		extra = { nope_odds = NOPE_ODDS },
		tw_bl = {
			twitch_blind = true,
		},
	},
	vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), "" .. NOPE_ODDS },
	boss_colour = HEX("00d231"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind) and G.jokers and #G.jokers.cards > 1
end

function tw_blind:in_pool()
	-- Never lucky!
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

	ease_background_colour_blind()

	local jokers_list = {}
	for _, v in ipairs(G.jokers.cards) do
		table.insert(jokers_list, v)
	end
	for _, v in ipairs(jokers_list) do
		local edition = poll_edition("twbl_lucky_wheel", nil, false, true)
		v:set_edition(edition, true)
	end
end
