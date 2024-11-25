local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("sparkle"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 6 },
	config = {
		tw_bl = {
			twitch_blind = true,
			tags = { "twbl_run_direction" },
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

	ease_background_colour_blind()

	if not G.GAME.used_vouchers["v_magic_trick"] then
		local card = create_card("Voucher", G.play, false, nil, nil, nil, "v_magic_trick", nil)
		card.cost = 0
		G.play:emplace(card)
	end
	if not G.GAME.used_vouchers["v_illusion"] then
		local card = create_card("Voucher", G.play, false, nil, nil, nil, "v_illusion", nil)
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

	delay(0.5)

	G.E_MANAGER:add_event(Event({
		func = function()
			G.twbl_force_speedfactor = 1

			-- Voucher to redeem
			local voucher_card = create_card("Voucher", G.play, false, nil, nil, nil, "v_magic_trick", nil)
			voucher_card.cost = 0
			G.play:emplace(voucher_card)
			voucher_card:start_materialize()

			-- Fake card
			local doc_card = create_card("Joker", G.play, false, nil, nil, nil, "j_ring_master", nil)
			doc_card.states.visible = false
			G.play:emplace(doc_card)

			-- Talking doc
			local talking_card = Card_Character({
				x = doc_card.T.x,
				y = doc_card.T.y,
				w = doc_card.T.w,
				h = doc_card.T.h,
				center = G.P_CENTERS.j_ring_master,
			})
			doc_card:remove()
			talking_card.children.particles:set_role({
				role_type = "Minor",
				xy_bond = "Strong",
				r_bond = "Strong",
				major = talking_card,
			})
			local pseudo_card = talking_card.children.card
			G.play:emplace(pseudo_card)

			talking_card:add_speech_bubble("twbl_blinds_sparkle_" .. math.random(1), nil, { quip = true })
			talking_card:say_stuff(3)

			delay(2)

			G.E_MANAGER:add_event(Event({
				func = function()
					G.twbl_force_speedfactor = nil

					talking_card:remove_speech_bubble()
					talking_card.children.particles:fade(0.2, 1)
					pseudo_card:start_dissolve()

					G.E_MANAGER:add_event(Event({
						func = function()
							talking_card:remove()
							return true
						end,
					}))

					voucher_card:redeem()

					G.E_MANAGER:add_event(Event({
						func = function()
							G.GAME.playing_card_rate = G.P_CENTERS.v_magic_trick.config.extra * 2
							voucher_card:start_dissolve()
							return true
						end,
					}))

					return true
				end,
			}))

			return true
		end,
	}))
end
