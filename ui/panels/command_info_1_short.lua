--- @type TWBLPanel
local panel = TWBLPanel("command_info_1_short", {
	command = "",
	status = "k_twbl_interact_ex",
	position = "twbl_position_singular",
	text = "k_twbl_panel_toggle_DEFAULT",
})

function panel:get_definition()
	return {
		n = G.UIT.ROOT,
		config = { padding = 0.04, r = 0.3, colour = G.C.BLACK },
		nodes = {
			{
				n = G.UIT.R,
				config = {
					padding = 0.04,
				},
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm" },
						nodes = {
							{
								n = G.UIT.C,
								config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "toggle",
											scale = 0.25,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_toggle_command",
										},
									},
								},
							},
							{ n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
							{
								n = G.UIT.T,
								config = {
									text = "-",
									scale = 0.3,
									colour = G.C.UI.TEXT_LIGHT,
									shadow = false,
									id = "twbl_toggle_text",
								},
							},
							{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
						},
					},
				},
			},
		},
	}
end
function panel:update(full_update, args)
	local args_array, do_update = self:resolve_args(full_update, args)

	local element = panel.element
	local command_element = element:get_UIE_by_ID("twbl_toggle_command")
	if command_element then
		if args_array.position then
			command_element.config.text = args_array.command .. " <" .. localize(args_array.position) .. ">"
		else
			command_element.config.text = args_array.command
		end
	end
	local text_element = element:get_UIE_by_ID("twbl_toggle_text")
	if text_element then
		text_element.config.text = localize(args_array.text)
	end
	element:recalculate()
end
function panel:notify(message)
	if not self.element then
		return
	end
	attention_text({
		text = message,
		scale = 0.3,
		hold = 0.5,
		backdrop_colour = G.C.MONEY,
		align = "rc",
		major = self.element,
		offset = { x = 0.15, y = 0 },
	})
end

TW_BL.UI.register_panel(panel)
