--- @type TWBLPanel
local panel = TWBLPanel("voting_process_3", {
	id = nil,
	command = "",
	status = "k_twbl_vote_ex",
	variants = { "", "", "" },
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
						config = { minw = 1.915, align = "c" },
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
						config = { minw = 4.25, align = "cm" },
						nodes = {
							{
								n = G.UIT.C,
								config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "vote 1",
											scale = 0.25,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_1_command",
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
									id = "twbl_vote_1_text",
								},
							},
							{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
							{
								n = G.UIT.T,
								config = {
									text = "0%",
									scale = 0.3,
									colour = G.C.UI.TEXT_LIGHT,
									shadow = false,
									id = "twbl_vote_1_percent",
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { minw = 4.25, align = "cm" },
						nodes = {
							{
								n = G.UIT.C,
								config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "vote 2",
											scale = 0.25,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_2_command",
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
									id = "twbl_vote_2_text",
								},
							},
							{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
							{
								n = G.UIT.T,
								config = {
									text = "0%",
									scale = 0.3,
									colour = G.C.UI.TEXT_LIGHT,
									shadow = false,
									id = "twbl_vote_2_percent",
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { minw = 4.25, align = "cm" },
						nodes = {
							{
								n = G.UIT.C,
								config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "vote 3",
											scale = 0.25,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = false,
											id = "twbl_vote_3_command",
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
									id = "twbl_vote_3_text",
								},
							},
							{ n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
							{
								n = G.UIT.T,
								config = {
									text = "0%",
									scale = 0.3,
									colour = G.C.UI.TEXT_LIGHT,
									shadow = false,
									id = "twbl_vote_3_percent",
								},
							},
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
	if args_array.id then
		local vote_status = TW_BL.CHAT_COMMANDS.get_vote_status(args_array.id)
		for i = 1, 3 do
			if full_update then
				local text_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_text")
				if text_element then
					text_element.config.text = localize(args_array.variants[i])
				end

				local command_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_command")
				if command_element then
					command_element.config.text = args_array.command .. " " .. tostring(i)
				end
			end
			local percent_element = element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_percent")
			if percent_element then
				local variant_status = vote_status[tostring(i)]
				percent_element.config.text = math.floor(variant_status and variant_status.percent or 0) .. "%"
			end
		end
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
