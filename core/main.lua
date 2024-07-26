local nativefs = require("nativefs")

TwitchBlinds = Object:extend()
TW_BL = TwitchBlinds

assert(load(nativefs.read(SMODS.current_mod.path .. "core/settings.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/blinds.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/chat_commands.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/ui.lua")))()

local test__force_blind = nil

function TwitchBlinds:init()
    self.SETTINGS = twitch_blinds_init_settings()
    self.SETTINGS.current_mod_path = SMODS.current_mod.path
    self.SETTINGS:read_from_file()

    self.ATLASES = {
        blind_chips = SMODS.Atlas {
            key = 'twbl_blind_chips',
            px = 34,
            py = 34,
            path = 'BlindChips.png',
            atlas_table = 'ANIMATION_ATLAS',
            frames = 21,
        }
    }
    self.BLINDS = twitch_blinds_init_blinds()
    self.CHAT_COMMANDS = twitch_blinds_init_chat_commands()
    self.UI = twitch_blinds_init_ui()

    -- Timeouts

    local needs_reconnect = false
    local reconnect_timeout = 0

    -- Attach socket events

    function self.CHAT_COMMANDS.collector:ondisconnect()
        -- Request reconnect
        needs_reconnect = true
        reconnect_timeout = 2;
    end

    function self.CHAT_COMMANDS.collector:onvote(username, variant)
        print("Vote collected: " .. username .. " -> " .. variant)
        TW_BL.UI.update_voting_process(false)
    end

    function self.CHAT_COMMANDS.collector:ontoggle(username, index)
        TW_BL:on_toggle_trigger_blinds(username, index)
    end

    -- Overriding

    local game_start_run_ref = Game.start_run
    function Game:start_run(arg1, arg2)
        game_start_run_ref(self, arg1, arg2)

        needs_reconnect = false
        reconnect_timeout = 0

        print('Connecting to ' .. TW_BL.SETTINGS.current.channel_name)
        TW_BL.CHAT_COMMANDS.collector:connect(TW_BL.SETTINGS.current.channel_name, true)

        TW_BL.CHAT_COMMANDS.get_can_collect_from_game({
            vote = false,
            toggle = false,
        })
        TW_BL.CHAT_COMMANDS.get_single_use_from_game({
            vote = false,
            toggle = false,
        })

        TW_BL.CHAT_COMMANDS.collector:reset()

        local variants = {}
        for i = 1, TW_BL.BLINDS.blinds_to_vote do
            table.insert(variants, tostring(i))
        end
        TW_BL.CHAT_COMMANDS.collector.vote_variants = variants

        TW_BL.UI.draw_voting_process()
        TW_BL.UI.update_voting_process(true)
    end

    local main_menu_ref = Game.main_menu
    function Game:main_menu(arg1, arg2)
        main_menu_ref(self, arg1, arg2)

        TW_BL.CHAT_COMMANDS.toggle_can_collect('vote', false, false)
        TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, false)
        TW_BL.CHAT_COMMANDS.collector:reset()
        TW_BL.CHAT_COMMANDS.collector:disconnect(true)
    end

    local love_update_ref = love.update;
    function love.update(dt)
        love_update_ref(dt)

        if reconnect_timeout >= 0 then
            reconnect_timeout = reconnect_timeout - dt
        else
            if needs_reconnect then
                needs_reconnect = false
                self.CHAT_COMMANDS.collector:reconnect()
            end
        end

        self.CHAT_COMMANDS.collector:update()

        TW_BL:on_update_trigger_blinds(dt)
    end

    local select_blind_ref = G.FUNCS.select_blind
    function G.FUNCS.select_blind(arg1, arg2)
        -- Replace with blind selected by chat (or use first if no votes)
        if G.GAME.blind_on_deck == 'Boss' and G.GAME.round_resets.blind_choices.Boss and G.GAME.round_resets.blind_choices.Boss == TW_BL.BLINDS.chat_blind then
            local blinds_to_choose = TW_BL.BLINDS.get_twitch_blinds_from_game(true)
            if not blinds_to_choose then return select_blind_ref(arg1, arg2) end
            local win_variant, win_score, win_percent = TW_BL.CHAT_COMMANDS.get_vote_winner()
            local picked_blind = test__force_blind or blinds_to_choose[tonumber(win_variant or '1')]
            TW_BL.BLINDS.set_boss_blind(picked_blind)
            TW_BL.CHAT_COMMANDS.toggle_can_collect('vote', false, true)
            TW_BL.UI.update_voting_process(false)
        else
            return select_blind_ref(arg1, arg2)
        end
    end

    local get_new_boss_ref = get_new_boss;
    function get_new_boss(arg1, arg2)
        -- Final boss works as usual, for now
        if G.GAME.round_resets.ante % 8 == 0 then return get_new_boss_ref(arg1, arg2) end

        local caused_by_boss_defeate = G.GAME.round_resets.blind_states.Small == 'Upcoming' and
            G.GAME.round_resets.blind_states.Big == 'Upcoming' and G.GAME.round_resets.blind_states.Boss == 'Upcoming'

        if test__force_blind then
            if not G.GAME.round_resets.blind_choices.Boss or caused_by_boss_defeate then
                TW_BL:start_new_twitch_blinds_voting(false)
            end
            return TW_BL.BLINDS.chat_blind
        end

        if G.GAME.round_resets.blind_choices.Boss then
            if G.GAME.round_resets.blind_choices.Boss == TW_BL.BLINDS.chat_blind then
                -- Can't reroll chat
                return TW_BL.BLINDS.chat_blind
            end
            if string_starts(G.GAME.round_resets.blind_choices.Boss, 'bl_twbl_') then
                if caused_by_boss_defeate then
                    -- Not start voting if next boss is final, for now
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then TW_BL:start_new_twitch_blinds_voting(false) end
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
                    return TW_BL.BLINDS.chat_blind
                else
                    -- Not start voting if next boss is final, for now
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then TW_BL:start_new_twitch_blinds_voting(false) end
                    -- Reroll vanilla boss as usual
                    return get_new_boss_ref(arg1, arg2)
                end
            end
        else
            -- Not start voting if next boss is final, for now
            if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then TW_BL:start_new_twitch_blinds_voting(false) end
            return get_new_boss_ref(arg1, arg2)
        end
    end
end

--- @param final_boss boolean
function TwitchBlinds:start_new_twitch_blinds_voting(final_boss)
    self.BLINDS.setup_new_twitch_blinds(final_boss)
    self.CHAT_COMMANDS.toggle_can_collect('vote', true, true)
    self.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    self.CHAT_COMMANDS.collector:reset()

    self.UI.update_voting_process(true)
end

--- @param dt number
function TwitchBlinds:on_update_trigger_blinds(dt)
    blind_clock_request_increment_mult(dt)
end

--- @param username string
--- @param index number
function TwitchBlinds:on_toggle_trigger_blinds(username, index)
    blind_chaos_toggle_card(username, index)
    blind_flashlight_toggle_card_flip(username, index)
    blind_lock_toggle_eternal_joker(username, index)
end
