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
	if G.twbl_chat_booster_cards then
		G.twbl_chat_booster_cards_UIBox = UIBox({
			definition = {
				n = G.UIT.O,
				config = {
					object = G.twbl_chat_booster_cards,
				},
			},
			config = { align = "cr", offset = { x = 0, y = 0 }, major = panel.element },
		})
		G.twbl_chat_booster_cards.states.visible = true
	elseif G.twbl_chat_booster_planets then
		G.twbl_chat_booster_planets:hard_set_T(nil, nil, panel.element.T.w, nil)
		G.twbl_chat_booster_planets_UIBox = UIBox({
			definition = {
				n = G.UIT.O,
				config = {
					object = G.twbl_chat_booster_planets,
				},
			},
			config = { align = "mb", offset = { x = 0, y = 0.1 }, major = panel.element },
		})
		G.twbl_chat_booster_planets.states.visible = true
	end

	continue()
end

TW_BL.UI.register_controller(controller)
