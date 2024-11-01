local BOOSTERS_TO_APPLY = {
	["Spectral"] = true,
	["Arcana"] = true,
	["Celestial"] = true,
	["Standard"] = true,
}

local STICKER_RATE = {
	["Spectral"] = 0.5,
	["Arcana"] = 0.5,
	["Celestial"] = 0.333,
	["Standard"] = 0.5,
}

local function select_planet_in_pack()
	local copy = {}
	for _, v in ipairs(G.twbl_chat_booster_planets.cards) do
		table.insert(copy, v)
	end
	table.sort(copy, function(a, b)
		local target_diff = (a.ability.twbl_state_target_score or 0) - (b.ability.twbl_state_target_score or 0)
		if target_diff == 0 then
			return (a.ability.twbl_sticker_chat_booster_pseudo or 0) > (b.ability.twbl_sticker_chat_booster_pseudo or 0)
		end
		return target_diff > 0
	end)
	return copy[1]
end

local function select_cards_in_pack(amount)
	G.hand:unhighlight_all()
	local amount_to_select = amount or 0
	if amount_to_select == 0 then
		return
	end

	local copy = {}
	for _, v in ipairs(G.hand.cards) do
		table.insert(copy, v)
	end
	table.sort(copy, function(a, b)
		local target_diff = (a.ability.twbl_state_target_score or 0) - (b.ability.twbl_state_target_score or 0)
		if target_diff == 0 then
			return (a.ability.twbl_sticker_chat_booster_pseudo or 0) > (b.ability.twbl_sticker_chat_booster_pseudo or 0)
		end
		return target_diff > 0
	end)
	for i = 1, amount_to_select do
		G.hand:add_to_highlighted(copy[i])
	end
end

local function get_booster_pool(kind)
	local result_pool = {}
	local pool_to_copy = {}

	if kind == "Arcana" then
		pool_to_copy = G.P_CENTER_POOLS.Tarot
	elseif kind == "Spectral" then
		pool_to_copy = G.P_CENTER_POOLS.Spectral
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
		for _, k in ipairs(vanilla_planets) do
			local center = G.P_CENTERS[k]
			if center and center.config and center.config.hand_type then
				if not (center.config.softlock and G.GAME.hands[center.config.hand_type].played <= 0) then
					result_pool[k] = center
				end
			end
		end
		return result_pool
	end

	for k, v in pairs(pool_to_copy) do
		local min_select = v.config.min_highlighted or 0
		local max_select = v.config.max_highlighted or 0
		if (min_select > 0 or max_select > 0) and G.hand.config.card_limit >= min_select then
			result_pool[k] = v
		end
	end

	return result_pool
end

local tw_sticker = SMODS.Sticker({
	atlas = "twbl_stickers",
	pos = { x = 0, y = 0 },
	badge_colour = HEX("8e15ad"),
	config = {},
	rate = 0,
	key = "twbl_chat_booster",
	discovered = true,
})

-- Implementation in lovely/stickers_chat_booster.toml

function tw_sticker:in_pool()
	-- Twitch interaction required
	return false
end

function tw_sticker:should_apply(card, center, area)
	return TW_BL.SETTINGS.current.chat_booster_sticker_appearance > 1
		and card.ability.set == "Booster"
		and BOOSTERS_TO_APPLY[center.kind]
		and (
			card.from_tag
			or TW_BL.SETTINGS.current.chat_booster_sticker_appearance == 3
			or (
				TW_BL.SETTINGS.current.chat_booster_sticker_appearance == 2
				and STICKER_RATE[center.kind] >= pseudorandom(pseudoseed("twbl_sticker_chat_booster_natural"))
			)
		)
end

--

function twbl_sticker_chat_booster_naturally_apply(card, area, check_for_tag)
	if check_for_tag and not card.from_tag then
		return
	end
	if tw_sticker:should_apply(card, card.config.center, area or card.area) then
		tw_sticker:apply(card, true)
	end
end

--

