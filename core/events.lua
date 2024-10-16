function twbl_init_events()
	local EVENTS = {
		--- @type { [string]: { [string]: function } }
		_emitters = {},

		delay_dt = 0,
		delay_requested = false,
		delay_callback = nil,
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

	function EVENTS.request_delay(time, callback)
		if
			EVENTS.delay_requested
			or not TW_BL.SETTINGS.current.delay_for_chat
			or TW_BL.SETTINGS.current.delay_for_chat == 1
		then
			return false
		end
		time = time or 1
		if TW_BL.SETTINGS.current.delay_for_chat == 3 then
			time = time * 1.5
		end
		EVENTS.delay_dt = time
		EVENTS.delay_requested = true
		EVENTS.delay_callback = callback
		attention_text({
			scale = 1.0,
			text = "Waiting for chat...",
			hold = time,
			align = "cm",
			offset = { x = 0, y = 2 },
			major = G.play,
		})
		return true
	end

	function EVENTS.process_dt(dt)
		EVENTS.delay_dt = math.max(0, EVENTS.delay_dt - dt)
		EVENTS.emit("game_update", dt)
		if EVENTS.delay_dt > 0 and (not G.GAME.STOP_USE or G.GAME.STOP_USE == 0) then
			G.GAME.STOP_USE = 1
		end
		if EVENTS.delay_dt == 0 and EVENTS.delay_requested then
			if type(EVENTS.delay_callback) == "function" then
				EVENTS.delay_callback()
			end
			EVENTS.delay_callback = nil
			EVENTS.delay_requested = false
		end
	end

	return EVENTS
end
