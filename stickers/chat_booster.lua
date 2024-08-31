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

local tw_sticker = SMODS.Sticker({
	atlas = "twbl_stickers",
	pos = { x = 0, y = 0 },
	colour = HEX("8e15ad"),
	config = {},
	rate = 0,
	key = "twbl_chat_booster",
	loc_text = {
		name = "Chat Booster",
		text = { "Only Chat can select", "targets for consumables" },
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

function twbl_sticker_chat_booster_naturally_apply(card, area)
	if tw_sticker:should_apply(card, card.config.center, area or card.area) then
		tw_sticker:apply(card, true)
	end
end

function twbl_sticker_chat_booster_select_targets(card, set_highlighted)
	if not G.GAME.pool_flags.twbl_state_chat_booster or not card.ability or not card.ability.consumeable then
		return
	end
	if card.area ~= G.consumeables and card.area ~= G.pack_cards then
		return
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
		if card.area == G.consumeables then
			G.pack_cards:unhighlight_all()
		end
		if card.area == G.pack_cards then
			G.consumeables:unhighlight_all()
		end
	else
		G.hand:unhighlight_all()
	end
end

--

function twbl_sticker_chat_booster_open(card)
	local kind = card.config.center.kind
	if kind == "Spectral" or kind == "Arcana" then
		G.GAME.pool_flags.twbl_state_chat_booster = true

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)
		TW_BL.CHAT_COMMANDS.reset()
	else
		card.ability.twbl_chat_booster = nil
		G.GAME.pool_flags.twbl_state_chat_booster = nil
	end
end

function twbl_sticker_chat_booster_exit()
	if G.GAME.pool_flags.twbl_state_chat_booster then
		G.GAME.pool_flags.twbl_state_chat_booster = nil

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", false, true)
		TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)

		for _, v in ipairs(G.hand.cards) do
			v.ability.twbl_state_target_score = nil
		end
		for _, v in ipairs(G.deck.cards) do
			v.ability.twbl_state_target_score = nil
		end
	end
end

TW_BL.EVENTS.add_listener("twitch_command", "twbl_chat_booster", function(command, username, raw_index)
	if command ~= "target" or not G.GAME.pool_flags.twbl_state_chat_booster or not G.booster_pack then
		return
	end
	local index = tonumber(raw_index)
	if index and G.hand and G.hand.cards and G.hand.cards[index] then
		local card = G.hand.cards[index]
		card.ability.twbl_state_target_score = (card.ability.twbl_state_target_score or 0) + 1
		card_eval_status_text(card, "extra", nil, nil, nil, { message = username, colour = G.C.CHIPS })
		select_cards_in_pack(#G.hand.highlighted)
	else
		TW_BL.CHAT_COMMANDS.decrement_command_use("target", username)
	end
end)
