function twitch_blinds_init_utilities()
	local UTILITIES = {}

	function UTILITIES.get_twitch_blind_variant(target)
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

	function UTILITIES.get_new_bosses(ante_offset, amount)
		return TW_BL.BLINDS.setup_new_twitch_blinds(
			TW_BL.SETTINGS.current.pool_type,
			ante_offset or 0,
			amount or 3,
			false
		)
	end

	function UTILITIES.replace_blind_in_voting_process(blind, target, notify, reset)
		local variant = TW_BL.UTILITIES.get_twitch_blind_variant(target)
		if variant then
			variant = tonumber(variant)
		end
		local blinds_to_vote = TW_BL.BLINDS.get_twitch_blinds_from_game(TW_BL.SETTINGS.current.pool_type, false)
		if not variant or not blinds_to_vote or not blinds_to_vote[variant] then
			return false
		end
		blinds_to_vote[variant] = blind
		if not TW_BL.BLINDS.set_twitch_blinds_to_game(blinds) then
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

	return UTILITIES
end
