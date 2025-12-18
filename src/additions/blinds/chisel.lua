SMODS.Atlas({
	key = "twbl_blind_atlas_chisel",
	px = 34,
	py = 34,
	path = "blinds/chisel.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "chisel",
	dollars = 5,
	mult = 2,
	boss = { min = 2 },
	boss_colour = HEX("ce512b"),

	atlas = "twbl_blind_atlas_chisel",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,

	loc_vars = function(self)
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
	end,
	collection_loc_vars = function()
		return { vars = { localize("ph_most_played") } }
	end,

	set_blind = function(self)
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
	end,
	debuff_hand = function(self, cards, hand, handname, check)
		if G.GAME.blind.hands and G.GAME.blind.hands.debuffed == handname then
			G.GAME.blind.triggered = true
			if not check then
				G.GAME.blind.hands.debuffed = nil
			end
			return true
		end
		return false
	end,
})
