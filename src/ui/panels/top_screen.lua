TW_BL.UI.top_screen_panel = {}

local HIDDEN_y = -7.5
local VISIBLE_y = -0.615

function TW_BL.UI.top_screen_panel.show(definition_function, replace)
	local old_panel = TW_BL.UI.children.top_screen_panel
	if old_panel and not old_panel.REMOVED and not replace then
		old_panel.alignment.offset.y = VISIBLE_y
	else
		if old_panel and not old_panel.REMOVED then
			old_panel:remove()
		end
		local box = UIBox({
			definition = definition_function(),
			config = {
				major = G.jokers,
				align = "tli",
				offset = {
					x = 0,
					y = HIDDEN_y,
				},
			},
		})
		G.E_MANAGER:add_event(Event({
			blocking = false,
			blockable = false,
			force_pause = true,
			no_delete = true,
			func = function()
				box:set_role({ xy_bond = "Weak", major = G.jokers })
				box.alignment.offset.y = VISIBLE_y
				return true
			end,
		}))
		TW_BL.UI.children.top_screen_panel = box
	end
end
function TW_BL.UI.top_screen_panel.hide()
	if TW_BL.UI.children.top_screen_panel then
		local box = TW_BL.UI.children.top_screen_panel
		box:set_role({ xy_bond = "Weak", major = G.jokers })
		box.alignment.offset.y = HIDDEN_y
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.5,
			blocking = false,
			blockable = false,
			force_pause = true,
			no_delete = true,
			func = function()
				if box.alignment.offset.y == HIDDEN_y then
					box:remove()
					if TW_BL.UI.children.top_screen_panel == box then
						TW_BL.UI.children.top_screen_panel = nil
					end
				end
				return true
			end,
		}))
	end
end
