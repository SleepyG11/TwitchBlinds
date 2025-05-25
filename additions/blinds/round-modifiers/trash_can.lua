local tw_blind = TW_BL.BLINDS.create({
	key = "trash_can",
	dollars = 5,
	mult = 2,
	boss = { min = 4, max = 10 },
	config = {
		tw_bl = { twitch_blind = true, min = 3 },
	},
	boss_colour = HEX("dc6a10"),
})

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	return TW_BL.BLINDS.can_natural_appear(tw_blind)
end

function tw_blind:calculate(blind, context)
	if context.after then
		G.E_MANAGER:add_event(Event({
			func = function()
				G.GAME.blind:wiggle()
				play_sound("cancel", 0.8, 1.7)
				attention_text({
					scale = 1.4,
					text = localize("k_twbl_trash_ex"),
					hold = 2,
					align = "cm",
					offset = { x = 0, y = -2.7 },
					major = G.play,
				})
				return true
			end,
		}))
		SMODS.destroy_cards(context.scoring_hand)
		return {}
	end
end
