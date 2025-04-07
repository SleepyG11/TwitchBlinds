-- Remake it in a way that chat can select smth space-themed (telescope + observatory, planet vouchers, some jokers, pack of planets, etc.)

local tw_blind = TW_BL.BLINDS.create({
	key = "moon",
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	config = {
		tw_bl = {
			twitch_blind = true,
			min = 3,
			-- tags = { "twbl_run_direction" },
		},
	},
	boss_colour = HEX("00d4d4"),
})

function tw_blind.config.tw_bl:in_pool()
	return not TW_BL.G.blind_moon_encountered and TW_BL.BLINDS.can_appear_in_voting(tw_blind)
end

function tw_blind:in_pool()
	-- Not suitable for default gameplay
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end

	TW_BL.G.blind_moon_encountered = true

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

	delay(0.5)

	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			G.twbl_force_speedfactor = 1

			-- Voucher to redeem
			local voucher_card = create_card("Voucher", G.play, false, nil, nil, nil, "v_planet_merchant", nil)
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

			talking_card:add_speech_bubble("twbl_blinds_moon_" .. math.random(1), nil, { quip = true })
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

					voucher_card:explode()

					G.E_MANAGER:add_event(Event({
						func = function()
							G.GAME.planet_rate = G.GAME.planet_rate / 2
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