function twbl_sticker_chat_booster_select_targets(card, set_highlighted)
	if
		not (
			TW_BL.G.state_sticker_chat_booster
			and card.ability
			and card.ability.consumeable
			and G.twbl_chat_booster_cards
			and card.area == G.twbl_chat_booster_cards
		)
	then
		return false
	end

	for _, hand_card in ipairs(G.hand.cards) do
		if hand_card.ability and not hand_card.ability.twbl_sticker_chat_booster_pseudo then
			hand_card.ability.twbl_sticker_chat_booster_pseudo =
				pseudorandom(pseudoseed("twbl_chat_booster_card_pseudo"))
		end
	end

	local min_select = card.ability.consumeable.min_highlighted or 0
	local max_select = card.ability.consumeable.max_highlighted or 0
	local need_to_select = set_highlighted and (min_select > 0 or max_select > 0) and #G.hand.cards >= min_select

	if need_to_select then
		select_cards_in_pack(
			math.min(
				#G.hand.cards,
				card.ability.consumeable.max_highlighted or card.ability.consumeable.min_highlighted
			)
		)

		-- Prevent selecting 2 cards at once
		for _, area in ipairs({ G.consumeables, G.pack_cards }) do
			if area ~= card.area then
				area:unhighlight_all()
			end
		end

		return true
	else
		G.hand:unhighlight_all()
	end

	return false
end

function twbl_sticker_chat_booster_select_planet()
	if not TW_BL.G.state_sticker_chat_booster then
		return nil
	end

	for _, planet in ipairs(G.twbl_chat_booster_planets.cards) do
		if planet.ability and not planet.ability.twbl_sticker_chat_booster_pseudo then
			planet.ability.twbl_sticker_chat_booster_pseudo = pseudorandom(pseudoseed("twbl_chat_booster_card_pseudo"))
		end
	end

	return select_planet_in_pack()
end

function twbl_sticker_chat_booster_use_card()
	TW_BL.G.state_sticker_chat_booster_use = nil

	-- If we skipping
	if G.GAME.pack_choices then
		G.GAME.pack_choices = 0
	end

	if TW_BL.G.state_sticker_chat_booster == "Celestial" then
		TW_BL.EVENTS.request_delay(5, "chat_booster")
		G.E_MANAGER:add_event(Event({
			func = function()
				local planet = twbl_sticker_chat_booster_select_planet()
				if not planet then
					return false
				end

				G.FUNCS.use_card({
					config = {
						ref_table = planet,
					},
				})
				return true
			end,
		}))

		return true
	elseif TW_BL.G.state_sticker_chat_booster == "Arcana" or TW_BL.G.state_sticker_chat_booster == "Spectral" then
		TW_BL.EVENTS.request_delay(5, "chat_booster")
		G.E_MANAGER:add_event(Event({
			func = function()
				local card_to_use = G.twbl_chat_booster_cards and G.twbl_chat_booster_cards.cards[1]
				if not card_to_use or not twbl_sticker_chat_booster_select_targets(card_to_use, true) then
					return false
				end

				G.FUNCS.use_card({
					config = {
						ref_table = card_to_use,
					},
				})
				return true
			end,
		}))

		return true
	elseif TW_BL.G.state_sticker_chat_booster == "Standard" then
		TW_BL.EVENTS.request_delay(5, "chat_booster")
		G.E_MANAGER:add_event(Event({
			func = function()
				local card = twbl_sticker_chat_booster_select_planet()
				if not card then
					return false
				end

				card:hard_set_T(nil, nil, G.CARD_W, G.CARD_H)

				G.FUNCS.use_card({
					config = {
						ref_table = card,
					},
				})
				return true
			end,
		}))
		return true
	else
		return false
	end
end

--

function twbl_sticker_chat_booster_emplace_planets(kind)
	local area = G.twbl_chat_booster_planets
	local pool = get_booster_pool("Celestial")
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
		G.twbl_chat_booster_planets:emplace(chat_card)
	end
end

