local tw_blind = SMODS.Blind({
	key = TW_BL.BLINDS.register("sparkle", false),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 6 },
	config = {
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				return not G.GAME.used_vouchers["v_magic_trick"] or not G.GAME.used_vouchers["v_illusion"]
			end,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("be35b0"),
})

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	play_sound("card1")
	if not G.GAME.used_vouchers["v_magic_trick"] then
		G.GAME.used_vouchers["v_magic_trick"] = true
		Card:apply_to_run(G.P_CENTERS["v_magic_trick"])
	end
	if not G.GAME.used_vouchers["v_illusion"] then
		G.GAME.used_vouchers["v_illusion"] = true
		Card:apply_to_run(G.P_CENTERS["v_illusion"])
	end
end
