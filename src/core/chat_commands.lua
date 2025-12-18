TW_BL.chat_commands = {
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
		["grow"] = true,
	},
	commands_aliases = {
		["nope!"] = "nope",
	},

	-- Which commands can be processed
	can_collect = {},

	-- Counting how much each user used each command
	uses = {},
	-- Limit of how much each user can use each command
	max_uses = {},

	-- List of variants people can vote on
	vote_variants = {},
	-- Score of each voting variant
	vote_score = {},

	vote_buffer = {},
}

--

function TW_BL.chat_commands.can_use_command(command, username)
	if
		TW_BL.chat_commands.max_uses[command]
		and TW_BL.chat_commands.get_command_use(command, username) >= TW_BL.chat_commands.max_uses[command]
	then
		return false
	end
	return true
end
function TW_BL.chat_commands.process_new_provider_message(event)
	local iterator = string.gmatch(event.message, "%S+")

	local command = iterator()
	local all_words = { command }
	command = string.lower(command)
	command = TW_BL.chat_commands.commands_aliases[command] or command
	if not TW_BL.chat_commands.available_commands[command] then
		return
	end

	local words = {}
	for word in iterator do
		table.insert(words, word)
		table.insert(all_words, word)
	end

	local command_event = {
		provider = event.provider,
		command = command,
		username = event.username,
		message = event.message,
		words = words,
		all_words = all_words,
	}

	TW_BL.e_mitter.emit("new_provider_command", command_event)
end

--

--- @param command string
--- @param username string
--- @return integer | nil
function TW_BL.chat_commands.get_command_use(command, username)
	if not TW_BL.chat_commands.uses[command] then
		TW_BL.chat_commands.uses[command] = {}
	end
	return TW_BL.chat_commands.uses[command][username] or 0
end

--- @param command string
--- @param username string
--- @param uses integer | nil
function TW_BL.chat_commands.set_command_use(command, username, uses)
	if not TW_BL.chat_commands.uses[command] then
		TW_BL.chat_commands.uses[command] = {}
	end
	TW_BL.chat_commands.uses[command][username] = uses or 0
end

--- @param command string
--- @param username string
function TW_BL.chat_commands.increment_command_use(command, username)
	TW_BL.chat_commands.set_command_use(command, username, TW_BL.chat_commands.get_command_use(command, username) + 1)
end

--- @param command string
--- @param username string
function TW_BL.chat_commands.decrement_command_use(command, username)
	TW_BL.chat_commands.set_command_use(
		command,
		username,
		math.max(TW_BL.chat_commands.get_command_use(command, username) - 1, 0)
	)
end

--- @param command string
function TW_BL.chat_commands.reset_command_use(command)
	TW_BL.chat_commands.uses[command] = {}
end

function TW_BL.chat_commands.set_command_max_uses(command, amount)
	TW_BL.chat_commands.max_uses[command] = amount
end

--

--- @param id string
--- @param variant string
--- @return integer | nil
function TW_BL.chat_commands.get_vote_score(id, variant)
	if not TW_BL.chat_commands.vote_score[id] then
		TW_BL.chat_commands.vote_score[id] = {}
	end
	return TW_BL.chat_commands.vote_score[id][variant] or 0
end

--- @param id string
--- @param variant string
--- @param score integer | nil
function TW_BL.chat_commands.set_vote_score(id, variant, score)
	if not TW_BL.chat_commands.vote_score[id] then
		TW_BL.chat_commands.vote_score[id] = {}
	end
	TW_BL.chat_commands.vote_score[id][variant] = score or 0
	TW_BL.chat_commands.get_vote_status(id)
end

--- @param id string
--- @param variant string
function TW_BL.chat_commands.increment_vote_score(id, variant)
	TW_BL.chat_commands.set_vote_score(id, variant, TW_BL.chat_commands.get_vote_score(id, variant) + 1)
end

--- @param id string
--- @param variant string
function TW_BL.chat_commands.decrement_vote_score(id, variant)
	TW_BL.chat_commands.set_vote_score(id, variant, math.max(0, TW_BL.chat_commands.get_vote_score(id, variant) - 1))
end

--- @param id string
function TW_BL.chat_commands.reset_vote_score(id)
	TW_BL.chat_commands.vote_score[id] = {}
	TW_BL.chat_commands.get_vote_status(id)
end

--

--- @param id string
function TW_BL.chat_commands.get_vote_variants(id)
	if not TW_BL.chat_commands.vote_variants[id] then
		TW_BL.chat_commands.vote_variants[id] = {}
	end
	return TW_BL.chat_commands.vote_variants[id]
end

--- @param id string
--- @param variants string[]
function TW_BL.chat_commands.set_vote_variants(id, variants)
	TW_BL.chat_commands.vote_variants[id] = variants
	TW_BL.chat_commands.vote_buffer[id] = nil
	TW_BL.chat_commands.get_vote_status(id)
end

--- @param id string
--- @param variant string
function TW_BL.chat_commands.can_vote_for_variant(id, variant)
	for _, v in ipairs(TW_BL.chat_commands.get_vote_variants(id)) do
		if v == variant then
			return true
		end
	end
	return false
end

