function twbl_init_events()
	local EVENTS = {
		--- @type { [string]: { [string]: function } }
		_emitters = {},
	}

    TW_BL.EVENTS = EVENTS

    -- Add listener to event
    --- @param event string Event name
    --- @param key string Unique event key
    --- @param callback function Event handler
	function EVENTS.add_listener(event, key, callback)
		if not EVENTS._emitters[event] then
			EVENTS._emitters[event] = {}
		end
		assert(type(callback) == "function", "Listener callback must be a function")
		local replaced = EVENTS._emitters[event][key] and true or false
		EVENTS._emitters[event][key] = callback
		return replaced
	end

    -- Add listener from event
    --- @param event string Event name
    --- @param key string Unique event key
	function EVENTS.remove_listener(event, key)
		if not EVENTS._emitters[event] then
			EVENTS._emitters[event] = {}
		end
		local deleted = EVENTS._emitters[event][key] or nil
		EVENTS._emitters[event][key] = nil
		return deleted and true or false
	end

    -- Emit event
    --- @param event string Event name
    --- @param ... any[] Arguments to pass in handlers
	function EVENTS.emit(event, ...)
		if not EVENTS._emitters[event] then
			EVENTS._emitters[event] = {}
		end
		for k, callback in pairs(EVENTS._emitters[event]) do
			callback(...)
		end
	end

	return EVENTS
end
