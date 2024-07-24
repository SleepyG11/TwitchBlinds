--- STEAMODDED HEADER
--- MOD_NAME: Twitch Blinds
--- MOD_ID: TwitchBlinds
--- MOD_AUTHOR: [SleepyG11]
--- MOD_DESCRIPTION: Let your Twitch chat decide what new boss will end your run ;)

--- DISPLAY_NAME: Twitch Blinds
--- PREFIX: twbl
--- VERSION: 0.1.0
----------------------------------------------
------------MOD CODE -------------------------

local test__force_blind = nil

local blinds_to_load = {
    'chat',

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

local test_channel_name = 'sleepyg11_'

--

local nativefs = require("nativefs")
assert(load(nativefs.read(SMODS.current_mod.path .. "utilities.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "collector.lua")))()

function safe_reroll_boss(blind_name)
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

function pick_blind(eligible_bosses)
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

function pick_blinds_to_vote()
    local initial_pool = {}
    for k, v in pairs(TWITCH_BLINDS.BLINDS) do
        initial_pool[v] = true
    end
    local result = {}
    for i = 1, 3 do
        local boss = pick_blind(initial_pool);
        -- I hope setting nil in table change this value
        if #initial_pool <= 1 then
            -- This means that single picked blind remains, we need new pool
            for k, v in pairs(TWITCH_BLINDS.BLINDS) do
                initial_pool[v] = true
            end
        end
        initial_pool[boss] = nil
        table.insert(result, boss)
    end
    -- Write selected blinds to game save
    G.GAME.pool_flags.twitch_blinds = result
    return result
end

--

function SMODS.INIT.TwitchBlinds()
    TWITCH_BLINDS = {
        BLINDS = {},
        ATLASES = {
            blind_chips = SMODS.Atlas {
                key = 'twbl_blind_chips',
                px = 34,
                py = 34,
                path = 'BlindChips.png',
                atlas_table = 'ANIMATION_ATLAS',
                frames = 21,
            }
        },
        collector = TwitchCollector.new()
    }

    function TWITCH_BLINDS.toggle_can_collect(command, b, write)
        TWITCH_BLINDS.collector.can_collect[command] = b
        print('Can collect ' .. command .. ': ' .. tostring(b))
        if write and G.GAME and G.GAME.pool_flags then G.GAME.pool_flags['twitch_can_collect_' .. command] = b end
        print(inspectDepth(G.GAME.pool_flags))
    end

    function TWITCH_BLINDS.get_can_collect_from_save(game, default_values)
        print(inspectDepth(game.pool_flags))
        local commands = { 'vote', 'toggle' }
        for _, command in ipairs(commands) do
            local set_value = nil
            if (default_values) then set_value = default_values[command] end
            if game and game.pool_flags and game.pool_flags['twitch_can_collect_' .. command] ~= nil then
                set_value = game.pool_flags['twitch_can_collect_' .. command]
            end
            TWITCH_BLINDS.collector.can_collect[command] = set_value or false
            print('Can collect from save ' .. command .. ': ' .. tostring(set_value))
        end
    end

    function TWITCH_BLINDS.toggle_single_use(command, b, write)
        TWITCH_BLINDS.collector.single_use[command] = b
        print('Single use ' .. command .. ': ' .. tostring(b))
        if write and G.GAME and G.GAME.pool_flags then G.GAME.pool_flags['twitch_single_use_' .. command] = b end
        print(inspectDepth(G.GAME.pool_flags))
    end

    function TWITCH_BLINDS.get_single_use_from_save(game, default_values)
        print(inspectDepth(game.pool_flags))
        local commands = { 'vote', 'toggle' }
        for _, command in ipairs(commands) do
            local set_value = nil
            if (default_values) then set_value = default_values[command] end
            if game and game.pool_flags and game.pool_flags['twitch_single_use_' .. command] ~= nil then
                set_value = game.pool_flags['twitch_single_use_' .. command]
            end
            TWITCH_BLINDS.collector.single_use[command] = set_value or false
            print('Single use from save ' .. command .. ': ' .. tostring(set_value))
        end
    end

    for _, blind_name in ipairs(blinds_to_load) do
        assert(load(nativefs.read(SMODS.current_mod.path .. "/blinds/" .. blind_name .. ".lua")))()
    end

    --

    local collector = TWITCH_BLINDS.collector
    local needs_reconnect = false
    local reconnect_timeout = 0

    local needs_game_check = false
    local game_check_timeout = 1

    function collector:ondisconnect()
        -- Request reconnect
        needs_reconnect = true
        reconnect_timeout = 2;
    end

    function collector:onvote(username, variant)
        -- Blinds effects
    end

    function collector:ontoggle(username, index)
        -- Blinds effects
        blind_chaos_toggle_card(username, index)
        blind_flashlight_toggle_card_flip(username, index)
        blind_lock_toggle_eternal_joker(username, index)
    end

    collector.vote_variants = { '1', '2', '3' }
    collector.single_use.vote = true
    -- TODO: insert channel name from config
    collector:connect(test_channel_name)

    local love_update_ref = love.update;
    function love.update(dt)
        love_update_ref(dt)
        if reconnect_timeout >= 0 then
            reconnect_timeout = reconnect_timeout - dt
        else
            if needs_reconnect then
                needs_reconnect = false
                collector:reconnect()
            end
            collector:update()
        end

        -- Read save
        if game_check_timeout >= 0 then
            game_check_timeout = game_check_timeout - dt
        else
            if needs_game_check then
                needs_game_check = false
                if G.GAME then
                    TWITCH_BLINDS.get_can_collect_from_save(G.GAME, {
                        vote = false,
                        toggle = false,
                    })
                    TWITCH_BLINDS.get_single_use_from_save(G.GAME, {
                        vote = false,
                        toggle = false,
                    })
                end
            end
        end

        -- Blinds effects
        blind_clock_request_increment_mult(dt)
    end

    local start_run_ref = G.FUNCS.start_run
    function G.FUNCS.start_run(arg1, arg2, arg3)
        start_run_ref(arg1, arg2, arg3)
        -- idk, without delay it's not working
        game_check_timeout = 1
        needs_game_check = true
        collector:reset()
    end

    local main_menu_ref = G.main_menu
    function G.main_menu(arg1, arg2)
        main_menu_ref(arg1, arg2)

        TWITCH_BLINDS.toggle_can_collect('vote', false, false)
        TWITCH_BLINDS.toggle_can_collect('toggle', false, false)
        collector:reset()
    end

    --

    local select_blind_ref = G.FUNCS.select_blind
    function G.FUNCS.select_blind(arg1, arg2)
        -- Replace with blind selected by chat (or use first if no votes)
        if G.GAME.blind_on_deck == 'Boss' and G.GAME.round_resets.blind_choices.Boss and G.GAME.round_resets.blind_choices.Boss == 'bl_twitch_chat' then
            local max_score = -1
            local win_index = 1
            for _, v in ipairs(collector.vote_variants) do
                if collector.vote_score[v] and collector.vote_score[v] > max_score then
                    max_score = collector.vote_score[v]
                    win_index = tonumber(v) or win_index
                end
            end

            if not G.GAME.pool_flags.twitch_blinds then pick_blinds_to_vote() end
            local picked_blind = test__force_blind or G.GAME.pool_flags.twitch_blinds[win_index]
            -- WARN: If chat boss can be rerolled then this function should be moved to get_new_boss
            G.GAME.bosses_used[picked_blind] = G.GAME.bosses_used[picked_blind] + 1
            safe_reroll_boss(picked_blind)
            TWITCH_BLINDS.toggle_can_collect('vote', false, true)
        else
            select_blind_ref(arg1, arg2)
        end
    end

    local get_new_boss_ref = get_new_boss;
    function get_new_boss(arg1, arg2)
        -- Final boss works as usual
        if G.GAME.round_resets.ante % 8 == 0 then get_new_boss_ref(arg1, arg2) end

        local caused_by_boss_defeate = G.GAME.round_resets.blind_states.Small == 'Upcoming' and
            G.GAME.round_resets.blind_states.Big == 'Upcoming' and G.GAME.round_resets.blind_states.Boss == 'Upcoming'

        if test__force_blind then
            if not G.GAME.round_resets.blind_choices.Boss or caused_by_boss_defeate then
                pick_blinds_to_vote()
                TWITCH_BLINDS.toggle_can_collect('vote', true, true)
                collector:reset()
            end
            return 'bl_twitch_chat'
        end

        if G.GAME.round_resets.blind_choices.Boss then
            if G.GAME.round_resets.blind_choices.Boss == 'bl_twitch_chat' then
                -- Can't reroll chat
                return 'bl_twitch_chat'
            end
            if string_starts(G.GAME.round_resets.blind_choices.Boss, 'bl_twbl_') then
                if caused_by_boss_defeate then
                    -- Not start voting if next boss is final, because it's pointless
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then
                        pick_blinds_to_vote()
                        TWITCH_BLINDS.toggle_can_collect('vote', true, true)
                        collector:reset()
                    end
                    -- Return new vanilla boss
                    return get_new_boss_ref(arg1, arg2)
                else
                    -- Can't reroll blind selected by chat
                    -- Subject to change?
                    return G.GAME.round_resets.blind_choices.Boss
                end
            else
                if caused_by_boss_defeate then
                    -- Spawn chat blind
                    return 'bl_twitch_chat'
                else
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then
                        pick_blinds_to_vote()
                        TWITCH_BLINDS.toggle_can_collect('vote', true, true)
                        collector:reset()
                    end
                    -- Reroll vanilla boss as usual
                    return get_new_boss_ref(arg1, arg2)
                end
            end
        else
            if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then
                pick_blinds_to_vote()
                TWITCH_BLINDS.toggle_can_collect('vote', true, true)
                collector:reset()
            end
            return get_new_boss_ref(arg1, arg2)
        end
    end
end

----------------------------------------------
------------MOD CODE END----------------------
