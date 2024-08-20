local nativefs = require("nativefs")

local blinds_to_load = {
    'blank',
    'taxes',
    'vaporation',
    'trash_can',
    'banana',
    'moon',
    'sparkle',
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
    'pin',
    'greed',
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

        ATLAS = SMODS.Atlas {
            key = 'twbl_blind_chips',
            px = 34,
            py = 34,
            path = 'BlindChips.png',
            atlas_table = 'ANIMATION_ATLAS',
            frames = 21,
        }
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
        -- If not bosses in pool, return blank
        if not boss then return get_twitch_blind_key('blank') end
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

    --- Set blind
    --- @param blind_type 'Small' | 'Big' | 'Boss'
    --- @param blind_name string
    function BLINDS.replace_blind(blind_type, blind_name)
        local blind_type_lower = string.lower(blind_type)
        stop_use()
        G.CONTROLLER.locks.boss_reroll = true
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                play_sound('other1')
                G.blind_select_opts[blind_type_lower]:set_role({ xy_bond = 'Weak' })
                G.blind_select_opts[blind_type_lower].alignment.offset.y = 20
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = (function()
                local par = G.blind_select_opts[blind_type_lower].parent
                G.GAME.round_resets.blind_choices[blind_type] = blind_name
                G.blind_select_opts[blind_type_lower]:remove()
                G.blind_select_opts[blind_type_lower] = UIBox {
                    T = { par.T.x, 0, 0, 0, },
                    definition =
                    { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {
                        UIBox_dyn_container({ create_UIBox_blind_choice(blind_type) }, false, get_blind_main_colour(blind_type), mix_colours(G.C.BLACK, get_blind_main_colour(blind_type), 0.8))
                    } },
                    config = { align = "bmi",
                        offset = { x = 0, y = G.ROOM.T.y + 9 },
                        major = par,
                        xy_bond = 'Weak'
                    }
                }
                par.config.object = G.blind_select_opts[blind_type_lower]
                par.config.object:recalculate()
                G.blind_select_opts[blind_type_lower].parent = par
                G.blind_select_opts[blind_type_lower].alignment.offset.y = 0

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

            local ante_offset = 0
            if TW_BL.SETTINGS.current.blind_frequency == 2 then
                ante_offset = 1
            end

            if generate_if_missing then return BLINDS.setup_new_twitch_blinds(pool_type, ante_offset) end
        else
            return nil
        end
    end

    --- Get new blinds pool
    --- @param pool_type integer
    --- @param ante_offset integer
    --- @return string[]
    function BLINDS.get_blinds_pool(pool_type, ante_offset)
        ante_offset = ante_offset or 0
        local eligible_bosses = {}

        local current_ante = math.max(1, G.GAME.round_resets.ante)
        local target_ante = current_ante + ante_offset
        local final_boss = target_ante >= 2 and target_ante % G.GAME.win_ante == 0

        local include_twitch_blinds = false
        local include_not_twitch_blinds = false

        if pool_type == 1 then
            -- Only twitch blinds
            include_twitch_blinds = true
            -- TODO: create some twitch final blinds to fill pool
            include_not_twitch_blinds = final_boss
        elseif pool_type == 2 then
            -- All other blinds
            include_twitch_blinds = false
            include_not_twitch_blinds = true
        elseif pool_type == 3 then
            -- All blinds
            include_not_twitch_blinds = true
            include_twitch_blinds = true
        else
            -- If I miss something
            include_not_twitch_blinds = true
            include_twitch_blinds = true
        end

        for k, v in pairs(G.P_BLINDS) do
            local extra = (v.config and v.config.tw_bl) or {}
            local is_twitch_blind = extra.in_pool or false
            if not v.boss then
                -- Skip no boss blinds
            elseif extra.ignore then
                -- Can't be set to vote (i.e. very specific boss like The Clock from Cryptid)
            elseif is_twitch_blind and not include_twitch_blinds then
                -- Skip twitch blind if we don't need it
            elseif not is_twitch_blind and not include_not_twitch_blinds then
                -- Skip other blind if we don't need it
            else
                local is_correct_boss_type = (v.boss.showdown or false) == final_boss
                local can_appear = false
                if is_twitch_blind and is_correct_boss_type then
                    -- Add twitch blind if met range requirements
                    can_appear = ((extra.min or 0) <= target_ante) and
                        ((extra.max or 999) >= target_ante)
                elseif v.in_pool and (v.ignore_showdown_check or is_correct_boss_type) then
                    -- Evaluate Steamodded behaviour
                    -- I have no choice :(
                    G.GAME.round_resets.ante = target_ante
                    can_appear = v.in_pool(v) or false
                    G.GAME.round_resets.ante = current_ante
                elseif final_boss then
                    -- Add final boss blind
                    can_appear = is_correct_boss_type
                else
                    -- Add regular boss if met range requirements
                    can_appear = is_correct_boss_type and (v.boss.min <= target_ante and v.boss.max >= target_ante)
                end

                if can_appear then eligible_bosses[k] = true end
            end
        end

        for k, v in pairs(G.GAME.banned_keys) do
            if eligible_bosses[k] then eligible_bosses[k] = nil end
        end

        -- Prevent softlock
        eligible_bosses[BLINDS.chat_blind] = nil

        local result = {}
        for k, v in pairs(eligible_bosses) do
            table.insert(result, k)
        end

        return result
    end

    --- Generate new list of twitch blinds and save it
    --- @param pool_type integer Generate new list and save if not present
    --- @param ante_offset integer
    --- @return string[]|nil
    function BLINDS.setup_new_twitch_blinds(pool_type, ante_offset)
        local pool = BLINDS.get_blinds_pool(pool_type, ante_offset)
        local new_list = BLINDS.get_list_of_random_boss_blinds(pool, BLINDS.blinds_to_vote)
        local success = BLINDS.set_twitch_blinds_to_game(new_list)
        if success then return new_list end
        return nil
    end

    return BLINDS
end
