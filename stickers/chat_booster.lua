local BOOSTERS_TO_APPLY = {
	["Spectral"] = true,
	["Arcana"] = true,
	-- ["Celestial"] = true,
	["Standard"] = true,
}
local STICKER_RATE = {
	["Spectral"] = 0.5,
	["Arcana"] = 0.5,
	["Celestial"] = 0.333,
	["Standard"] = 0.5,
}

local BANNED_CONSUMEABLES = {
	["c_ankh"] = true,
	["c_hex"] = true,
}

local tw_sticker = TW_BL.STICKERS.register(SMODS.Sticker({
	atlas = "twbl_stickers",
	pos = { x = 0, y = 0 },
	badge_colour = HEX("8e15ad"),
	config = {},
	rate = 0,
	key = TW_BL.STICKERS.get_raw_key("chat_booster"),
	discovered = true,
}))

-- Implementation in lovely/stickers_chat_booster.toml

--

function tw_sticker:should_apply(card, center, area, bypass_roll)
	return TW_BL.SETTINGS.current.chat_booster_sticker_appearance > 1
		and card.ability.set == "Booster"
		and BOOSTERS_TO_APPLY[center.kind]
		and (
			G.TWBL_BOOSTER_FROM_TAG
			or TW_BL.SETTINGS.current.chat_booster_sticker_appearance == 3
			or (
				TW_BL.SETTINGS.current.chat_booster_sticker_appearance == 2
				and STICKER_RATE[center.kind] >= pseudorandom(pseudoseed("twbl_sticker_chat_booster_natural"))
			)
		)
end
function tw_sticker:in_pool()
	-- Twitch interaction required
	return false
end
function tw_sticker:__naturally_apply(card, center, area, bypass_roll)
	if tw_sticker:should_apply(card, center, area or card.area, bypass_roll) then
		tw_sticker:apply(card, true)
	end
end

--

function tw_sticker:__is_valid_consumeable(kind, mode, card)
	if card.config.hidden then
		return false
	end
	if G.GAME.round_resets.ante > 2 and BANNED_CONSUMEABLES[card.config.center.key] then
		return false
	end
	if mode == "single" then
		local min_select = card.config.center.config.min_highlighted or 0
		local max_select = card.config.center.config.max_highlighted or 0
		if card.ability and card.ability.name == "Aura" then
			max_select = 1
			min_select = 1
		end
		if (min_select > 0 or max_select > 0) and G.hand.config.card_limit >= min_select then
			return true
		else
			return false
		end
	end
	return true
end
-- function tw_sticker:__get_pool(kind, mode)
-- 	if kind == "Celestial" then
-- 		return result_pool
-- 	elseif kind == "Arcana" or kind == "Spectral" then
-- 		local pools = {
-- 			["Arcana"] = G.P_CENTER_POOLS.Tarot,
-- 			["Spectral"] = G.P_CENTER_POOLS.Spectral,
-- 		}
-- 		local pool_to_copy = pools[kind]
-- 		local result_pool = {}

-- 		if mode == "single" then
-- 			for k, v in pairs(pool_to_copy) do
-- 				local min_select = v.config.min_highlighted or 0
-- 				local max_select = v.config.max_highlighted or 0
-- 				if
-- 					(min_select > 0 or max_select > 0)
-- 					and G.hand.config.card_limit >= min_select
-- 					and not v.config.hidden
-- 				then
-- 					result_pool[k] = v
-- 				end
-- 			end
-- 		elseif mode == "multiple" then
-- 			for k, v in pairs(pool_to_copy) do
-- 				if not v.config.hidden then
-- 					result_pool[k] = v
-- 				end
-- 			end
-- 			if G.GAME.round_resets.ante < 3 then
-- 				result_pool["c_hex"] = nil
-- 				result_pool["c_ankh"] = nil
-- 			end
-- 		end
-- 		return result_pool
-- 	end
-- 	return {}
-- end
function tw_sticker:__sort_voting_cards(cards)
	local copy = {}
	for _, card in ipairs(cards) do
		if card.ability then
			if not card.ability.twbl_sticker_chat_booster_pseudo then
				card.ability.twbl_sticker_chat_booster_pseudo =
					pseudorandom(pseudoseed("twbl_chat_booster_card_pseudo"))
			end
			table.insert(copy, card)
		end
	end
	table.sort(copy, function(a, b)
		local target_diff = (a.ability.twbl_state_target_score or 0) - (b.ability.twbl_state_target_score or 0)
		if target_diff == 0 then
			return (a.ability.twbl_sticker_chat_booster_pseudo or 0) > (b.ability.twbl_sticker_chat_booster_pseudo or 0)
		end
		return target_diff > 0
	end)
	return copy
