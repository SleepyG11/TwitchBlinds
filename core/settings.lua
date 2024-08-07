local nativefs = require("nativefs")

function twitch_blinds_init_settings(current_mod_path)
    local SETTINGS = {
        default = {
            blind_frequency = 2,
            pool_type = 1,
            channel_name = '',
            forced_blind = nil,
        },
        temp = nil,
        current = {},

        current_mod_path = current_mod_path
    }

    function SETTINGS.write_to_file()
        nativefs.write(SETTINGS.current_mod_path .. "user_settings.lua", STR_PACK(SETTINGS.current))
    end

    function SETTINGS.read_from_file()
        if not nativefs.getInfo(SETTINGS.current_mod_path .. "user_settings.lua") then
            SETTINGS.current = table_copy(SETTINGS.default)
            SETTINGS.write_to_file()
        else
            local file_settings = STR_UNPACK(nativefs.read(SETTINGS.current_mod_path .. "user_settings.lua"))
            if not file_settings then
                SETTINGS.current = table_copy(SETTINGS.default)
                SETTINGS.write_to_file()
            else
                SETTINGS.current = table_merge(table_copy(SETTINGS.default), file_settings)
            end
        end
    end

    function SETTINGS.create_temp()
        SETTINGS.temp = table_copy(SETTINGS.current)
    end

    function SETTINGS.save()
        SETTINGS.current = table_copy(SETTINGS.temp)
        SETTINGS.write_to_file()
    end

    return SETTINGS
end
