local tw_blind = SMODS.Blind({
	key = register_twitch_blind("chisel", false),
	dollars = 5,
	mult = 2,
	boss = { min = 1, max = 10 },
	pos = { x = 0, y = 11 },
	config = {
		tw_bl = { twitch_blind = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("ce512b"),
})

function tw_blind:loc_vars()
	local selected_hand = nil
	if G.GAME.blind and G.GAME.blind.hands and G.GAME.blind.hands.selected then
		-- If hand selected before, use it
		selected_hand = G.GAME.blind.hands.selected
	else
		-- Find true most played hand and display it
		local _handname, _played, _order = "High Card", -1, 100
		for k, v in pairs(G.GAME.hands) do
			if v.played > _played or (v.played == _played and _order > v.order) then
				_played = v.played
				_handname = k
			end
		end
		selected_hand = _handname
	end

	return { vars = { localize(selected_hand, "poker_hands") } }
end

function tw_blind:collection_loc_vars()
	return { vars = { localize("ph_most_played") } }
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	-- Find true most played hand and save it
	local _handname, _played, _order = "High Card", -1, 100
	for k, v in pairs(G.GAME.hands) do
		if v.played > _played or (v.played == _played and _order > v.order) then
			_played = v.played
			_handname = k
		end
	end

	G.GAME.blind.hands = {
		["debuffed"] = _handname,
		["selected"] = _handname,
	}
end

function tw_blind:debuff_hand(cards, hand, handname, check)
	if G.GAME.blind.hands and G.GAME.blind.hands.debuffed == handname then
		G.GAME.blind.triggered = true
		if not check then
			G.GAME.blind.hands.debuffed = nil
		end
		return true
	end
	return false
end
