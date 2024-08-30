function twbl_init_utilities()
	local UTILITIES = {}

    TW_BL.UTILITIES = UTILITIES

    --- Get index of a voting blind
    --- @param target "winner" | "loser" | integer | nil
    --- @return string or nil
	function UTILITIES.get_vote_variant(target)
		if not TW_BL.CHAT_COMMANDS.vote_variants then
			return nil
		end
		if tonumber(target) then
			return TW_BL.CHAT_COMMANDS.vote_variants[tonumber(target)]
		end
		if target == "winner" then
			local win_index = TW_BL.CHAT_COMMANDS.get_vote_winner()
			return win_index
		elseif target == "loser" then
			local result = nil
			local score = math.huge

			for k, v in pairs(TW_BL.CHAT_COMMANDS.get_vote_status()) do
				if not v.winner and v.score <= score then
					result = k
					score = v.score
				end
			end

			return result or "1"
		else
			return pseudorandom_element(TW_BL.CHAT_COMMANDS.vote_variants, pseudoseed("twbl_rnd_blind_variant"))
		end
	end

	--- Generate new list of blinds
	--- @param ante_offset integer Difference between current ante and target ante
    --- @param amount integer Amount of blinds to choose
	--- @return string[]|nil
	function UTILITIES.get_new_bosses(ante_offset, amount)
		return TW_BL.BLINDS.generate_new_voting_blinds(
			TW_BL.SETTINGS.current.pool_type,
			ante_offset or 0,
			amount or 3,
			false
		)
	end

    --- Replace one of voting bosses
    --- @param blind string Blins key
    --- @param target "winner" | "loser" | integer | nil Specific blind to search or random if `nil`
    --- @param notify boolean Display attention text on panel if blind is replaced
    --- @param reset boolean Reset voting score
	function UTILITIES.replace_voting_blind(blind, target, notify, reset)
		local variant = TW_BL.UTILITIES.get_vote_variant(target)
		if variant then
            ---@diagnostic disable-next-line: cast-local-type
			variant = tonumber(variant)
		end
		local blinds_to_vote = TW_BL.BLINDS.get_voting_blinds_from_game(TW_BL.SETTINGS.current.pool_type, false)
		if not variant or not blinds_to_vote or not blinds_to_vote[variant] then
			return false
		end
		blinds_to_vote[variant] = blind
		if not TW_BL.BLINDS.set_voting_blinds_to_game(blinds) then
			return false
		end
		if reset then
			TW_BL.CHAT_COMMANDS.reset()
		end
		if notify and TW_BL.UI.current_panel == "blind_voting_process" then
			local element = TW_BL.UI.current_panel.config and TW_BL.UI.current_panel.config.element
			if element then
				local boss_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(variant) .. "_blind_name")
				if boss_element then
					attention_text({
						text = localize("k_twbl_replaced_ex"),
						scale = 0.5,
						hold = 0.5,
						backdrop_colour = G.C.GOLD,
						align = "cmi",
						major = boss_element,
						offset = {
							x = 0,
							y = 0,
						},
					})
				end
			end
		end
		TW_BL.UI.update_panel("blind_voting_process", true)
		return true
	end

    --- Check is current boss is The Chat
    --- @return boolean
	function UTILITIES.is_chat_blind_present()
		return G.GAME and G.GAME.round_resets.blind_choices.Boss == TW_BL.BLINDS.chat_blind
	end

	return UTILITIES
end
