local PANEL_VISIBLE_Y = -6.1
local PANEL_HIDDEN_Y = -9.1
local PANEL_ANIMATION_DELAY = 0.75

--- @type TWBLPanelController
local controller = TWBLPanelController("game_top")
function controller:get_panel_UIBox(definition)
	return UIBox({
		definition = definition,
		config = {
			align = "cmri",
			offset = { x = -0.2857, y = PANEL_HIDDEN_Y },
			major = G.ROOM_ATTACH,
			id = "twbl_panel",
		},
	})
end
function controller:before_remove(panel, continue)
	G.E_MANAGER:add_event(Event({
		trigger = "ease",
		blocking = false,
		blockable = false,
		ref_table = panel.element.config.offset,
		ref_value = "y",
		ease_to = PANEL_HIDDEN_Y,
		delay = PANEL_ANIMATION_DELAY,
		func = function(t)
			return t
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			continue()
			return true
		end,
	}))
end
function controller:after_set(panel, continue)
	G.E_MANAGER:add_event(Event({
		trigger = "ease",
		blocking = false,
		blockable = false,
		ref_table = panel.element.config.offset,
		ref_value = "y",
		ease_to = PANEL_VISIBLE_Y,
		delay = PANEL_ANIMATION_DELAY,
		func = function(t)
			return t
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			continue()
			return true
		end,
	}))
end

TW_BL.UI.register_controller(controller)
