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

    for _, blind_name in ipairs(blinds_to_load) do
        assert(load(nativefs.read(SMODS.current_mod.path .. "/blinds/" .. blind_name .. ".lua")))()
    end

    --

    local collector = TWITCH_BLINDS.collector
    local needs_reconnect = false
    local reconnect_timeout = 0;

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

    collector.variants = { '1', '2', '3' }
    -- TODO: blocking mechanism for each command separately
    -- TODO: voters list for each command separately
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
                if collector.channel_name then collector:connect(collector.channel_name) end
            end
            collector:update()
        end

        -- Blinds effects
        blind_clock_request_increment_mult(dt)
    end

    local start_run_ref = G.FUNCS.start_run
    function G.FUNCS.start_run(e, args)
        start_run_ref(e, args)
        collector:reset()
    end

    --

    local select_blind_ref = G.FUNCS.select_blind
    function G.FUNCS.select_blind(e)
        -- Replace with blind selected by chat (or use first if no votes)
        if G.GAME.blind_on_deck == 'Boss' and G.GAME.round_resets.blind_choices.Boss and G.GAME.round_resets.blind_choices.Boss == 'bl_chat' then
            local max_score = -1
            local win_index = 1
            for _, v in ipairs(collector.variants) do
                if collector.score[v] and collector.score[v] > max_score then
                    max_score = collector.score[v]
                    win_index = tonumber(v) or win_index
                end
            end

            local picked_blind = G.GAME.pool_flags.twitch_blinds[win_index]
            -- If chat boss can be rerolled then this function should be moved to get_new_boss
            G.GAME.bosses_used[picked_blind] = G.GAME.bosses_used[picked_blind] + 1
            safe_reroll_boss(picked_blind)
        else
            select_blind_ref(e)
        end
    end

    local get_new_boss_ref = get_new_boss;
    function get_new_boss(e)
        -- Final boss works as usual
        if G.GAME.round_resets.ante % 8 == 0 then get_new_boss_ref(e) end

        local caused_by_boss_defeate = G.GAME.round_resets.blind_states.Small == 'Upcoming' and
            G.GAME.round_resets.blind_states.Big == 'Upcoming' and G.GAME.round_resets.blind_states.Boss == 'Upcoming'

        if G.GAME.round_resets.blind_choices.Boss then
            if G.GAME.round_resets.blind_choices.Boss == 'bl_chat' then
                -- Can't reroll chat
                return 'bl_chat'
            end
            if string_starts(G.GAME.round_resets.blind_choices.Boss, 'bl_twbl_') then
                if caused_by_boss_defeate then
                    -- Not start voting if next boss is final, because it's pointless
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then
                        pick_blinds_to_vote()
                        collector:reset()
                    end
                    -- Return new vanilla boss
                    return get_new_boss_ref(e)
                else
                    -- Can't reroll blind selected by chat
                    -- Subject to change?
                    return G.GAME.round_resets.blind_choices.Boss
                end
            else
                if caused_by_boss_defeate then
                    -- Spawn chat blind
                    return 'bl_chat'
                else
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then
                        pick_blinds_to_vote()
                        collector:reset()
                    end
                    -- Reroll vanilla boss as usual
                    return get_new_boss_ref(e)
                end
            end
        else
            if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then
                pick_blinds_to_vote()
                collector:reset()
            end
            return get_new_boss_ref(e)
        end
    end
end

----------------------------------------------
------------MOD CODE END----------------------
