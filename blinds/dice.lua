-- Too boring

local LOSE_ODDS = 6

local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("dice", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	config = {
		extra = { odds = LOSE_ODDS },
		tw_bl = { twitch_blind = true, min = 2 },
	},
	vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), LOSE_ODDS },
	pos = { x = 0, y = 18 },
	atlas = "twbl_blind_chips",
	boss_colour = HEX("00d400"),
})

function tw_blind:in_pool()
	-- Twitch interaction required
	return false
end

function tw_blind:set_blind()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("roll", true, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("roll", 1, true)
	TW_BL.CHAT_COMMANDS.reset(false, "roll")
end

function tw_blind:defeat()
	TW_BL.CHAT_COMMANDS.toggle_can_collect("roll", false, true)
	TW_BL.CHAT_COMMANDS.toggle_max_uses("roll", nil, true)
	TW_BL.CHAT_COMMANDS.reset(false, "roll")
end

TW_BL.EVENTS.add_listener("twitch_command", TW_BL.BLINDS.get_key("dice"), function(command, username)
	if command ~= "roll" then
		return
	end
	if G.GAME.blind.name ~= TW_BL.BLINDS.get_key("dice") then
		return
	end
	local color = G.C.MONEY
	if
		pseudorandom(pseudoseed("twbl_dice"))
		< G.GAME.probabilities.normal / G.GAME.blind.config.blind.config.extra.odds
	then
		G.GAME.blind:wiggle()
		ease_dollars(-6, false)
		color = G.C.MULT
	else
		ease_dollars(1, false)
	end
	local money_ui = G.HUD:get_UIE_by_ID("dollar_text_UI")
	if money_ui then
		attention_text({
			text = username,
			scale = 0.4,
			hold = 0.5,
			backdrop_colour = color,
			align = "tm",
			major = money_ui,
			offset = { x = 0, y = -0.15 },
		})
	end
end)
