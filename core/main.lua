local nativefs = require("nativefs")

TwitchBlinds = Object:extend()
TW_BL = TwitchBlinds

assert(load(nativefs.read(SMODS.current_mod.path .. "core/events.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/settings.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/blinds.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/chat_commands.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/ui.lua")))()

function TwitchBlinds:init()
    self.EVENTS = twitch_blinds_init_events()

    self.SETTINGS = twitch_blinds_init_settings(SMODS.current_mod.path)
    self.SETTINGS:read_from_file()

    self.__DEV_MODE = self.SETTINGS.current.dev_mode

    self.UI = twitch_blinds_init_ui()
    self.BLINDS = twitch_blinds_init_blinds()
    self.CHAT_COMMANDS = twitch_blinds_init_chat_commands()

    TW_BL.CHAT_COMMANDS.collector:connect(TW_BL.SETTINGS.current.channel_name, true)

    -- Overriding

    local game_start_run_ref = Game.start_run
    function Game:start_run(...)
        game_start_run_ref(self, ...)
        TW_BL:start_run()
    end

    local main_menu_ref = Game.main_menu
    function Game:main_menu(...)
        main_menu_ref(self, ...)
        TW_BL:main_menu()
    end

    local love_update_ref = love.update;
    function love.update(dt, ...)
        love_update_ref(dt, ...)
        TW_BL.EVENTS.emit('game_update', dt)
    end

    local get_new_boss_ref = get_new_boss;
    function get_new_boss(...)
        local is_first_boss = not G.GAME.round_resets.blind_choices.Boss
        local caused_by_boss_defeate = (G.GAME.round_resets.blind_states.Small == 'Upcoming' or G.GAME.round_resets.blind_states.Small == 'Hide') and
            G.GAME.round_resets.blind_states.Big == 'Upcoming' and G.GAME.round_resets.blind_states.Boss == 'Upcoming'

        local is_overriding = false

        local result = nil
        local start_voting_process = false
        local force_voting_process = false
        local voting_ante_offset = 0

        if not G.GAME.pool_flags.twitch_chat_blind_antes then
            -- If no data in save, then assume that we don't see chat at most 1 ante
            G.GAME.pool_flags.twitch_chat_blind_antes = is_first_boss and 0 or 1
        end

        if G.GAME.round_resets.blind_choices.Small == TW_BL.BLINDS.chat_blind then
            is_overriding = true
            G.GAME.round_resets.blind_choices.Small = get_new_boss_ref(...)
        end
        if G.GAME.round_resets.blind_choices.Big == TW_BL.BLINDS.chat_blind then
            is_overriding = true
            G.GAME.round_resets.blind_choices.Big = get_new_boss_ref(...)
        end

        if TW_BL.SETTINGS.current.channel_name == '' then
            -- No channel name - no point to start voting
            TW_BL.CHAT_COMMANDS.toggle_can_collect('vote', false, true)
            result = get_new_boss_ref(...)
        elseif TW_BL.__DEV_MODE and TW_BL.SETTINGS.current.forced_blind then
            -- Dev mode: set boss
            start_voting_process = true
            force_voting_process = true
            result = TW_BL.BLINDS.chat_blind
        elseif caused_by_boss_defeate or is_first_boss then
            if TW_BL.SETTINGS.current.blind_frequency == 1 then
                -- Disabled by settings
                TW_BL.CHAT_COMMANDS.toggle_can_collect('vote', false, true)
                result = get_new_boss_ref(...)
            elseif TW_BL.SETTINGS.current.blind_frequency == 2 then
                start_voting_process = true
                if is_first_boss or G.GAME.pool_flags.twitch_chat_blind_antes < 1 then
                    -- If in this ante blind was chat, return vanilla one
                    voting_ante_offset = 1
                    force_voting_process = is_first_boss
                    result = get_new_boss_ref(...)
                else
                    -- If previous was no chat, return chat
                    result = TW_BL.BLINDS.chat_blind
                end
            elseif TW_BL.SETTINGS.current.blind_frequency == 3 then
                -- Forced by settings
                start_voting_process = true
                force_voting_process = is_first_boss
                result = TW_BL.BLINDS.chat_blind
            else
                -- If I miss something
                result = get_new_boss_ref(...)
            end
        else
            if G.GAME.round_resets.blind_choices.Boss == TW_BL.BLINDS.chat_blind then
                -- Can't reroll chat
                result = TW_BL.BLINDS.chat_blind
            elseif G.GAME.pool_flags.twitch_chat_blind_antes == 0 then
                -- Can't reroll blind selected by chat
                -- Subject to change?
                result = G.GAME.round_resets.blind_choices.Boss
            else
                -- Reroll vanilla boss as usual
                result = get_new_boss_ref(...)
            end
        end

        if is_first_boss or caused_by_boss_defeate then
            -- Count how many antes ago was chat blind
            G.GAME.pool_flags.twitch_chat_blind_antes = (result == TW_BL.BLINDS.chat_blind and 0) or
                (G.GAME.pool_flags.twitch_chat_blind_antes + 1)
        end

        if start_voting_process and not is_overriding then
            if force_voting_process or not TW_BL.CHAT_COMMANDS.can_collect.vote then
                TW_BL.BLINDS.setup_new_twitch_blinds(TW_BL.SETTINGS.current.pool_type, voting_ante_offset)
                TW_BL.CHAT_COMMANDS.toggle_can_collect('vote', true, true)
                TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
                TW_BL.CHAT_COMMANDS.reset()
            end
        end

        if TW_BL.CHAT_COMMANDS.can_collect.vote then
            TW_BL.UI.set_panel('voting_process', true, true)
        else
            TW_BL.UI.remove_panel('voting_process', true)
        end

        return result
    end

    local select_blind_ref = G.FUNCS.select_blind
    function G.FUNCS.select_blind(...)
        -- Replace with blind selected by chat (or use first if no votes)
        if G.GAME.blind_on_deck and G.GAME.round_resets.blind_choices[G.GAME.blind_on_deck] and G.GAME.round_resets.blind_choices[G.GAME.blind_on_deck] == TW_BL.BLINDS.chat_blind then
            if G.GAME.blind_on_deck ~= 'Boss' then
                -- If somehow chat is in not boss position, then insert random boss here
                TW_BL.BLINDS.replace_blind(G.GAME.blind_on_deck, get_new_boss_ref())
                return
            end
            local blinds_to_choose = TW_BL.BLINDS.get_twitch_blinds_from_game(TW_BL.SETTINGS.current.pool_type, true)
            if not blinds_to_choose then return select_blind_ref(...) end
            local win_variant, win_score, win_percent = TW_BL.CHAT_COMMANDS.get_vote_winner()
            local picked_blind = (TW_BL.__DEV_MODE and TW_BL.SETTINGS.current.forced_blind and
                    TW_BL.BLINDS.loaded[TW_BL.SETTINGS.current.forced_blind]) or
                blinds_to_choose[tonumber(win_variant or '1')]
            TW_BL.BLINDS.replace_blind(G.GAME.blind_on_deck, picked_blind)
            TW_BL.CHAT_COMMANDS.toggle_can_collect('vote', false, true)
            TW_BL.UI.remove_panel('voting_process', true)
        else
            return select_blind_ref(...)
        end
    end
end

function TwitchBlinds:start_run()
    TW_BL.CHAT_COMMANDS.get_can_collect_from_game({
        vote = false,
        toggle = false,
        flip = false,
        roll = false,
    })
    TW_BL.CHAT_COMMANDS.get_single_use_from_game({
        vote = not TW_BL.__DEV_MODE,
        toggle = false,
        flip = false,
        roll = false,
    })

    TW_BL.CHAT_COMMANDS.reset()

    local variants = {}
    for i = 1, TW_BL.BLINDS.blinds_to_vote do
        table.insert(variants, tostring(i))
    end
    TW_BL.CHAT_COMMANDS.vote_variants = variants
    TW_BL.UI.set_panel_from_save()
end

function TwitchBlinds:main_menu()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('vote', false, false)
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, false)
    TW_BL.CHAT_COMMANDS.reset()
end