function twbl_sticker_chat_booster_emplace_consumeable(kind)
	local area = G.twbl_chat_booster_cards
	local pool = get_booster_pool(kind)
	local center = pseudorandom_element(pool, pseudoseed("twbl_chat_booster_chat_card"))
	local chat_card = Card(area.T.x + area.T.w / 2, area.T.y, G.CARD_W / 2, G.CARD_H / 2, nil, center, {
		bypass_discovery_center = true,
		bypass_discovery_ui = true,
		discover = false,
		bypass_back = G.GAME.selected_back.pos,
	})
	area:emplace(chat_card)
end

function twbl_sticker_chat_booster_emplace_playing_cards(kind)
	local area = G.twbl_chat_booster_planets
	for i = 1, 4 do
		local center
		if pseudorandom(pseudoseed("twbl_stdset" .. G.GAME.round_resets.ante)) > 0.6 then
			local _pool, _pool_key = get_current_pool("Enhanced", nil, nil, "sta")
			center = pseudorandom_element(_pool, pseudoseed(_pool_key))
			local it = 1
			while center == "UNAVAILABLE" do
				it = it + 1
				center = pseudorandom_element(_pool, pseudoseed(_pool_key .. "_resample" .. it))
			end

			center = G.P_CENTERS[center]
		else
			center = G.P_CENTERS.c_base
		end
		local front = pseudorandom_element(G.P_CARDS, pseudoseed("twbl_frontsta" .. G.GAME.round_resets.ante))
		local card = Card(area.T.x + area.T.w / 2, area.T.y, G.CARD_W / 2, G.CARD_H / 2, front, center, {
			bypass_discovery_center = false,
			bypass_discovery_ui = false,
			discover = false,
			bypass_back = G.GAME.selected_back.pos,
		})
		local edition_rate = 6
		local edition = poll_edition("twbl_standard_edition" .. G.GAME.round_resets.ante, edition_rate, true)
		card:set_edition(edition)
		local seal_rate = 3
		local seal_poll = pseudorandom(pseudoseed("twbl_stdseal" .. G.GAME.round_resets.ante))
		if seal_poll > 1 - 0.02 * seal_rate then
			local seal_type = pseudorandom(pseudoseed("twbl_stdsealtype" .. G.GAME.round_resets.ante))
			if seal_type > 0.75 then
				card:set_seal("Red")
			elseif seal_type > 0.5 then
				card:set_seal("Blue")
			elseif seal_type > 0.25 then
				card:set_seal("Gold")
			else
				card:set_seal("Purple")
			end
		end
		area:emplace(card)
	end
end

--

