--- @generic T
--- @generic S
--- @param target T
--- @param source S
--- @param ... any
--- @return T | S
function TW_BL.utils.table_merge(target, source, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { source, ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			if type(v) == "table" then
				target[k] = TW_BL.utils.table_merge(target[k] or {}, v)
			else
				target[k] = v
			end
		end
	end

	return target
end

function TW_BL.utils.table_shallow_copy(t)
	local res = {}
	if not t or type(t) ~= "table" then
		return res
	end
	for k, v in pairs(t) do
		res[k] = v
	end
	return res
end

function TW_BL.utils.table_filter(t, filter)
	local res = {}
	if not t or type(t) ~= "table" then
		return res
	end
	filter = filter or function()
		return false
	end
	for k, v in pairs(t) do
		if filter(v, k, t) then
			if type(k) == "number" then
				table.insert(res, v)
			else
				res[k] = v
			end
		end
	end
	return res
end
