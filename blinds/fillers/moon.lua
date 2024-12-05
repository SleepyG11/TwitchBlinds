local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("moon"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	config = {
		tw_bl = {
			twitch_blind = true,
			tags = { "twbl_run_direction" },
		},
	},
	pos = { x = 0, y = 7 },
	atlas = "twbl_blind_chips",
	boss_colour = HEX("00d4d4"),
}))

function tw_blind.config.tw_bl:in_pool()
	return TW_BL.BLINDS.can_appear_in_voting(tw_blind)
		and (not G.GAME.used_vouchers["v_planet_merchant"] or not G.GAME.used_vouchers["v_planet_tycoon"])
end

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	ease_background_colour_blind()

	if not G.GAME.used_vouchers["v_planet_merchant"] then
		local card = create_card("Voucher", G.play, false, nil, nil, nil, "v_planet_merchant", nil)
		card.cost = 0
		G.play:emplace(card)
	end
	if not G.GAME.used_vouchers["v_planet_tycoon"] then
		local card = create_card("Voucher", G.play, false, nil, nil, nil, "v_planet_tycoon", nil)
		card.cost = 0
		G.play:emplace(card)
	end

	for _, card in ipairs(G.play.cards) do
		card:start_materialize()
		card:redeem()
		G.E_MANAGER:add_event(Event({
			func = function()
				card:start_dissolve()
				return true
			end,
		}))
	end
end