function twbl_sticker_chat_booster_open(card)
	local kind = card.config.center.kind
	if kind == "Spectral" or kind == "Arcana" then
		TW_BL.G.state_sticker_chat_booster = card.config.center.kind
		TW_BL.G.state_sticker_chat_booster_use = true

		G.twbl_chat_booster_cards =
			CardArea(0, 0, G.CARD_W / 2, G.CARD_H / 2, { card_limit = 1, type = "title_2", highlight_limit = 0 })
		twbl_sticker_chat_booster_emplace_consumeable(kind)
		G.twbl_chat_booster_cards.states.visible = false

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_max_uses("target", 1, true)
		TW_BL.CHAT_COMMANDS.reset(false, "target")
		TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
			command = "target",
			position = "twbl_position_Card_singular",
			text = "k_twbl_panel_toggle_chat_booster_consumeable",
		})
		TW_BL.EVENTS.set_delay_threshold("chat_booster", 5)
	elseif kind == "Celestial" then
		TW_BL.G.state_sticker_chat_booster = card.config.center.kind
		TW_BL.G.state_sticker_chat_booster_use = true

		G.twbl_chat_booster_planets =
			CardArea(0, 0, 5 * G.CARD_W / 2, G.CARD_H / 2, { card_limit = 5, type = "title_2", highlight_limit = 0 })
		twbl_sticker_chat_booster_emplace_planets(kind)
		G.twbl_chat_booster_planets.states.visible = false

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_max_uses("target", 1, true)
		TW_BL.CHAT_COMMANDS.reset(false, "target")
		TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
			command = "target",
			position = "twbl_position_Card_singular",
			text = "k_twbl_panel_toggle_chat_booster_celestial",
		})
		TW_BL.EVENTS.set_delay_threshold("chat_booster", 5)
	elseif kind == "Standard" then
		TW_BL.G.state_sticker_chat_booster = card.config.center.kind
		TW_BL.G.state_sticker_chat_booster_use = true

		G.twbl_chat_booster_planets =
			CardArea(0, 0, 5 * G.CARD_W / 2, G.CARD_H / 2, { card_limit = 5, type = "title_2", highlight_limit = 0 })
		twbl_sticker_chat_booster_emplace_playing_cards(kind)
		G.twbl_chat_booster_planets.states.visible = false

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_max_uses("target", 1, true)
		TW_BL.CHAT_COMMANDS.reset(false, "target")
		TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
			command = "target",
			position = "twbl_position_Card_singular",
			text = "k_twbl_panel_toggle_chat_booster_standard",
		})
		TW_BL.EVENTS.set_delay_threshold("chat_booster", 5)
	else
		card.ability.twbl_chat_booster = nil
		TW_BL.G.state_sticker_chat_booster = nil
		TW_BL.G.state_sticker_chat_booster_use = nil
	end
end

function twbl_sticker_chat_booster_exit()
	if G.twbl_chat_booster_cards then
		G.twbl_chat_booster_cards_UIBox:remove()
		G.twbl_chat_booster_cards_UIBox = nil
		G.twbl_chat_booster_cards:remove()
		G.twbl_chat_booster_cards = nil
	end
	if G.twbl_chat_booster_planets then
		G.twbl_chat_booster_planets_UIBox:remove()
		G.twbl_chat_booster_planets_UIBox = nil
		G.twbl_chat_booster_planets:remove()
		G.twbl_chat_booster_planets = nil
	end
	if TW_BL.G.state_sticker_chat_booster then
		TW_BL.G.state_sticker_chat_booster = nil
		TW_BL.G.state_sticker_chat_booster_use = nil

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
	if TW_BL.G.state_sticker_chat_booster == "Celestial" then
		if
			index
			and G.twbl_chat_booster_planets
			and G.twbl_chat_booster_planets.cards
			and G.twbl_chat_booster_planets.cards[index]
		then
			TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
			local card = G.twbl_chat_booster_planets.cards[index]
			card.ability.twbl_state_target_score = (card.ability.twbl_state_target_score or 0) + 1
			card_eval_status_text(
				card,
				"extra",
				nil,
				nil,
				nil,
				{ message = username, colour = G.C.CHIPS, instant = true }
			)
		end
	elseif TW_BL.G.state_sticker_chat_booster == "Standard" then
		if
			index
			and G.twbl_chat_booster_planets
			and G.twbl_chat_booster_planets.cards
			and G.twbl_chat_booster_planets.cards[index]
		then
			TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
			local card = G.twbl_chat_booster_planets.cards[index]
			card.ability.twbl_state_target_score = (card.ability.twbl_state_target_score or 0) + 1
			card_eval_status_text(
				card,
				"extra",
				nil,
				nil,
				nil,
				{ message = username, colour = G.C.MONEY, instant = true }
			)
		end
	elseif TW_BL.G.state_sticker_chat_booster == "Arcana" or TW_BL.G.state_sticker_chat_booster == "Spectral" then
		if index and G.hand and G.hand.cards and G.hand.cards[index] then
			TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
			local card = G.hand.cards[index]
			card.ability.twbl_state_target_score = (card.ability.twbl_state_target_score or 0) + 1
			card_eval_status_text(
				card,
				"extra",
				nil,
				nil,
				nil,
				{ message = username, colour = G.C.CHIPS, instant = true }
			)
		end
	end
end)