--- Get most voted variant and it's score
--- @param id string
--- @return { index: number, variant: string, score: number, percent: number, winner: boolean, fallback?: boolean } | nil
function TW_BL.chat_commands.get_vote_winner(id)
	local total_score = 0
	local win_score = 0
	local win_variant, win_index = nil, nil

	local fallback = true
	for index, v in ipairs(TW_BL.chat_commands.get_vote_variants(id)) do
		local variant_score = TW_BL.chat_commands.get_vote_score(id, v)
		if variant_score then
			total_score = total_score + variant_score
			-- If no winner, first win automatically
			if not win_variant then
				win_variant = v
				win_index = index
			end
			if variant_score > win_score then
				win_index = index
				win_variant = v or win_variant
				win_score = variant_score
				fallback = false
			end
		end
	end

	if not win_variant then
		return nil
	end

	local win_percent = total_score == 0 and 0 or (win_score / total_score * 100)

	return {
		index = win_index,
		variant = win_variant,
		score = win_score,
		percent = win_percent,
		winner = true,
		fallback = fallback,
	}
end

--- Get all variants score
--- @param id string
--- @return table<{ index: number, variant: string, score: number, percent: number, winner: boolean, fallback?: boolean }>
function TW_BL.chat_commands.get_vote_status(id)
	local total_score = 0
	local win_score = 0
	local win_variant = nil

	local vote_variants = TW_BL.chat_commands.get_vote_variants(id)
	local fallback = true

	for _, v in ipairs(vote_variants) do
		local variant_score = TW_BL.chat_commands.get_vote_score(id, v)
		if variant_score then
			total_score = total_score + variant_score
			-- If no winner, first win automatically
			if not win_variant then
				win_variant = v
			end
			if variant_score > win_score then
				win_score = variant_score
				win_variant = v or win_variant
				fallback = false
			end
		end
	end

	local result = {}

	for index, v in ipairs(vote_variants) do
		local variant_score = TW_BL.chat_commands.get_vote_score(id, v) or 0
		local variant_percent = total_score == 0 and 0 or (variant_score / total_score * 100)
		local variant_winner = v == win_variant
		local is_fallback = false
		if variant_winner then
			is_fallback = fallback
		end
		table.insert(result, {
			index = index,
			variant = v,
			score = variant_score,
			percent = variant_percent,
			winner = variant_winner,
			fallback = is_fallback,
		})
	end

	if not TW_BL.chat_commands.vote_buffer[id] then
		TW_BL.chat_commands.vote_buffer[id] = result
		return result
	else
		local buffered_result = TW_BL.chat_commands.vote_buffer[id]
		for index, item in ipairs(result) do
			TW_BL.utils.table_merge(buffered_result[index], item)
		end
		return buffered_result
	end
end

--

--- @param args? { reset_vote_score?: boolean | string, reset_command_use?: boolean | string }
function TW_BL.chat_commands.reset(args)
	args = args or {}
	if args.reset_vote_score then
		if args.reset_vote_score == true then
			TW_BL.chat_commands.vote_score = {}
		else
			TW_BL.chat_commands.reset_vote_score(args.reset_vote_score)
		end
	end
	if args.reset_command_use then
		if args.reset_command_use == true then
			TW_BL.chat_commands.uses = {}
		else
			TW_BL.chat_commands.reset_command_use(args.reset_command_use)
		end
	end
end
function TW_BL.chat_commands.save()
	local saveTable = {
		can_collect = TW_BL.chat_commands.can_collect,
		max_uses = TW_BL.chat_commands.max_uses,
		vote_variants = TW_BL.chat_commands.vote_variants,
	}
	return saveTable
end
function TW_BL.chat_commands.load(saveTable)
	saveTable = saveTable or {}
	TW_BL.chat_commands.can_collect = saveTable.can_collect or {}
	TW_BL.chat_commands.max_uses = saveTable.max_uses or {}
	TW_BL.chat_commands.vote_variants = saveTable.vote_variants or {}

	TW_BL.chat_commands.reset({
		reset_vote_score = true,
		reset_command_use = true,
	})
end

--

--- @param args { command?: string, command_max_uses?: number | false, reset_command_use?: boolean, vote_id?: string, set_vote_variants?: string[], reset_vote_score?: boolean }
function TW_BL.chat_commands.set(args)
	args = args or {}
	if args.command then
		if args.command_max_uses ~= nil then
			TW_BL.chat_commands.set_command_max_uses(args.command, args.command_max_uses or nil)
		end
		if args.reset_command_use then
			TW_BL.chat_commands.reset_command_use(args.command)
		end
	end
	if args.vote_id then
		if args.set_vote_variants then
			TW_BL.chat_commands.set_vote_variants(args.vote_id, args.set_vote_variants)
		end
		if args.reset_vote_score then
			TW_BL.chat_commands.reset_vote_score(args.vote_id)
		end
	end
end

--

--- @param args { command: string, can_use_command?: boolean, increment_command_use?: boolean, vote_id?: string, can_vote_for_variant?: boolean, increment_vote_score?: boolean }
function TW_BL.chat_commands.default_command_check(event, args)
	args = args or {}
	if not args.command then
		return false
	end
	if event.command ~= args.command then
		return false
	end
	if args.can_use_command and not TW_BL.chat_commands.can_use_command(args.command, event.username) then
		return false
	end
	if
		args.vote_id
		and args.can_vote_for_variant
		and not TW_BL.chat_commands.can_vote_for_variant(args.vote_id, event.words[1])
	then
		return false
	end
	if args.increment_command_use then
		TW_BL.chat_commands.increment_command_use(args.command, event.username)
	end
	if args.vote_id and args.increment_vote_score then
		TW_BL.chat_commands.increment_vote_score(args.vote_id, event.words[1])
	end
	return true
end

--

TW_BL.e_mitter.on("new_provider_message", TW_BL.chat_commands.process_new_provider_message)
TW_BL.e_mitter.on("run_delete", function()
	TW_BL.chat_commands.reset({
		reset_vote_score = true,
		reset_command_use = true,
	})
end)
