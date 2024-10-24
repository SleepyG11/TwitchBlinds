local DEFAULT_SETTINGS = {
	blind_frequency = 2,
	blind_pool_type = 1,
	pool_type = 1,
	channel_name = "",
	forced_blind = nil,

	delay_for_chat = 1,

	natural_chat_booster_sticker = false,
	natural_blinds = false,
}

function twbl_init_settings()
	local init_settings = table_defaults(TW_BL.current_mod.config, DEFAULT_SETTINGS)

	local SETTINGS = {
		default = DEFAULT_SETTINGS,
		temp = table_copy(init_settings),
		current = table_copy(init_settings),
	}

	TW_BL.SETTINGS = SETTINGS

	function SETTINGS.create_temp()
		SETTINGS.temp = table_copy(SETTINGS.current)
	end

	function SETTINGS.save()
		SETTINGS.current = SETTINGS.temp
		TW_BL.current_mod.config = SETTINGS.current
		SETTINGS.create_temp()
		SMODS.save_mod_config(TW_BL.current_mod)
	end

	SETTINGS.create_temp()

	return SETTINGS
end
