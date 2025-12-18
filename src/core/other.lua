local old_dissolve = Card.start_dissolve
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice, ...)
	if TW_BL.FLAGS.silent_card_dissolve then
		silent = true
	end
	return old_dissolve(self, dissolve_colours, silent, dissolve_time_fac, no_juice, ...)
end

local e_manager_add_event_ref = EventManager.add_event
function EventManager:add_event(event, queue, front, ...)
	if G.twbl_force_event_queue and not queue then
		queue = G.twbl_force_event_queue
	end
	return e_manager_add_event_ref(self, event, queue, front, ...)
end

local e_manager_clear_queue_ref = EventManager.clear_queue
function EventManager:clear_queue(queue, exception, ...)
	if G.twbl_force_event_queue then
		if not queue or exception == G.twbl_force_event_queue then
			G.twbl_force_event_queue = nil
			G.twbl_force_speedfactor = nil
		end
	end
	return e_manager_clear_queue_ref(self, queue, exception)
end
