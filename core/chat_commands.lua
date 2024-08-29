function twbl_init_chat_commands()
	local collector = TwitchCollector:new()
	local CHAT_COMMANDS = {
		available_commands = {
			["vote"] = true,
			["toggle"] = true,
			["flip"] = true,
			["roll"] = true,
			["select"] = true,
			["pick"] = true,
			["target"] = true,
			["nope"] = true,
			["count"] = true,
		},
		commands_aliases = {
			["nope!"] = "nope",
		},

		collector = collector,
		socket = collector.socket,
		enabled = false,

		can_collect = {},
		users = {},
		single_use = {},

		vote_variants = {},
		vote_score = {},
	}

	local needs_reconnect = false
	local reconnect_timeout = 0

	--

	--- @param b boolean
	function CHAT_COMMANDS.set_enabled(b)
		CHAT_COMMANDS.enabled = b
	end

	function CHAT_COMMANDS.process_message(username, message)
		local iterator = string.gmatch(message, "%S+")

		local command = string.lower(iterator())
		command = CHAT_COMMANDS.commands_aliases[command] or command
		if not CHAT_COMMANDS.available_commands[command] then
			return
		end

		local words = {}
		for word in iterator do
			table.insert(words, word)
		end

		if CHAT_COMMANDS.can_use_command(command, username) then
			CHAT_COMMANDS.increment_command_use(command, username)
			TW_BL.EVENTS.emit("twitch_command", command, username, unpack(words))
		end
	end

	--- Chech can user us this command
	--- @param command string Command
	--- @param username string Twitch username
	--- @return boolean
	function CHAT_COMMANDS.can_use_command(command, username)
		if not CHAT_COMMANDS.can_collect[command] then
			return false
		end
		if not CHAT_COMMANDS.users[command] then
			CHAT_COMMANDS.users[command] = {}
		end
		if
			CHAT_COMMANDS.single_use[command]
			and CHAT_COMMANDS.users[command][username]
			and CHAT_COMMANDS.users[command][username] > 0
		then
			return false
		end
		return true
	end

	--- Increment command use count
	--- @param command string Command
	--- @param username string Twitch username
	function CHAT_COMMANDS.increment_command_use(command, username)
		if not CHAT_COMMANDS.users[command] then
			CHAT_COMMANDS.users[command] = {}
		end
		CHAT_COMMANDS.users[command][username] = (CHAT_COMMANDS.users[command][username] or 0) + 1
	end

	--- Decrement command use count
	--- @param command string Command
	--- @param username string Twitch username
	function CHAT_COMMANDS.decrement_command_use(command, username)
		if not CHAT_COMMANDS.users[command] then
			CHAT_COMMANDS.users[command] = {}
		end
		CHAT_COMMANDS.users[command][username] = math.max((CHAT_COMMANDS.users[command][username] or 1) - 1, 0)
	end

	function CHAT_COMMANDS.can_vote_for_variant(variant)
		return table_contains(CHAT_COMMANDS.vote_variants, variant)
	end

	function CHAT_COMMANDS.increment_vote_score(variant)
		CHAT_COMMANDS.vote_score[variant] = (CHAT_COMMANDS.vote_score[variant] or 0) + 1
	end

	function CHAT_COMMANDS.decrement_vote_score(variant)
		CHAT_COMMANDS.vote_score[variant] = math.max(0, (CHAT_COMMANDS.vote_score[variant] or 0) - 1)
	end

	--- Reset vote score and command uses
	function CHAT_COMMANDS.reset()
		CHAT_COMMANDS.vote_score = {}
		for k, v in pairs(CHAT_COMMANDS.users) do
			CHAT_COMMANDS.users[k] = {}
		end
	end

	--

	function CHAT_COMMANDS.toggle_can_collect(command, b, write)
		CHAT_COMMANDS.can_collect[command] = b
		if write and G.GAME and G.GAME.pool_flags then
			G.GAME.pool_flags["twbl_commands_can_collect_" .. command] = b
		end
	end

	function CHAT_COMMANDS.toggle_single_use(command, b, write)
		CHAT_COMMANDS.single_use[command] = b
		if write and G.GAME and G.GAME.pool_flags then
			G.GAME.pool_flags["twbl_commands_single_use_" .. command] = b
		end
	end

	function CHAT_COMMANDS.set_vote_variants(variants, write)
		CHAT_COMMANDS.vote_variants = variants
		if write and G.GAME and G.GAME.pool_flags then
			G.GAME.pool_flags.twbl_vote_variants = variants
		end
	end

	function CHAT_COMMANDS.get_can_collect_from_game(default_values)
		for command, _ in pairs(CHAT_COMMANDS.available_commands) do
			local set_value = nil
			if default_values then
				set_value = default_values[command]
			end
			if G.GAME and G.GAME.pool_flags and G.GAME.pool_flags["twbl_commands_can_collect_" .. command] ~= nil then
				set_value = G.GAME.pool_flags["twbl_commands_can_collect_" .. command]
			end
			CHAT_COMMANDS.can_collect[command] = set_value or false
		end
	end

	function CHAT_COMMANDS.get_single_use_from_game(default_values)
		for command, _ in pairs(CHAT_COMMANDS.available_commands) do
			local set_value = nil
			if default_values then
				set_value = default_values[command]
			end
			if G.GAME and G.GAME.pool_flags and G.GAME.pool_flags["twbl_commands_single_use_" .. command] ~= nil then
				set_value = G.GAME.pool_flags["twbl_commands_single_use_" .. command]
			end
			CHAT_COMMANDS.single_use[command] = set_value or false
		end
	end

	function CHAT_COMMANDS.get_vote_variants_from_game(default_value)
		if G.GAME and G.GAME.pool_flags then
			CHAT_COMMANDS.vote_variants = G.GAME.pool_flags.twbl_vote_variants or default_value
		end
	end

	function CHAT_COMMANDS.get_vote_variants_for_blinds()
		local variants = {}
		for i = 1, TW_BL.BLINDS.blinds_to_vote do
			table.insert(variants, tostring(i))
		end
		return variants
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
				if not win_variant then
					win_variant = v
				end
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
				winner = variant_winner,
			}
		end

		return result
	end

	--

	function collector:onmessage(username, message)
		if CHAT_COMMANDS.enabled then
			CHAT_COMMANDS.process_message(username, message)
		end
	end

	function collector:onnewconnectionstatus(status)
		TW_BL.EVENTS.emit("new_connection_status", status, collector.channel_name)
	end

	function collector:ondisconnect()
		-- Request reconnect
		needs_reconnect = true
		reconnect_timeout = 2
	end

	TW_BL.EVENTS.add_listener("game_update", "chat_commands_init", function(dt)
		if reconnect_timeout >= 0 then
			reconnect_timeout = reconnect_timeout - dt
		else
			if needs_reconnect then
				needs_reconnect = false
				self.CHAT_COMMANDS.collector:reconnect()
			end
		end
		CHAT_COMMANDS.collector:update()
	end)

	TW_BL.EVENTS.add_listener("twitch_command", "chat_commands_init", function(command, username, variant)
		if command == "vote" then
			if CHAT_COMMANDS.can_vote_for_variant(variant) then
				CHAT_COMMANDS.increment_vote_score(variant)
				TW_BL.UI.update_panel(nil, false)
				TW_BL.UI.create_panel_notify(nil, username)
			else
				CHAT_COMMANDS.decrement_command_use(command, username)
			end
		end
	end)

	return CHAT_COMMANDS
end
