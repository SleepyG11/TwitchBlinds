local buffer = {}
TW_BL.buffer = buffer

function TW_BL.buffered(key, func)
	if buffer[key] ~= nil then
		return buffer[key]
	end
	buffer[key] = func()
	return buffer[key]
end

TW_BL.e_mitter.on("update", function(dt)
	buffer = {}
	TW_BL.buffer = buffer
end)