end
function tw_sticker:__highlight_targets(target_area, consumeable)
	local card = consumeable
	if not (target_area and TW_BL.G.state_sticker_chat_booster and card.ability and card.ability.consumeable) then
		return false
	end

	local min_select = card.ability.consumeable.min_highlighted or 0
	local max_select = card.ability.consumeable.max_highlighted or 0
	local need_to_select = (min_select > 0 or max_select > 0) and #target_area.cards >= min_select

	target_area:unhighlight_all()
	if need_to_select then
		local sorted_cards = tw_sticker:__sort_voting_cards(target_area.cards)
		local result_amount_to_select = math.min(
			#target_area.cards,
			(card.ability and card.ability.name == "Aura" and 1)
				or (card.ability.consumeable.max_highlighted or card.ability.consumeable.min_highlighted)
		)

		for i = 1, result_amount_to_select do
			target_area:add_to_highlighted(sorted_cards[i])
		end
	end
	return true
end
function tw_sticker:__emplace_cards(kind, mode)
	local area = G.twbl_chat_booster_area
	if #area.cards > 0 then
		return
	end
	if kind == "Spectral" or kind == "Arcana" then
		local amount = 1
		if mode == "multiple" then
			amount = 4
		end
		for i = 1, amount do
			local card_pool = "Tarot"
			if pseudorandom(pseudoseed("twbl_chat_booster_card_pool")) > 0.85 then
				card_pool = "Spectral"
			end
			local card = create_card(card_pool, area, nil, nil, true)
			local anti_softlock = 30
			while anti_softlock > 0 and not tw_sticker:__is_valid_consumeable(kind, mode, card) do
				anti_softlock = anti_softlock - 1
				area:remove_card(card)
				card:remove()
				card = create_card(card_pool, area, nil, nil, true)
			end
			card:hard_set_T(nil, nil, G.CARD_W / 2, G.CARD_H / 2)
			area:emplace(card)
		end
	elseif kind == "Standard" then
		for i = 1, 5 do
			local center = SMODS.poll_enhancement({
				guaranteed = true,
			})
			center = G.P_CENTERS[center]
			local edition_rate = 6
			local edition = poll_edition("twbl_standard_edition" .. G.GAME.round_resets.ante, edition_rate, true)

			local front = pseudorandom_element(G.P_CARDS, pseudoseed("twbl_frontsta" .. G.GAME.round_resets.ante))
			local card = Card(area.T.x + area.T.w / 2, area.T.y, G.CARD_W / 2, G.CARD_H / 2, front, center, {
				bypass_discovery_center = false,
				bypass_discovery_ui = false,
				discover = false,
				bypass_back = G.GAME.selected_back.pos,
			})

			card:set_edition(edition)
			local seal = SMODS.poll_seal({
				mod = 6.66,
			})
			if seal then
				card:set_seal(seal)
			end
			area:emplace(card)
		end
	elseif kind == "Celestial" then
		local vanilla_planets = {
			"c_mercury",
			"c_venus",
			"c_earth",
			"c_mars",
			"c_jupiter",
			"c_saturn",
			"c_uranus",
			"c_neptune",
			"c_pluto",
			"c_planet_x",
			"c_ceres",
			"c_eris",
		}
		local pool = {}
		for _, k in ipairs(vanilla_planets) do
			local center = G.P_CENTERS[k]
			if center and center.config and center.config.hand_type then
				if not (center.config.softlock and G.GAME.hands[center.config.hand_type].played <= 0) then
					result_pool[k] = center
				end
			end
		end

		for i = 1, 5 do
			local center = pseudorandom_element(pool, pseudoseed("twbl_sticker_chat_booster_planet"))

			-- Remove the planet from the pool
			for k, planet in pairs(pool) do
				if planet == center then
					pool[k] = nil
					break
				end
			end

			center = table_copy(center)

			center.use = function(self, check, _, copier)
				local hand_type = check.ability.consumeable.hand_type
				if not hand_type then
					return false
				end

				-- Do level down to Level 0!
				if G.GAME.hands[hand_type].level <= 0 then
					return false
				end

				update_hand_text({ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 }, {
					handname = localize(hand_type, "poker_hands"),
					chips = G.GAME.hands[hand_type].chips,
					mult = G.GAME.hands[hand_type].mult,
					level = G.GAME.hands[hand_type].level,
				})
				level_up_hand(check, hand_type, nil, -1)
				update_hand_text(
					{ sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
					{ mult = 0, chips = 0, handname = "", level = "" }
				)
			end

			local chat_card = Card(
				area.T.x + area.T.w / 2 + ((i - 1) * G.CARD_W / 2),
				area.T.y,
				G.CARD_W / 2,
				G.CARD_H / 2,
				nil,
				center,
				{
					bypass_discovery_center = true,
					bypass_discovery_ui = true,
					discover = false,
					bypass_back = G.GAME.selected_back.pos,
				}
			)
			area:emplace(chat_card)
		end
	end
end

--

function tw_sticker:__use()
	TW_BL.G.state_sticker_chat_booster.use = nil

	-- If we skipping
	if G.GAME.pack_choices then
		G.GAME.pack_choices = 0
	end

	local kind = TW_BL.G.state_sticker_chat_booster.kind
	local mode = TW_BL.G.state_sticker_chat_booster.mode

	if kind == "Celestial" then
		TW_BL.EVENTS.request_delay(5, "chat_booster")
		G.E_MANAGER:add_event(Event({
			func = function()
				local planet = tw_sticker:__sort_voting_cards(G.twbl_chat_booster_area.cards)[1]
				if planet then
					G.FUNCS.use_card({
						config = {
							ref_table = planet,
						},
					})
					return true
				end
				return false
			end,
		}))
		return true
	elseif kind == "Arcana" or kind == "Spectral" then
		TW_BL.EVENTS.request_delay(5, "chat_booster")
		G.E_MANAGER:add_event(Event({
			func = function()
				local card_to_use = tw_sticker:__sort_voting_cards(G.twbl_chat_booster_area.cards)[1]
				if card_to_use and tw_sticker:__highlight_targets(G.hand, card_to_use) then
					G.FUNCS.use_card({
						config = {
							ref_table = card_to_use,
						},
					})
					return true
				end
				return false
			end,
		}))
		return true
	elseif kind == "Standard" then
		TW_BL.EVENTS.request_delay(5, "chat_booster")
		G.E_MANAGER:add_event(Event({
			func = function()
				local card = tw_sticker:__sort_voting_cards(G.twbl_chat_booster_area.cards)[1]
				if card then
					card:hard_set_T(nil, nil, G.CARD_W, G.CARD_H)
					card.children.center.scale_mag =
						math.min(card.children.center.atlas.px / G.CARD_W, card.children.center.atlas.py / G.CARD_H)
					G.FUNCS.use_card({
						config = {
							ref_table = card,
						},
					})
					return true
				end
				return false
			end,
		}))
		return true
	else
		return false
	end
end
function tw_sticker:__on_booster_open(card)
	local center = card.config.center
	local kind = center.kind

	TW_BL.G.state_sticker_chat_booster = {
		kind = kind,
		use = true,
		mode = "single",
	}

	if kind == "Spectral" or kind == "Arcana" then
		local mode = pseudorandom_element({ "single", "multiple" }, pseudoseed("twbl_chat_booster_mode"))
		TW_BL.G.state_sticker_chat_booster.mode = mode

		if mode == "single" then
			G.twbl_chat_booster_area =
				CardArea(0, 0, G.CARD_W / 2, G.CARD_H / 2, { card_limit = 1, type = "title_2", highlight_limit = 0 })
			G.twbl_chat_booster_area_position = "left"
			tw_sticker:__emplace_cards(kind, mode)
			G.twbl_chat_booster_area.states.visible = false

			TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
			TW_BL.CHAT_COMMANDS.toggle_max_uses("target", 1, true)
			TW_BL.CHAT_COMMANDS.reset(false, "target")
			TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
				command = "target",
				position = "twbl_position_Card_singular",
				text = "k_twbl_panel_toggle_chat_booster_consumeable_single",
			})
			TW_BL.EVENTS.set_delay_threshold("chat_booster", 5)
		elseif mode == "multiple" then
			G.twbl_chat_booster_area = CardArea(
				0,
				0,
				G.CARD_W / 2 * 1.15 * 4,
				G.CARD_H / 2,
				{ card_limit = 4, type = "title_2", highlight_limit = 0 }
			)
			G.twbl_chat_booster_area_position = "left-long"
			tw_sticker:__emplace_cards(kind, mode)
			G.twbl_chat_booster_area.states.visible = false

			TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
			TW_BL.CHAT_COMMANDS.toggle_max_uses("target", 1, true)
			TW_BL.CHAT_COMMANDS.reset(false, "target")
			TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
				command = "target",
				position = "twbl_position_Card_singular",
				text = "k_twbl_panel_toggle_chat_booster_consumeable_multiple",
			})
			TW_BL.EVENTS.set_delay_threshold("chat_booster", 5)
		end
	elseif kind == "Celestial" then
		G.twbl_chat_booster_area =
			CardArea(0, 0, 5 * G.CARD_W / 2, G.CARD_H / 2, { card_limit = 5, type = "title_2", highlight_limit = 0 })
		G.twbl_chat_booster_area_position = "bottom-full-width"
		tw_sticker:__emplace_cards(kind, "single")
		G.twbl_chat_booster_area.states.visible = false

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_max_uses("target", 1, true)
		TW_BL.CHAT_COMMANDS.reset(false, "target")
		TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
			command = "target",
			position = "twbl_position_Card_singular",
			text = "k_twbl_panel_toggle_chat_booster_celestial_single",
		})
		TW_BL.EVENTS.set_delay_threshold("chat_booster", 5)
	elseif kind == "Standard" then
		G.twbl_chat_booster_area =
			CardArea(0, 0, 5 * G.CARD_W / 2, G.CARD_H / 2, { card_limit = 5, type = "title_2", highlight_limit = 0 })
		G.twbl_chat_booster_area_position = "bottom-full-width"
		tw_sticker:__emplace_cards(kind, "single")
		G.twbl_chat_booster_area.states.visible = false

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_max_uses("target", 1, true)
		TW_BL.CHAT_COMMANDS.reset(false, "target")
		TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
			command = "target",
			position = "twbl_position_Card_singular",
			text = "k_twbl_panel_toggle_chat_booster_standard_single",
		})
		TW_BL.EVENTS.set_delay_threshold("chat_booster", 5)
	else
		card.ability.twbl_chat_booster = nil
		TW_BL.G.state_sticker_chat_booster = nil
	end
