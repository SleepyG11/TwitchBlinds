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
		enabled = false,

		can_collect = {},
		users = {},
		max_uses = {},

		vote_variants = {},
		vote_score = {},
	}

	TW_BL.CHAT_COMMANDS = CHAT_COMMANDS

	local needs_reconnect = false
	local next_reconnect_timeout = 1
	local reconnect_timeout = 0

	---------------------------------------

	--- @param b boolean
	function CHAT_COMMANDS.set_enabled(b)
		CHAT_COMMANDS.enabled = b
	end

	--- @param username string
	--- @param message string
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
			TW_BL.EVENTS.emit("twitch_command", command, username, unpack(words))
		end
	end

	-- Command use
	---------------------------------------

	--- @param command string
	--- @param username string
	--- @return boolean
	function CHAT_COMMANDS.can_use_command(command, username)
		if not CHAT_COMMANDS.can_collect[command] then
			return false
		end
		if not CHAT_COMMANDS.users[command] then
			CHAT_COMMANDS.users[command] = {}
		end
		if TW_BL.__DEV_MODE then
			return true
		end
		if
			CHAT_COMMANDS.max_uses[command]
			and CHAT_COMMANDS.users[command][username]
			and CHAT_COMMANDS.users[command][username] >= CHAT_COMMANDS.max_uses[command]
		then
			return false
		end
		return true
	end

	--- @param command string
	--- @param username string
	function CHAT_COMMANDS.increment_command_use(command, username)
		if not CHAT_COMMANDS.users[command] then
			CHAT_COMMANDS.users[command] = {}
		end
		CHAT_COMMANDS.users[command][username] = (CHAT_COMMANDS.users[command][username] or 0) + 1
	end

	--- @param command string
	--- @param username string
	function CHAT_COMMANDS.decrement_command_use(command, username)
		if not CHAT_COMMANDS.users[command] then
			CHAT_COMMANDS.users[command] = {}
		end
		CHAT_COMMANDS.users[command][username] = math.max((CHAT_COMMANDS.users[command][username] or 1) - 1, 0)
	end

	-- Vote score
	---------------------------------------

	--- @param id string
	--- @param variant string
	--- @return integer | nil
	function CHAT_COMMANDS.get_vote_score(id, variant)
		if not CHAT_COMMANDS.vote_score[id] then
			CHAT_COMMANDS.vote_score[id] = {}
		end
		return CHAT_COMMANDS.vote_score[id][variant]
	end

	--- @param id string
	--- @param variant string
	--- @param score integer | nil
	function CHAT_COMMANDS.set_vote_score(id, variant, score)
		if not CHAT_COMMANDS.vote_score[id] then
			CHAT_COMMANDS.vote_score[id] = {}
		end
		CHAT_COMMANDS.vote_score[id][variant] = score
	end

	--- @param id string
	--- @param variant string
	function CHAT_COMMANDS.increment_vote_score(id, variant)
		CHAT_COMMANDS.set_vote_score(id, variant, (CHAT_COMMANDS.get_vote_score(id, variant) or 0) + 1)
	end

	--- @param id string
	--- @param variant string
	function CHAT_COMMANDS.decrement_vote_score(id, variant)
		CHAT_COMMANDS.set_vote_score(id, variant, math.max(0, (CHAT_COMMANDS.get_vote_score(id, variant) or 0) - 1))
	end

	-- Vote variants
	---------------------------------------

	function CHAT_COMMANDS.get_vote_variants(id)
		if not CHAT_COMMANDS.vote_variants[id] then
			CHAT_COMMANDS.vote_variants[id] = {}
		end
		return CHAT_COMMANDS.vote_variants[id]
	end

	--- @param id string
	--- @param variants string[]
	--- @param write boolean Save value in game object
	function CHAT_COMMANDS.set_vote_variants(id, variants, write)
		CHAT_COMMANDS.vote_variants[id] = variants
		if write and G.GAME then
			TW_BL.G.vote_variants = TW_BL.G.vote_variants or {}
			TW_BL.G.vote_variants[id] = variants
		end
	end

	--- @param id string
	--- @param variant string
	--- @return boolean
	function CHAT_COMMANDS.can_vote_for_variant(id, variant)
		return table_contains(CHAT_COMMANDS.get_vote_variants(id), variant)
	end

	function CHAT_COMMANDS.get_vote_variants_for_blinds()
		local variants = {}
		for i = 1, TW_BL.BLINDS.blinds_to_vote do
			table.insert(variants, tostring(i))
		end
		return variants
	end

	--- @param default_value string[] Value if data in game object not found
	function CHAT_COMMANDS.get_vote_variants_from_game(default_value)
		if G.GAME then
			CHAT_COMMANDS.vote_variants = TW_BL.G.vote_variants or default_value or {}
		end
	end

	-- Can collect
	---------------------------------------

	--- @param command string
	--- @param b boolean
	--- @param write boolean Save value in game object
	function CHAT_COMMANDS.toggle_can_collect(command, b, write)
		CHAT_COMMANDS.can_collect[command] = b
		if write and G.GAME then
			TW_BL.G["commands_can_collect_" .. command] = b
		end
	end

	--- Get can each command can be processed from game object
	--- @param default_values table<string, boolean> Values if data in game object not found
	function CHAT_COMMANDS.get_can_collect_from_game(default_values)
		for command, _ in pairs(CHAT_COMMANDS.available_commands) do
			local set_value = nil
			if default_values then
				set_value = default_values[command]
			end
			if G.GAME and TW_BL.G["commands_can_collect_" .. command] ~= nil then
				set_value = TW_BL.G["commands_can_collect_" .. command]
			end
			CHAT_COMMANDS.can_collect[command] = set_value or false
		end
	end

	-- Single use
	---------------------------------------

	--- @param command string
	--- @param count integer | nil
	--- @param write boolean Save value in game object
	function CHAT_COMMANDS.toggle_max_uses(command, count, write)
		CHAT_COMMANDS.max_uses[command] = count
		if write and G.GAME then
			TW_BL.G["commands_max_uses_" .. command] = count
		end
	end

	--- Get can each command can be used one time only from game object
	--- @param default_values table<string, integer | nil> Values if data in game object not found
	function CHAT_COMMANDS.get_max_uses_from_game(default_values)
		for command, _ in pairs(CHAT_COMMANDS.available_commands) do
			local set_value = nil
			if default_values then
				set_value = default_values[command]
			end
			if G.GAME and TW_BL.G["commands_max_uses_" .. command] ~= nil then
				set_value = TW_BL.G["commands_max_uses_" .. command]
			end
			CHAT_COMMANDS.max_uses[command] = set_value or nil
		end
	end

	-- Vote stats
	---------------------------------------

	--- Get most voted variant and it's score
	--- @param id string
	--- @return string|nil win_index Variant with highest score or `nil` if no votes collected
	--- @return number win_score Score of win variant
	--- @return number win_percent Percent of votes of win variant (0-100)
	function CHAT_COMMANDS.get_vote_winner(id)
		local total_score = 0
		local win_score = 0
		local win_variant = nil

		for _, v in ipairs(CHAT_COMMANDS.get_vote_variants(id)) do
			local variant_score = CHAT_COMMANDS.get_vote_score(id, v)
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

	--- Get all variants score
	--- @param id string
	--- @return { [string]: { score: number, percent: number, winner: boolean } }
	function CHAT_COMMANDS.get_vote_status(id)
		local total_score = 0
		local win_score = 0
		local win_variant = nil

		local vote_variants = CHAT_COMMANDS.get_vote_variants(id)

		for _, v in ipairs(vote_variants) do
			local variant_score = CHAT_COMMANDS.get_vote_score(id, v)
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

		for _, v in ipairs(vote_variants) do
			local variant_score = CHAT_COMMANDS.get_vote_score(id, v) or 0
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

	-- Other
	---------------------------------------

	--- Reset voting scores and commands uses
	--- @param reset_vote_score? string | boolean Reset all or specific voting score id
	--- @param command string? Command to reset
	function CHAT_COMMANDS.reset(reset_vote_score, command)
		if reset_vote_score then
			if reset_vote_score == true then
				CHAT_COMMANDS.vote_score = {}
			else
				CHAT_COMMANDS.vote_score[reset_vote_score] = {}
			end
			TW_BL.UI.update_panel("game_top", nil, false)
		end
		if command then
			CHAT_COMMANDS.users[command] = {}
		else
			for k, v in pairs(CHAT_COMMANDS.users) do
				CHAT_COMMANDS.users[k] = {}
			end
		end
	end

	--

	function collector:onmessage(username, message)
		if CHAT_COMMANDS.enabled then
			CHAT_COMMANDS.process_message(username, message)
		end
	end

	function collector:onnewconnectionstatus(status)
		if status == collector.STATUS.CONNECTED then
			next_reconnect_timeout = 1
		end
		TW_BL.EVENTS.emit("new_connection_status", status, collector.channel_name)
	end

	function collector:ondisconnect()
		-- Request reconnect
		needs_reconnect = true
		reconnect_timeout = next_reconnect_timeout
		next_reconnect_timeout = next_reconnect_timeout * 2
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
		CHAT_COMMANDS.collector:update(dt)
	end)

	return CHAT_COMMANDS
end
