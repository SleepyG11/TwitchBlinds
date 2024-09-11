-- Not Started

-- function twitch_cursed_boosters_setup_shop()
-- 	-- TOOO: apply tags
-- 	local arcana_pack = "p_arcana_mega_" .. math.random(1, 2)

-- 	for i, k in ipairs({ arcana_pack, arcana_pack }) do
-- 		local card = Card(
-- 			G.shop_booster.T.x + G.shop_booster.T.w / 2,
-- 			G.shop_booster.T.y,
-- 			G.CARD_W * 1.27,
-- 			G.CARD_H * 1.27,
-- 			G.P_CARDS.empty,
-- 			G.P_CENTERS[k],
-- 			{ bypass_discovery_center = true, bypass_discovery_ui = true }
-- 		)
-- 		create_shop_card_ui(card, "Booster", G.shop_booster)
-- 		card.ability.twbl_chat_booster = true
-- 		card.ability.booster_pos = i
-- 		card:start_materialize()
-- 		G.shop_booster:emplace(card)
-- 	end
-- end

-- TW_BL.G.cursed_boosters = true