end
function tw_sticker:__on_booster_exit()
	local areas = {
		"twbl_chat_booster_area",
		"twbl_chat_booster_area_UIBox",
	}
	for i = 1, #areas do
		local area = G[areas[i]]
		if area then
			area:remove()
			G[areas[i]] = nil
		end
	end

	G.twbl_chat_booster_area_position = nil

	if TW_BL.G.state_sticker_chat_booster then
		local kind = TW_BL.G.state_sticker_chat_booster.kind
		local mode = TW_BL.G.state_sticker_chat_booster.mode
		local use = TW_BL.G.state_sticker_chat_booster.use

		TW_BL.G.state_sticker_chat_booster = nil

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", false, true)
		TW_BL.CHAT_COMMANDS.toggle_max_uses("target", nil, true)
		TW_BL.CHAT_COMMANDS.reset(false, "target")
		TW_BL.UI.remove_panel("booster_top", "command_info_1_short", true)

		for _, v in ipairs(G.hand.cards) do
			v.ability.twbl_state_target_score = nil
		end
		for _, v in ipairs(G.deck.cards) do
			v.ability.twbl_state_target_score = nil
		end
	end
end

--

TW_BL.EVENTS.add_listener("twitch_command", "twbl_sticker_chat_booster", function(command, username, raw_index)
	if command ~= "target" or not TW_BL.G.state_sticker_chat_booster or not G.booster_pack then
		return
	end
	local index = tonumber(raw_index)
	local kind = TW_BL.G.state_sticker_chat_booster.kind
	local mode = TW_BL.G.state_sticker_chat_booster.mode

	local area, colour
	if kind == "Celestial" or kind == "Standard" then
		area = G.twbl_chat_booster_area
		colour = kind == "Standard" and G.C.MONEY or G.C.CHIPS
	elseif kind == "Arcana" or kind == "Spectral" then
		colour = kind == "Arcana" and G.C.PURPLE or G.C.CHIPS
		if mode == "single" then
			area = G.hand
		elseif mode == "multiple" then
			area = G.twbl_chat_booster_area
		end
	end
	if index and area and area.cards and area.cards[index] then
		TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
		local card = area.cards[index]
		card.ability.twbl_state_target_score = (card.ability.twbl_state_target_score or 0) + 1
		card_eval_status_text(card, "extra", nil, nil, nil, { message = username, colour = colour, instant = true })
	end
end)
