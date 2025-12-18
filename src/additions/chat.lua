SMODS.Atlas({
	key = "twbl_blind_atlas_chat",
	px = 34,
	py = 34,
	path = "blinds/chat.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

SMODS.Blind({
	key = "chat",
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	boss_colour = HEX("8e15ad"),
	discovered = true,
	discoverable = false,

	atlas = "twbl_blind_atlas_chat",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_ignore = true,
	-- twbl_in_pool = function(self)
	-- 	return false
	-- end,
	-- twbl_boss = { min = -1, max = -1 },
	-- twbl_weight = 0,
	-- twbl_get_weight = function(self)
	-- 	return self.twbl_weight or 1
	-- end,

	twbl_select_blind = function(self, args)
		if G.GAME.blind_on_deck ~= "Boss" then
			-- If somehow chat is in non-boss position, insert random boss here
			TW_BL.blinds.replace_blind(G.GAME.blind_on_deck, TW_BL.refs.get_new_boss())
		else
			-- TW_BL.EVENTS.request_delay(5, "voting_blind")
			G.E_MANAGER:add_event(Event({
				func = function()
					local picked_blind, winner = TW_BL.blind_voting.finish_blind_voting()
					if not picked_blind then
						TW_BL.refs.select_blind(unpack(args))
					else
						TW_BL.blinds.replace_blind(G.GAME.blind_on_deck, picked_blind)
					end
					return true
				end,
			}))
		end
		return true
	end,
})

TW_BL.CHAT_BLIND = "bl_twbl_chat"
TW_BL.blinds.chat_blind = TW_BL.CHAT_BLIND
