TW_BL.config = setmetatable({}, {})
TW_BL.load_file("src/config/default_config.lua")

-- Save/load

TW_BL.config.save_event = nil

function TW_BL.config.save()
	if SMODS and SMODS.save_mod_config then
		TW_BL.current_mod.config = TW_BL.config.current
		SMODS.save_mod_config(TW_BL.current_mod)
	end
	TW_BL.e_mitter.emit("settings_save")
end
function TW_BL.config.load()
	if not TW_BL.current_mod.config.version then
		TW_BL.config.current = TW_BL.utils.table_merge({}, TW_BL.config.default)
		TW_BL.current_mod.config = TW_BL.config.current
		SMODS.save_mod_config(TW_BL.current_mod)
	else
		TW_BL.config.current = TW_BL.utils.table_merge({}, TW_BL.config.default, TW_BL.current_mod.config)
	end
	TW_BL.cc = TW_BL.config.current
end
function TW_BL.config.request_save(delay)
	if TW_BL.config.save_event and not TW_BL.config.save_event.complete then
		TW_BL.config.save_event.time = G.TIMERS[TW_BL.config.save_event.timer]
	else
		local event = Event({
			no_delete = true,
			blocking = false,
			blockable = false,
			timer = "REAL",
			trigger = "after",
			delay = delay or 1,
			func = function()
				TW_BL.config.save()
				return true
			end,
		})
		TW_BL.config.save_event = event
		G.E_MANAGER:add_event(event, "other", true)
	end
end

TW_BL.config.load()
