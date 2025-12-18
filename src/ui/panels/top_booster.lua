TW_BL.UI.top_booster_panel = {}

local VISIBLE_y = 2.75

function TW_BL.UI.top_booster_panel.show(definition_function, replace)
	local old_panel = TW_BL.UI.children.top_booster_panel
	if old_panel and not old_panel.REMOVED and not replace then
	else
		if old_panel and not old_panel.REMOVED then
			old_panel:remove()
		end
		local box = UIBox({
			definition = definition_function(),
			config = {
				major = G.jokers,
				align = "tmi",
				offset = {
					x = 1.225,
					y = VISIBLE_y,
				},
			},
		})
		TW_BL.UI.children.top_booster_panel = box
	end
end
function TW_BL.UI.top_booster_panel.hide()
	if TW_BL.UI.children.top_booster_panel then
		TW_BL.UI.children.top_booster_panel:remove()
		TW_BL.UI.children.top_booster_panel = nil
	end
end
