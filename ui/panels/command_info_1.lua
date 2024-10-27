--- @type TWBLPanel
local panel = TWBLPanel("command_info_1", {
	command = "",
	status = "k_twbl_interact_ex",
	position = "twbl_position_singular",
	text = "k_twbl_panel_toggle_DEFAULT",
})

function panel:localize_status(status)
	if status == TW_BL.CHAT_COMMANDS.collector.STATUS.CONNECTED then
		return localize(self.args.status)
	end
end
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
						config = { minw = 1.915, align = "c", id = "twbl_voting_status_container" },
						nodes = {
							{
								n = G.UIT.O,
								config = {
									id = "twbl_voting_status",
									object = DynaText({
										string = { "" },
										colours = { G.C.UI.TEXT_LIGHT },
										shadow = false,
										rotate = false,
										float = true,
										bump = true,
										scale = 0.35,
										spacing = 1,
										pop_in = 1,
									}),
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { minw = 4.25 * 3 + 0.1, align = "cm" },
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

-- local status_element = element:get_UIE_by_ID("twbl_voting_status_container")
-- if status_element then
--     status_element.float = true
--     status_element.states.hover.can = true
--     status_element.states.collide.can = true
--     status_element.hover = function()
--         status_element.config.h_popup = {
--             n = G.UIT.ROOT,
--             config = {
--                 align = "cm",
--                 padding = 0.05,
--                 colour = lighten(G.C.JOKER_GREY, 0.5),
--                 r = 0.1,
--                 emboss = 0.05,
--             },
--             nodes = {
--                 {
--                     n = G.UIT.R,
--                     config = {
--                         align = "cm",
--                         padding = 0.075,
--                         colour = G.C.BLACK,
--                         r = 0.1,
--                     },
--                     nodes = {
--                         {
--                             n = G.UIT.C,
--                             config = {
--                                 align = "cm",
--                                 -- padding = 0.15,
--                                 colour = G.C.WHITE,
--                                 r = 0.1,
--                                 emboss = 0.05,
--                             },
--                             nodes = {
--                                 {
--                                     n = G.UIT.R,
--                                     config = { align = "cm" },
--                                     nodes = {
--                                         {
--                                             n = G.UIT.T,
--                                             config = {
--                                                 text = "Type in chat, for example",
--                                                 colour = G.C.BLACK,
--                                                 scale = 0.3,
--                                             },
--                                         },
--                                     },
--                                 },
--                                 {
--                                     n = G.UIT.R,
--                                     config = { align = "cm" },
--                                     nodes = {
--                                         {
--                                             n = G.UIT.T,
--                                             config = {
--                                                 text = args_array.command .. " 2",
--                                                 scale = 0.25,
--                                                 colour = G.C.UI.TEXT_LIGHT,
--                                                 shadow = false,
--                                                 id = "twbl_toggle_command",
--                                             },
--                                         },
--                                         {
--                                             n = G.UIT.C,
--                                             config = {
--                                                 padding = 0.08,
--                                                 r = 0.3,
--                                                 align = "cm",
--                                                 colour = G.C.CHIPS,
--                                             },
--                                             nodes = {
--                                                 {
--                                                     n = G.UIT.T,
--                                                     config = {
--                                                         text = args_array.command .. " 2",
--                                                         scale = 0.25,
--                                                         colour = G.C.UI.TEXT_LIGHT,
--                                                         shadow = false,
--                                                         id = "twbl_toggle_command",
--                                                     },
--                                                 },
--                                             },
--                                         },
--                                     },
--                                 },
--                                 {
--                                     n = G.UIT.R,
--                                     config = { align = "cm" },
--                                     nodes = {
--                                         {
--                                             n = G.UIT.T,
--                                             config = {
--                                                 text = "to apply boss blind",
--                                                 colour = G.C.BLACK,
--                                                 scale = 0.3,
--                                             },
--                                         },
--                                     },
--                                 },
--                                 {
--                                     n = G.UIT.R,
--                                     config = { align = "cm", padding = 0.025 },
--                                     nodes = {
--                                         {
--                                             n = G.UIT.T,
--                                             config = {
--                                                 text = "effect on second card",
--                                                 colour = G.C.BLACK,
--                                                 scale = 0.3,
--                                             },
--                                         },
--                                     },
--                                 },
--                             },
--                         },
--                     },
--                 },
--             },
--         }
--         status_element.config.h_popup_config =
--             { align = "mb", offset = { x = 0, y = 0.2 }, parent = status_element }
--         Node.hover(status_element)
--     end
-- end
