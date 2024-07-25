local nativefs = require("nativefs")

TwitchBlinds = Object:extend()
TW_BL = TwitchBlinds

assert(load(nativefs.read(SMODS.current_mod.path .. "core/blinds.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/chat_commands.lua")))()

local test__force_blind = nil
local test__channel_name = 'sleepyg11_'

function TwitchBlinds:init()
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

    -- Timeouts

    local needs_reconnect = false
    local reconnect_timeout = 0
    local needs_game_check = false
    local game_check_timeout = 0

    -- Attach socket events

    function self.CHAT_COMMANDS.collector:ondisconnect()
        -- Request reconnect
        needs_reconnect = true
        reconnect_timeout = 2;
    end

    function self.CHAT_COMMANDS.collector:onvote(username, variant)
    end

    function self.CHAT_COMMANDS.collector:ontoggle(username, index)
        TW_BL:on_toggle_trigger_blinds(username, index)
    end

    self.CHAT_COMMANDS.collector:connect(test__channel_name)

    -- Overriding

    local start_run_ref = G.FUNCS.start_run
    function G.FUNCS.start_run(arg1, arg2, arg3)
        start_run_ref(arg1, arg2, arg3)
        -- Without delay G.GAME.pool_flags not present
        game_check_timeout = 1
        needs_game_check = true
    end

    local main_menu_ref = G.main_menu
    function G.main_menu(arg1, arg2)
        main_menu_ref(arg1, arg2)

        self.CHAT_COMMANDS.toggle_can_collect('vote', false, false)
        self.CHAT_COMMANDS.toggle_can_collect('toggle', false, false)
        self.CHAT_COMMANDS.collector:reset()
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
            self.CHAT_COMMANDS.collector:update()
        end

        -- Read save
        if game_check_timeout >= 0 then
            game_check_timeout = game_check_timeout - dt
        else
            if needs_game_check then
                needs_game_check = false
                if G.GAME then
                    self.CHAT_COMMANDS.get_can_collect_from_game({
                        vote = false,
                        toggle = false,
                    })
                    self.CHAT_COMMANDS.get_single_use_from_game({
                        vote = false,
                        toggle = false,
                    })
                end
                self.CHAT_COMMANDS.collector:reset()
            end
        end

        TW_BL:on_update_trigger_blinds(dt)
    end

    local select_blind_ref = G.FUNCS.select_blind
    function G.FUNCS.select_blind(arg1, arg2)
        -- Replace with blind selected by chat (or use first if no votes)
        if G.GAME.blind_on_deck == 'Boss' and G.GAME.round_resets.blind_choices.Boss and G.GAME.round_resets.blind_choices.Boss == self.BLINDS.chat_blind then
            local blinds_to_choose = self.BLINDS.get_twitch_blinds_from_game(true)
            if not blinds_to_choose then return select_blind_ref(arg1, arg2) end
            local win_variant, win_score, win_percent = self.CHAT_COMMANDS.get_vote_result()
            local picked_blind = test__force_blind or blinds_to_choose[tonumber(win_variant or '1')]
            self.BLINDS.set_boss_blind(picked_blind)
            self.CHAT_COMMANDS.toggle_can_collect('vote', false, true)
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
                self:start_new_twitch_blinds_voting(false)
            end
            return self.BLINDS.chat_blind
        end

        if G.GAME.round_resets.blind_choices.Boss then
            if G.GAME.round_resets.blind_choices.Boss == self.BLINDS.chat_blind then
                -- Can't reroll chat
                return self.BLINDS.chat_blind
            end
            if string_starts(G.GAME.round_resets.blind_choices.Boss, 'bl_twbl_') then
                if caused_by_boss_defeate then
                    -- Not start voting if next boss is final, for now
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then self:start_new_twitch_blinds_voting(false) end
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
                    return self.BLINDS.chat_blind
                else
                    -- Not start voting if next boss is final, for now
                    if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then self:start_new_twitch_blinds_voting(false) end
                    -- Reroll vanilla boss as usual
                    return get_new_boss_ref(arg1, arg2)
                end
            end
        else
            -- Not start voting if next boss is final, for now
            if (G.GAME.round_resets.ante + 1) % 8 ~= 0 then self:start_new_twitch_blinds_voting(false) end
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
