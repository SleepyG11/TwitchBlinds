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

    function collector:onvote(username, variant)
        print('Vote collected: ' .. username .. ' -> ' .. variant)

        -- Blinds effects
    end

    function collector:onselect(username, index)
        print('Select collected: ' .. username .. ' -> ' .. tostring(index))

        -- Blinds effects
        blind_chaos_toggle_card(index)
    end

    collector.variants = { '1', '2', '3' }
    -- TODO: blocking mechanism for each command separately
    -- TODO: voters list for each command separately
    -- TODO: reconnect mechanism
    -- TODO: insert channel name from config
    collector:connect(test_channel_name)

    local love_update_ref = love.update;
    function love.update(dt)
        love_update_ref(dt)
        collector:update()

        -- Blinds effects
        blind_clock_request_increment_mult(dt)
    end

    --

    local start_run_ref = G.FUNCS.start_run
    function G.FUNCS.start_run(e, args)
        start_run_ref(e, args)
        collector:reset()
    end

    local select_blind_ref = G.FUNCS.select_blind
    function G.FUNCS.select_blind(e)
        -- Replace with blind selected by chat
        if G.GAME.blind_on_deck == 'Boss' and G.GAME.round_resets.blind_choices.Boss and G.GAME.round_resets.blind_choices.Boss == 'bl_chat' then
            -- TODO: picking mechanism
            safe_reroll_boss('bl_twbl_chaos') -- For now only direct blind picking, for test purposes
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
                    -- Reroll vanilla boss as usual
                    return get_new_boss_ref(e)
                end
            end
        end
        return get_new_boss_ref(e)
    end
end

----------------------------------------------
------------MOD CODE END----------------------
