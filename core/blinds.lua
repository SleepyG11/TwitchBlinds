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
    --- @param eligible_bosses string[] List to choose from
    function BLINDS.get_random_boss_blind(eligible_bosses)
        if not G.GAME then return nil end
        local min_use = 100
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
        G.GAME.bosses_used[boss] = G.GAME.bosses_used[boss] + 1

        return boss
    end

    --- Get specified amount of random boss blinds from list
    --- @param eligible_bosses string[] List to choose from
    --- @param count number Amount of blinds to choose
    function BLINDS.get_list_of_random_boss_blinds(eligible_bosses, count)
        local initial_pool = {}
        for k, v in pairs(eligible_bosses) do
            initial_pool[v] = true
        end
        local result = {}
        for i = 1, count do
            local boss = BLINDS.get_random_boss_blind(initial_pool);
            -- I hope setting nil in table change this value
            if #initial_pool <= 1 then
                -- This means that single picked blind remains, we need new pool
                for k, v in pairs(eligible_bosses) do
                    initial_pool[v] = true
                end
            end
            initial_pool[boss] = nil
            table.insert(result, boss)
        end
        -- -- Write selected blinds to game save
        -- G.GAME.pool_flags.twitch_blinds = result
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
    --- @param generate_if_missing boolean Generate new list and save if not present
    --- @return string[]|nil
    function BLINDS.get_twitch_blinds_from_game(generate_if_missing)
        if G.GAME and G.GAME.pool_flags then
            if G.GAME.pool_flags.twitch_blinds then return G.GAME.pool_flags.twitch_blinds end
            if generate_if_missing then return BLINDS.setup_new_twitch_blinds(false) end
            -- if generate_if_missing then return BLINDS.setup_new_twitch_blinds(G.GAME.round_resets.ante % 8 == 0) end
        else
            return nil
        end
    end

    --- Generate new list of twitch blinds and save it
    --- @param final_boss boolean?
    --- @return string[]|nil
    function BLINDS.setup_new_twitch_blinds(final_boss)
        local new_list = BLINDS.get_list_of_random_boss_blinds(
            (final_boss and BLINDS.final) or BLINDS.regular,
            BLINDS.blinds_to_vote
        )
        local success = BLINDS.set_twitch_blinds_to_game(new_list)
        if success then return new_list end
        return nil
    end

    return BLINDS
end
