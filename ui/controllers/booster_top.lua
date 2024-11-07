--- @type TWBLPanelController
local controller = TWBLPanelController("booster_top")
function controller:get_panel_UIBox(definition)
	return UIBox({
		definition = definition,
		config = {
			align = "cm",
			offset = { x = 0, y = -7.12 },
			major = G.hand,
			id = "twbl_panel",
		},
	})
end
function controller:after_set(panel, continue)
	G.E_MANAGER:add_event(Event({
		blocking = false,
		blockable = false,
		func = function()
			if G.twbl_chat_booster_area and G.twbl_chat_booster_area_position then
				local position = G.twbl_chat_booster_area_position
				if position == "bottom-full-width" then
					G.twbl_chat_booster_area:hard_set_T(nil, nil, panel.element.T.w, nil)
					G.twbl_chat_booster_area_UIBox = UIBox({
						definition = {
							n = G.UIT.O,
							config = {
								object = G.twbl_chat_booster_area,
							},
						},
						config = { align = "mb", offset = { x = 0, y = 0.1 }, major = panel.element },
					})
					G.twbl_chat_booster_area.states.visible = true
				elseif position == "left" then
					G.twbl_chat_booster_area_UIBox = UIBox({
						definition = {
							n = G.UIT.O,
							config = {
								object = G.twbl_chat_booster_area,
							},
						},
						config = { align = "cr", offset = { x = 0, y = 0 }, major = panel.element },
					})
					G.twbl_chat_booster_area.states.visible = true
				elseif position == "left-long" then
					panel.element.config.offset.x = -0.6
					G.twbl_chat_booster_area_UIBox = UIBox({
						definition = {
							n = G.UIT.O,
							config = {
								object = G.twbl_chat_booster_area,
							},
						},
						config = { align = "cr", offset = { x = -0.5, y = 0 }, major = panel.element },
					})
					G.twbl_chat_booster_area.states.visible = true
				end
			end
			continue()
			return true
		end,
	}))
end

TW_BL.UI.register_controller(controller)
