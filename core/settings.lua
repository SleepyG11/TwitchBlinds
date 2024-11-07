local DEFAULT_SETTINGS = {
	blind_frequency = 2,
	blind_pool_type = 1,
	pool_type = 1,
	channel_name = "",
	forced_blind = nil,

	delay_for_chat = 1,

	natural_chat_booster_sticker = false,
	chat_booster_sticker_appearance = 1,
	natural_blinds = false,

	mystic_variants = true,
	discovery_bypass = false,
}

function twbl_init_settings()
	local init_settings = table_defaults(TW_BL.current_mod.config, DEFAULT_SETTINGS)

	local SETTINGS = {
		default = DEFAULT_SETTINGS,
		temp = {},
		current = table_copy(init_settings),
	}

	TW_BL.SETTINGS = SETTINGS

	function SETTINGS.save()
		TW_BL.current_mod.config = SETTINGS.current
		SMODS.save_mod_config(TW_BL.current_mod)
	end

	return SETTINGS
end
