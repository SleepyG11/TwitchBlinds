local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("sparkle"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 6 },
	config = {
		tw_bl = {
			twitch_blind = true,
			min = 3,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("be35b0"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
		and (not G.GAME.used_vouchers["v_magic_trick"] or not G.GAME.used_vouchers["v_illusion"])
end

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
	if not G.GAME.used_vouchers["v_magic_trick"] then
		G.E_MANAGER:add_event(Event({
			func = function()
				local card = create_card("Voucher", G.play, false, nil, nil, nil, "v_magic_trick", nil)
				card.cost = 0
				G.play:emplace(card)
				card:redeem()
				G.E_MANAGER:add_event(Event({
					func = function()
						card:start_dissolve()
						return true
					end,
				}))
				return true
			end,
		}))
	end
	if not G.GAME.used_vouchers["v_illusion"] then
		G.E_MANAGER:add_event(Event({
			func = function()
				local card = create_card("Voucher", G.play, false, nil, nil, nil, "v_illusion", nil)
				card.cost = 0
				G.play:emplace(card)
				card:redeem()
				G.E_MANAGER:add_event(Event({
					func = function()
						card:start_dissolve()
						return true
					end,
				}))
				return true
			end,
		}))
	end
end
