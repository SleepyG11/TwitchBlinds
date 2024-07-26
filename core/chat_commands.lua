function twitch_blinds_init_chat_commands()
    local collector = TwitchCollector:new()
    local CHAT_COMMANDS = {
        available_commands = { 'vote', 'toggle' },
        collector = collector,
        socket = collector.socket,
    }

    function CHAT_COMMANDS.toggle_can_collect(command, b, write)
        CHAT_COMMANDS.collector.can_collect[command] = b
        if write and G.GAME and G.GAME.pool_flags then G.GAME.pool_flags['twitch_can_collect_' .. command] = b end
    end

    function CHAT_COMMANDS.toggle_single_use(command, b, write)
        CHAT_COMMANDS.collector.single_use[command] = b
        if write and G.GAME and G.GAME.pool_flags then G.GAME.pool_flags['twitch_single_use_' .. command] = b end
    end

    function CHAT_COMMANDS.get_can_collect_from_game(default_values)
        local game = G.GAME
        for _, command in ipairs(CHAT_COMMANDS.available_commands) do
            local set_value = nil
            if default_values then set_value = default_values[command] end
            if game and game.pool_flags and game.pool_flags['twitch_can_collect_' .. command] ~= nil then
                set_value = game.pool_flags['twitch_can_collect_' .. command]
            end
            CHAT_COMMANDS.collector.can_collect[command] = set_value or false
        end
    end

    function CHAT_COMMANDS.get_single_use_from_game(default_values)
        local game = G.GAME
        for _, command in ipairs(CHAT_COMMANDS.available_commands) do
            local set_value = nil
            if (default_values) then set_value = default_values[command] end
            if game and game.pool_flags and game.pool_flags['twitch_single_use_' .. command] ~= nil then
                set_value = game.pool_flags['twitch_single_use_' .. command]
            end
            CHAT_COMMANDS.collector.single_use[command] = set_value or false
        end
    end

    --- @return string|nil win_index Variant with highest score or `nil` if no votes collected
    --- @return number win_score Score of win variant
    --- @return number win_percent Percent of votes of win variant (0-100)
    function CHAT_COMMANDS.get_vote_winner()
        local total_score = 0
        local win_score = 0
        local win_variant = nil

        for _, v in ipairs(CHAT_COMMANDS.collector.vote_variants) do
            local variant_score = CHAT_COMMANDS.collector.vote_score[v]
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

        for _, v in ipairs(CHAT_COMMANDS.collector.vote_variants) do
            local variant_score = CHAT_COMMANDS.collector.vote_score[v]
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

        for _, v in ipairs(CHAT_COMMANDS.collector.vote_variants) do
            local variant_score = CHAT_COMMANDS.collector.vote_score[v] or 0
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
