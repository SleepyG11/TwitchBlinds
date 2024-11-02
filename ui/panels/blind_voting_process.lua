--- @type TWBLPanel
local panel = TWBLPanel("blind_voting_process", {
	status = "k_twbl_vote_ex",
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
									id = "twbl_vote_1_blind_name",
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
									id = "twbl_vote_2_blind_name",
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
									id = "twbl_vote_3_blind_name",
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
	if not self.element then
		return
	end
	local blinds_to_vote = TW_BL.BLINDS.get_voting_blinds_from_game(TW_BL.SETTINGS.current.pool_type, false)
	if blinds_to_vote then
		local vote_status = TW_BL.CHAT_COMMANDS.get_vote_status("voting_blind")
		for i = 1, TW_BL.BLINDS.blinds_to_vote do
			if full_update then
				local boss_element = self.element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_blind_name")
				if boss_element then
					local is_mystic = TW_BL.SETTINGS.current.mystic_variants and i == TW_BL.BLINDS.blinds_to_vote
					if not is_mystic then
						boss_element.float = true
						boss_element.states.hover.can = true
						boss_element.states.collide.can = true
						boss_element.hover = function()
							boss_element.config.h_popup = create_UIBox_blind_popup(
								G.P_BLINDS[blinds_to_vote[i]],
								G.P_BLINDS[blinds_to_vote[i]].discovered
							)
							boss_element.config.h_popup_config =
								{ align = "mb", offset = { x = 0, y = 0.2 }, parent = boss_element }
							Node.hover(boss_element)
						end

						boss_element.config.text = blinds_to_vote[i]
								and localize({ type = "name_text", key = blinds_to_vote[i], set = "Blind" })
							or "-"
					else
						boss_element.float = false
						boss_element.states.hover.can = false
						boss_element.states.collide.can = false
						boss_element.hover = function()
							Node.hover(boss_element)
						end

						boss_element.config.text = "???"
					end
				end
			end
			local percent_element = self.element:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_percent")
			if percent_element then
				local variant_status = vote_status[tostring(i)]
				percent_element.config.text = math.floor(variant_status and variant_status.percent or 0) .. "%"
			end
		end
	end
	self.element:recalculate()
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
