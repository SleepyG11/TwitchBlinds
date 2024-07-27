local nativefs = require("nativefs")

local blinds_to_load = {
    'afk',
    'taxes',
    'vaporation',
    'trash_can',
    'banana',
    'astronomer',
    'magician',
    -- '777',
    -- 'end',
    'jimbo',
    'precision',
    'clock',
    'chaos',
    'circus',
    'flashlight',
    'lock',
    'chisel',
    'expiration',
    'isaac',
}

function twitch_blinds_init_blinds()
    local BLINDS = {
        --- @type string[]
        loaded = {},
        --- @type string[]
        regular = {},
        --- @type string[]
        final = {},

        --- @type string
        chat_blind = nil,
        --- @type number
        blinds_to_vote = 3,
    }

    function register_twitch_blind(blind_name, final_boss)
        local full_key = 'bl_twbl_' .. blind_name
        table.insert(BLINDS.loaded, full_key)
        table.insert((final_boss and BLINDS.final) or BLINDS.regular, full_key)
        return 'twbl_' .. blind_name
    end

    --- @param blind_name string
    --- @return string
    function get_twitch_blind_key(blind_name)
        return 'bl_twbl_' .. blind_name
    end

    assert(load(nativefs.read(SMODS.current_mod.path .. "blinds/chat.lua")))()
    for _, blind_name in ipairs(blinds_to_load) do
        assert(load(nativefs.read(SMODS.current_mod.path .. "blinds/" .. blind_name .. ".lua")))()
    end
    BLINDS.chat_blind = 'bl_twitch_chat'

    --- Get one random boss blind from list
    --- @param pool { [string]: boolean } List to choose from
    --- @return string
    function BLINDS.get_random_boss_blind(pool)
        local eligible_bosses = {}
        for k, v in pairs(pool) do
            eligible_bosses[k] = 0
        end
        local min_use = 9999
        for k, v in pairs(G.GAME.bosses_used) do
            if eligible_bosses[k] then
                eligible_bosses[k] = v
                if eligible_bosses[k] <= min_use then
                    min_use = eligible_bosses[k]
                end
            end
        end
        for k, v in pairs(eligible_bosses) do
            if eligible_bosses[k] then
                if eligible_bosses[k] > min_use then
                    eligible_bosses[k] = nil
                end
            end
        end
        local _, boss = pseudorandom_element(eligible_bosses, pseudoseed('twbl_boss_pick'))
        G.GAME.bosses_used[boss] = (G.GAME.bosses_used[boss] or 0) + 1
        return boss
    end

    --- Get specified amount of random boss blinds from list
    --- @param initial_pool string[] List to choose from
    --- @param count number Amount of blinds to choose
    --- @return string[]
    function BLINDS.get_list_of_random_boss_blinds(initial_pool, count)
        local pool = {}
        for _, v in ipairs(initial_pool) do
            pool[v] = true
        end
        local result = {}
        for i = 1, count do
            local boss = BLINDS.get_random_boss_blind(pool);
            if #pool <= 1 then
                -- This means that single picked blind remains, we need new pool
                for _, v in ipairs(initial_pool) do
                    pool[v] = true
                end
            end
            table.insert(result, boss)
            for _, v in ipairs(result) do
                -- No repeat bosses
                pool[v] = nil
            end
        end
        return result
    end

    --- Set current boss blind
    --- @param blind_name string
    function BLINDS.set_boss_blind(blind_name)
        stop_use()
        G.CONTROLLER.locks.boss_reroll = true
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                play_sound('other1')
                G.blind_select_opts.boss:set_role({ xy_bond = 'Weak' })
                G.blind_select_opts.boss.alignment.offset.y = 20
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = (function()
                local par = G.blind_select_opts.boss.parent
                G.GAME.round_resets.blind_choices.Boss = blind_name
                G.blind_select_opts.boss:remove()
                G.blind_select_opts.boss = UIBox {
                    T = { par.T.x, 0, 0, 0, },
                    definition =
                    { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {
                        UIBox_dyn_container({ create_UIBox_blind_choice('Boss') }, false, get_blind_main_colour('Boss'), mix_colours(G.C.BLACK, get_blind_main_colour('Boss'), 0.8))
                    } },
                    config = { align = "bmi",
                        offset = { x = 0, y = G.ROOM.T.y + 9 },
                        major = par,
                        xy_bond = 'Weak'
                    }
                }
                par.config.object = G.blind_select_opts.boss
                par.config.object:recalculate()
                G.blind_select_opts.boss.parent = par
                G.blind_select_opts.boss.alignment.offset.y = 0

                G.E_MANAGER:add_event(Event({
                    blocking = false,
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        G.CONTROLLER.locks.boss_reroll = nil
                        return true
                    end
                }))

                save_run()
                return true
            end)
        }))
    end

    --- Save twitch blinds in game
    --- @param blinds string[] Generate new list and save in game if not present
    --- @return boolean `true` if set successfully, `false` if `G.GAME` is not ready
    function BLINDS.set_twitch_blinds_to_game(blinds)
        if G.GAME and G.GAME.pool_flags then
            G.GAME.pool_flags.twitch_blinds = blinds
            return true
        else
            return false
        end
    end

    --- Get twitch blinds from game
    --- @param pool_type integer Generate new list and save if not present
    --- @param generate_if_missing boolean Generate new list and save if not present
    --- @return string[]|nil
    function BLINDS.get_twitch_blinds_from_game(pool_type, generate_if_missing)
        if G.GAME and G.GAME.pool_flags then
            if G.GAME.pool_flags.twitch_blinds then return G.GAME.pool_flags.twitch_blinds end
            if generate_if_missing then return BLINDS.setup_new_twitch_blinds(pool_type, false) end
            -- TODO: final blinds
            -- if generate_if_missing then return BLINDS.setup_new_twitch_blinds(pool_type, G.GAME.round_resets.ante % 8 == 0) end
        else
            return nil
        end
    end

    --- Get all blinds from game except chat
    --- @param final_boss boolean
    --- @param exclude_twitch_blinds boolean
    --- @return string[]
    function BLINDS.get_all_blinds(final_boss, exclude_twitch_blinds)
        local eligible_bosses = {}
        for k, v in pairs(G.P_BLINDS) do
            if not v.boss then

            elseif (not v.boss.showdown and (not final_boss or G.GAME.round_resets.ante < 2)) and (v.boss.min <= math.max(1, G.GAME.round_resets.ante)) then
                eligible_bosses[k] = true
            elseif v.boss.showdown and final_boss and G.GAME.round_resets.ante >= 2 then
                eligible_bosses[k] = true
            end
        end
        for k, v in pairs(G.GAME.banned_keys) do
            if eligible_bosses[k] then eligible_bosses[k] = nil end
        end
        eligible_bosses[BLINDS.chat_blind] = nil

        if not exclude_twitch_blinds then
            for _, k in ipairs((final_boss and BLINDS.final) or BLINDS.regular) do
                eligible_bosses[k] = true
            end
        end

        local result = {}
        for k, v in pairs(eligible_bosses) do
            table.insert(result, k)
        end

        return result
    end

    --- Generate new list of twitch blinds and save it
    --- @param pool_type integer Generate new list and save if not present
    --- @param final_boss boolean?
    --- @return string[]|nil
    function BLINDS.setup_new_twitch_blinds(pool_type, final_boss)
        local pool = (final_boss and BLINDS.final) or BLINDS.regular
        if pool_type == 1 then
            -- Twitch Blinds
            pool = (final_boss and BLINDS.get_all_blinds(final_boss or false, true)) or BLINDS.regular
            -- TODO: final blinds
            -- pool = (final_boss and BLINDS.final) or BLINDS.regular
        elseif pool_type == 2 then
            -- All other
            pool = BLINDS.get_all_blinds(final_boss or false, true)
        elseif pool_type == 3 then
            -- All
            pool = BLINDS.get_all_blinds(final_boss or false, false)
        end

        local new_list = BLINDS.get_list_of_random_boss_blinds(pool, BLINDS.blinds_to_vote)
        local success = BLINDS.set_twitch_blinds_to_game(new_list)
        if success then return new_list end
        return nil
    end

    return BLINDS
end
