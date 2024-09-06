local BOOSTERS_TO_APPLY = {
	["Spectral"] = true,
	["Arcana"] = true,
}

local STICKER_RATE = {
	["Spectral"] = 0.75,
	["Arcana"] = 0.5,
}

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
	colour = HEX("8e15ad"),
	config = {},
	rate = 0,
	key = "twbl_chat_booster",
	loc_text = {
		name = "Chat Booster",
		text = { "Chat will use additional", "targetable consumable" },
	},
})

-- Implementation in lovely/stickers_chat_booster.toml

function tw_sticker:in_pool()
	-- Twitch interaction required
	return false
end

function tw_sticker:should_apply(card, center, area)
	return TW_BL.SETTINGS.current.natural_chat_booster_sticker
		and card.ability.set == "Booster"
		and BOOSTERS_TO_APPLY[center.kind]
		and STICKER_RATE[center.kind] >= pseudorandom(pseudoseed("twbl_sticker_chat_booster_natural"))
end

--

function twbl_sticker_chat_booster_naturally_apply(card, area)
	if tw_sticker:should_apply(card, card.config.center, area or card.area) then
		tw_sticker:apply(card, true)
	end
end

function twbl_sticker_chat_booster_select_targets(card, set_highlighted)
	if
		not (
			G.GAME.twbl.state_sticker_chat_booster
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

function twbl_sticker_chat_booster_use_card()
	G.GAME.twbl.state_sticker_chat_booster_use = nil
	local card_to_use = G.twbl_chat_booster_cards and G.twbl_chat_booster_cards.cards[1]
	if not card_to_use or not twbl_sticker_chat_booster_select_targets(card_to_use, true) then
		return false
	end

	-- If we skipping
	if G.GAME.pack_choices then
		G.GAME.pack_choices = 0
	end

	G.FUNCS.use_card({
		config = {
			ref_table = card_to_use,
		},
	})

	return true
end

--

function twbl_sticker_chat_booster_open(card)
	local kind = card.config.center.kind
	if kind == "Spectral" or kind == "Arcana" then
		G.GAME.twbl.state_sticker_chat_booster = true
		G.GAME.twbl.state_sticker_chat_booster_use = true

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)
		TW_BL.CHAT_COMMANDS.reset(true, "target")
		TW_BL.UI.set_panel("booster_top", "command_info_1_short", true, true, {
			command = "target",
			position = "twbl_position_Card_singular",
			text = "k_twbl_panel_toggle_chat_booster",
		})
		G.twbl_chat_booster_cards = CardArea(
			-99,
			-99,
			1.02 * G.CARD_W / 2,
			1.05 * G.CARD_H / 2,
			{ card_limit = 1, type = "title_2", highlight_limit = 0 }
		)
		local area = G.twbl_chat_booster_cards
		local center =
			pseudorandom_element(get_booster_pool(card.config.center.kind), pseudoseed("twbl_chat_booster_chat_card"))
		local chat_card = Card(area.T.x + area.T.w / 2, area.T.y, G.CARD_W / 2, G.CARD_H / 2, nil, center, {
			bypass_discovery_center = true,
			bypass_discovery_ui = true,
			discover = falses,
			bypass_back = G.GAME.selected_back.pos,
		})
		G.twbl_chat_booster_cards:emplace(chat_card)
	else
		card.ability.twbl_chat_booster = nil
		G.GAME.twbl.state_sticker_chat_booster = nil
		G.GAME.twbl.state_sticker_chat_booster_use = nil
	end
end

function twbl_sticker_chat_booster_exit()
	if G.twbl_chat_booster_cards then
		G.twbl_chat_booster_cards:remove()
	end
	if G.GAME.twbl.state_sticker_chat_booster then
		G.GAME.twbl.state_sticker_chat_booster = nil
		G.GAME.twbl.state_sticker_chat_booster_use = nil

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", false, true)
		TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)
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

TW_BL.EVENTS.add_listener("twitch_command", "twbl_chat_booster", function(command, username, raw_index)
	if command ~= "target" or not G.GAME.twbl.state_sticker_chat_booster or not G.booster_pack then
		return
	end
	local index = tonumber(raw_index)
	if index and G.hand and G.hand.cards and G.hand.cards[index] then
		local card = G.hand.cards[index]
		card.ability.twbl_state_target_score = (card.ability.twbl_state_target_score or 0) + 1
		card_eval_status_text(card, "extra", nil, nil, nil, { message = username, colour = G.C.CHIPS })
	else
		TW_BL.CHAT_COMMANDS.decrement_command_use("target", username)
	end
end)
