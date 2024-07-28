function twitch_blinds_init_chat_commands()
    local collector = TwitchCollector:new()
    local CHAT_COMMANDS = {
        available_commands = { 'vote', 'toggle', 'flip', 'roll' },
        collector = collector,
        socket = collector.socket,

        can_collect = {},
        users = {},
        single_use = {},

        vote_variants = {},
        vote_score = {},
    }

    --

    function CHAT_COMMANDS.process_message(username, message)
        local flip_match = message == 'flip'
        if flip_match then
            if not CHAT_COMMANDS.can_use_command('flip', username) then return end
            CHAT_COMMANDS.increment_command_use('flip', username)
            CHAT_COMMANDS.oncommand('flip', username)
            return
        end
        local roll_match = message == 'roll'
        if roll_match then
            if not CHAT_COMMANDS.can_use_command('roll', username) then return end
            CHAT_COMMANDS.increment_command_use('roll', username)
            CHAT_COMMANDS.oncommand('roll', username)
            return
        end
        local vote_match = message:match('vote (.+)')
        if vote_match then
            if not CHAT_COMMANDS.can_use_command('vote', username) then return end
            if not table_contains(CHAT_COMMANDS.vote_variants, vote_match) then return end
            CHAT_COMMANDS.increment_command_use('vote', username)
            CHAT_COMMANDS.vote_score[vote_match] = (CHAT_COMMANDS.vote_score[vote_match] or 0) + 1
            CHAT_COMMANDS.oncommand('vote', username, vote_match)
            return
        end
        local toggle_match = message:match('toggle (.+)')
        if toggle_match then
            if not CHAT_COMMANDS.can_use_command('toggle', username) then return end
            local value = tonumber(toggle_match)
            if not value then return end
            CHAT_COMMANDS.increment_command_use('toggle', username)
            CHAT_COMMANDS.oncommand('toggle', username, value)
            return
        end
    end

    --- Chech can user us this command
    --- @param command string Command
    --- @param username string Twitch username
    --- @return boolean
    function CHAT_COMMANDS.can_use_command(command, username)
        if not CHAT_COMMANDS.can_collect[command] then return false end
        if not CHAT_COMMANDS.users[command] then CHAT_COMMANDS.users[command] = {} end
        if CHAT_COMMANDS.single_use[command] and CHAT_COMMANDS.users[command][username] and CHAT_COMMANDS.users[command][username] > 0 then return false end
        return true
    end

    --- Increment command use count
    --- @param command string Command
    --- @param username string Twitch username
    function CHAT_COMMANDS.increment_command_use(command, username)
        if not CHAT_COMMANDS.users[command] then CHAT_COMMANDS.users[command] = {} end
        CHAT_COMMANDS.users[command][username] = (CHAT_COMMANDS.users[command][username] or 0) + 1
    end

    --- Decrement command use count
    --- @param command string Command
    --- @param username string Twitch username
    function CHAT_COMMANDS.decrement_command_use(command, username)
        if not CHAT_COMMANDS.users[command] then CHAT_COMMANDS.users[command] = {} end
        CHAT_COMMANDS.users[command][username] = math.max((CHAT_COMMANDS.users[command][username] or 1) - 1, 0)
    end

    --- Called every time when command is collected
    --- @param command string Command
    --- @param username string Twitch username
    --- @param ... any Arguments (specific for each command)
    function CHAT_COMMANDS.oncommand(command, username, ...) end

    --- Reset vote score and command uses
    function CHAT_COMMANDS.reset()
        CHAT_COMMANDS.vote_score = {}
        for k, v in pairs(CHAT_COMMANDS.users) do
            CHAT_COMMANDS.users[k] = {}
        end
    end

    function collector:onmessage(username, message)
        CHAT_COMMANDS.process_message(username, message)
    end

    --

    function CHAT_COMMANDS.toggle_can_collect(command, b, write)
        CHAT_COMMANDS.can_collect[command] = b
        if write and G.GAME and G.GAME.pool_flags then G.GAME.pool_flags['twitch_can_collect_' .. command] = b end
    end

    function CHAT_COMMANDS.toggle_single_use(command, b, write)
        CHAT_COMMANDS.single_use[command] = b
        if write and G.GAME and G.GAME.pool_flags then G.GAME.pool_flags['twitch_single_use_' .. command] = b end
    end

    function CHAT_COMMANDS.get_can_collect_from_game(default_values)
        for _, command in ipairs(CHAT_COMMANDS.available_commands) do
            local set_value = nil
            if default_values then set_value = default_values[command] end
            if G.GAME and G.GAME.pool_flags and G.GAME.pool_flags['twitch_can_collect_' .. command] ~= nil then
                set_value = G.GAME.pool_flags['twitch_can_collect_' .. command]
            end
            CHAT_COMMANDS.can_collect[command] = set_value or false
        end
    end

    function CHAT_COMMANDS.get_single_use_from_game(default_values)
        for _, command in ipairs(CHAT_COMMANDS.available_commands) do
            local set_value = nil
            if (default_values) then set_value = default_values[command] end
            if G.GAME and G.GAME.pool_flags and G.GAME.pool_flags['twitch_single_use_' .. command] ~= nil then
                set_value = G.GAME.pool_flags['twitch_single_use_' .. command]
            end
            CHAT_COMMANDS.single_use[command] = set_value or false
        end
    end

    --

    --- @return string|nil win_index Variant with highest score or `nil` if no votes collected
    --- @return number win_score Score of win variant
    --- @return number win_percent Percent of votes of win variant (0-100)
    function CHAT_COMMANDS.get_vote_winner()
        local total_score = 0
        local win_score = 0
        local win_variant = nil

        for _, v in ipairs(CHAT_COMMANDS.vote_variants) do
            local variant_score = CHAT_COMMANDS.vote_score[v]
            if variant_score then
                total_score = total_score + variant_score
                if variant_score > win_score then
                    win_score = variant_score
                    win_variant = v or win_variant
                end
            end
        end

        local win_percent = total_score == 0 and 0 or (win_score / total_score * 100)

        return win_variant, win_score, win_percent
    end

    --- @return { [string]: { score: number, percent: number, winner: boolean } }
    function CHAT_COMMANDS.get_vote_status()
        local total_score = 0
        local win_score = 0
        local win_variant = nil

        for _, v in ipairs(CHAT_COMMANDS.vote_variants) do
            local variant_score = CHAT_COMMANDS.vote_score[v]
            if variant_score then
                total_score = total_score + variant_score
                -- If no winner, first win automatically
                if not win_variant then win_variant = v end
                if variant_score > win_score then
                    win_score = variant_score
                    win_variant = v or win_variant
                end
            end
        end

        local result = {}

        for _, v in ipairs(CHAT_COMMANDS.vote_variants) do
            local variant_score = CHAT_COMMANDS.vote_score[v] or 0
            local variant_percent = total_score == 0 and 0 or (variant_score / total_score * 100)
            local variant_winner = v == win_variant
            result[v] = {
                score = variant_score,
                percent = variant_percent,
                winner = variant_winner
            }
        end

        return result
    end

    return CHAT_COMMANDS;
end
