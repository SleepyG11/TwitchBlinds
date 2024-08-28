function twitch_blinds_init_utilities()
	local UTILITIES = {}

	function UTILITIES.get_new_bosses(ante_offset, amount)
		TW_BL.BLINDS.setup_new_twitch_blinds(TW_BL.SETTINGS.current.pool_type, ante_offset or 0, amount or 3, false)
	end

	return UTILITIES
end
