local DEFAULT_SETTINGS = {
    blind_frequency = 2,
    pool_type = 1,
    channel_name = '',
    forced_blind = nil,
}

function twitch_blinds_init_settings()
    local SETTINGS = {
        default = DEFAULT_SETTINGS,
        temp = nil,
        current = table_defaults(TW_BL.current_mod.config, DEFAULT_SETTINGS),
    }

    function SETTINGS.create_temp()
        SETTINGS.temp = table_copy(SETTINGS.current)
    end

    function SETTINGS.save()
        SETTINGS.current = table_merge(SETTINGS.current, SETTINGS.temp)
        TW_BL.current_mod.config = SETTINGS.current
        SMODS.save_mod_config(TW_BL.current_mod)
    end

    return SETTINGS
end
