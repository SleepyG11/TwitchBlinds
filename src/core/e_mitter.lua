TW_BL.e_mitter = setmetatable({}, {})
TW_BL.e_mitter.queues = {}

--- @param args? { before?: string, after?: string, key?: string, tags?: table<string, boolean>, start?: boolean }
function TW_BL.e_mitter.on(type, callback, args)
	args = args or {}
	if not TW_BL.e_mitter.queues[type] then
		TW_BL.e_mitter.queues[type] = {}
	end
	local result = {
		callback = callback or function() end,
		key = args.key,
		tags = args.tags or {},
	}
	if args.key then
		TW_BL.e_mitter.off(type, args.key)
	end
	if args.before then
		for index, item in ipairs(TW_BL.e_mitter.queues[type]) do
			if item.key and item.key == args.before then
				table.insert(TW_BL.e_mitter.queues[type], index, result)
				return
			end
		end
	elseif args.after then
		for index, item in ipairs(TW_BL.e_mitter.queues[type]) do
			if item.key and item.key == args.after then
				table.insert(TW_BL.e_mitter.queues[type], index + 1, result)
				return
			end
		end
	elseif args.start then
		table.insert(TW_BL.e_mitter.queues[type], 1, result)
		return
	else
		table.insert(TW_BL.e_mitter.queues[type], result)
	end
end
function TW_BL.e_mitter.emit(type, ...)
	if TW_BL.e_mitter.queues[type] then
		for _, item in ipairs(TW_BL.e_mitter.queues[type]) do
			if item.callback(...) then
				return true
			end
		end
	end
	return false
end
function TW_BL.e_mitter.off(type, key)
	if TW_BL.e_mitter.queues[type] then
		for index, item in ipairs(TW_BL.e_mitter.queues[type]) do
			if item.key and item.key == key then
				table.remove(TW_BL.e_mitter.queues[type], index)
				return true
			end
		end
	end
	return false
end
function TW_BL.e_mitter.off_tag(type, tag)
	if TW_BL.e_mitter.queues[type] then
		local new_queue = {}
		for _, item in ipairs(TW_BL.e_mitter.queues[type]) do
			if not item.tags[tag] then
				table.insert(new_queue, item)
			end
		end
		TW_BL.e_mitter.queues[type] = new_queue
	end
end
