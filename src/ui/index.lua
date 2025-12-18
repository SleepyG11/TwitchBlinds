TW_BL.UI = {
	children = {},
}

function TW_BL.UI.cleanup()
	for key, element in pairs(TW_BL.UI.children) do
		if element.remove then
			element:remove()
		end
	end
	TW_BL.UI.children = {}
end
function TW_BL.UI.notify(args)
	args = args or {}
	if args.target == "card" then
		local card = args.card
		if args.card and not args.card.REMOVED then
			TW_BL.FLAGS.card_eval_status_text_scale = args.scale
			TW_BL.FLAGS.card_eval_status_text_align = args.align
			TW_BL.FLAGS.card_eval_status_text_align_y_off = args.align_y_off
			card_eval_status_text(card, "extra", nil, nil, nil, {
				message = args.message,
				instant = true,
				colour = args.colour or G.C.ORANGE,
				no_juice = args.no_juice,
				delay = args.hold,
			})
			TW_BL.FLAGS.card_eval_status_text_scale = nil
			TW_BL.FLAGS.card_eval_status_text_align = nil
			TW_BL.FLAGS.card_eval_status_text_align_y_off = nil
		end
	elseif args.target == "panel" then
		local element = args.panel
		if type(element) == "string" then
			element = TW_BL.UI.children[element]
		end
		if element and not element.REMOVED then
			attention_text({
				text = args.message,
				scale = args.scale or 0.3,
				hold = args.hold or 0.5,
				backdrop_colour = args.colour or G.C.ORANGE,
				align = "rc",
				major = element,
				offset = { x = 0.15, y = 0 },
			})
			if args.with_sound then
				play_sound("paper1", math.random() * 0.2 + 1.1, 0.6)
			end
		end
	elseif args.target == "blind" then
		if G.GAME.blind then
			attention_text({
				text = args.message,
				scale = args.scale or 0.4,
				hold = args.hold or 0.5,
				backdrop_colour = args.colour or G.C.ORANGE,
				align = "cmi",
				major = G.GAME.blind,
				offset = {
					x = 0,
					y = 0,
				},
			})
			if args.with_sound then
				play_sound("paper1", math.random() * 0.2 + 1.1, 0.6)
			end
		end
	end
end

--

TW_BL.load_file("src/ui/voting.lua")

TW_BL.load_files({
	"top_screen.lua",
	"top_booster.lua",
}, "src/ui/panels/")

TW_BL.load_file("src/ui/config.lua")

--

TW_BL.current_mod.extra_tabs = function()
	return {
		{
			label = "Connections",
			tab_definition_function = TW_BL.UI.tab_connections_UIBox,
		},
		{
			label = "Config",
			tab_definition_function = TW_BL.UI.tab_config_UIBox,
		},
	}
end
