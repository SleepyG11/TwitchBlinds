local MIN_MULT = 2
local MAX_MULT = 8

local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("nope", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 24 },
	config = {
		tw_bl = { twitch_blind = true, ignore = true },
	},
	atlas = "twbl_blind_chips",
	boss_colour = G.C.SECONDARY_SET.Tarot,
})

function tw_blind:in_pool()
	-- Nope!
	return false
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("nope", true, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("nope", false, true)
	TW_BL.CHAT_COMMANDS.reset(false, "nope")
	TW_BL.UI.set_panel("game_top", "command_info_1", true, true, {
		command = "nope",
		status = "k_twbl_nope_ex",
		position = nil,
		text = "k_twbl_panel_toggle_nope",
	})
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("nope", false, true)
	TW_BL.CHAT_COMMANDS.toggle_single_use("nope", false, true)
	TW_BL.CHAT_COMMANDS.reset(false, "nope")
	TW_BL.UI.remove_panel("game_top", "command_info_1", true)
end

TW_BL.EVENTS.add_listener("twitch_command", TW_BL.BLINDS.get_key("nope"), function(command, username)
	if command ~= "nope" or G.GAME.blind.name ~= TW_BL.BLINDS.get_key("nope") then
		return
	end

	for i = 1, 3 do
		G.E_MANAGER:add_event(Event({
			blocking = false,
			trigger = "after",
			delay = math.random(5, 15) / 10 * i,
			func = function()
				attention_text({
					text = localize("k_twbl_nope_ex"),
					scale = math.random(15, 45) / 10,
					hold = math.random(25, 80) / 10,
					backdrop_colour = G.C.SECONDARY_SET.Tarot,
					align = "cmi",
					major = G.ROOM_ATTACH,
					offset = {
						x = math.random(-80, 80) / 10,
						y = math.random(-50, 50) / 10,
					},
				})
				play_sound("tarot2", 1, 0.4)
				return true
			end,
		}))
	end

	G.GAME.blind:wiggle()

	G.GAME.blind.mult = math.random(MIN_MULT * 100, MAX_MULT * 100) / 100
	G.GAME.blind.chips = to_big(get_blind_amount(G.GAME.round_resets.ante))
		* to_big(G.GAME.starting_params.ante_scaling)
		* to_big(G.GAME.blind.mult)
	G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
	G.GAME.blind:set_text()

	attention_text({
		text = localize("k_twbl_nope_ex"),
		scale = 1,
		hold = 1.5,
		backdrop_colour = G.C.SECONDARY_SET.Tarot,
		align = "cmi",
		major = G.GAME.blind,
		offset = {
			x = 0,
			y = 0,
		},
	})

	if G.STATE == G.STATES.SELECTING_HAND then
		if G.hand and G.hand.cards and #G.hand.cards > 0 then
			local card = G.hand.cards[math.random(1, #G.hand.cards)]
			card_eval_status_text(
				card,
				"extra",
				nil,
				nil,
				nil,
				{ message = localize("k_twbl_nope_ex"), colour = G.C.SECONDARY_SET.Tarot }
			)
		end

		if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
			local card = G.jokers.cards[math.random(1, #G.jokers.cards)]
			card_eval_status_text(
				card,
				"extra",
				nil,
				nil,
				nil,
				{ message = localize("k_twbl_nope_ex"), colour = G.C.SECONDARY_SET.Tarot }
			)
		end
	end
end)
