function twbl_init_events()
	local EVENTS = {
		--- @type { [string]: { [string]: function } }
		_emitters = {},

		delay_dt = 0,
		delay_requested = false,
		delay_thresholds = {},
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

	function EVENTS.request_delay(time, threshold)
		if EVENTS.delay_requested then
			return false
		end
		time = time or 1
		time = time * ((TW_BL.SETTINGS.current.delay_for_chat or 1) - 1)
		if threshold and not EVENTS.delay_thresholds[threshold] then
			time = 0
		end
		if time == 0 then
			return false
		end
		EVENTS.delay_dt = time
		EVENTS.delay_requested = true
		stop_use()
		G.E_MANAGER:add_event(Event({
			func = function()
				return not EVENTS.delay_requested
			end,
		}))
		return true
	end

	function EVENTS.clear_delay()
		EVENTS.delay_dt = 0
		EVENTS.delay_requested = false
	end

	function EVENTS.set_delay_threshold(threshold, t)
		EVENTS.delay_thresholds[threshold] = t * ((TW_BL.SETTINGS.current.delay_for_chat or 1) - 1)
	end

	function EVENTS.process_dt(dt)
		if G.SETTINGS.paused then
			return
		end
		EVENTS.delay_dt = math.max(0, EVENTS.delay_dt - dt)
		for k, v in pairs(EVENTS.delay_thresholds) do
			local new_value = v - dt
			EVENTS.delay_thresholds[k] = new_value > 0 and new_value or nil
		end
		EVENTS.emit("game_update", dt)
		if EVENTS.delay_dt == 0 and EVENTS.delay_requested then
			EVENTS.delay_requested = false
		end
	end

	return EVENTS
end
