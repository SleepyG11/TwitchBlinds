SMODS.Sticker({
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

-- TODO: proper select blocking for cards that was created (like Familiar)

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
		local target_diff = (a.ability.twitch_booster_target or 0) - (b.ability.twitch_booster_target or 0)
		if target_diff == 0 then
			return (a.ability.twitch_chat_booster_pseudo or 0) > (b.ability.twitch_chat_booster_pseudo or 0)
		end
		return target_diff > 0
	end)
	for i = 1, amount_to_select do
		G.hand:add_to_highlighted(copy[i])
	end
end

TW_BL.EVENTS.add_listener("twitch_command", "twbl_chat_booster", function(command, username, raw_index)
	if command ~= "target" or not G.GAME.pool_flags.twitch_chat_booster or not G.booster_pack then
		return
	end
	local index = tonumber(raw_index)
	if index and G.hand and G.hand.cards and G.hand.cards[index] then
		local card = G.hand.cards[index]
		card.ability.twitch_booster_target = (card.ability.twitch_booster_target or 0) + 1
		card_eval_status_text(card, "extra", nil, nil, nil, { message = username, colour = G.C.CHIPS })
		select_cards_in_pack(#G.hand.highlighted)
	else
		TW_BL.CHAT_COMMANDS.decrement_command_use("target", username)
	end
end)

function twitch_chat_booster_select_targets(card, set_highlighted)
	if not G.GAME.pool_flags.twitch_chat_booster then
		return
	end
	if not card.ability or not card.ability.consumeable then
		return
	end
	if card.area ~= G.consumeables and card.area ~= G.pack_cards then
		return
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
	else
		G.hand:unhighlight_all()
	end
end

function twitch_chat_booster_open(card)
	local kind = card.config.center.kind
	if kind == "Spectral" or kind == "Arcana" then
		G.GAME.pool_flags.twitch_chat_booster = true

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", true, true)
		TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)
		TW_BL.CHAT_COMMANDS.reset()
	else
		card.ability.twbl_chat_booster = nil
		G.GAME.pool_flags.twitch_chat_booster = nil
	end
end

function twitch_chat_booster_exit()
	if G.GAME.pool_flags.twitch_chat_booster then
		G.GAME.pool_flags.twitch_chat_booster = nil

		TW_BL.CHAT_COMMANDS.toggle_can_collect("target", false, true)
		TW_BL.CHAT_COMMANDS.toggle_single_use("target", false, true)

		for _, v in ipairs(G.hand.cards) do
			v.ability.twitch_booster_target = nil
			v.ability.twitch_prevent_action = nil
		end
		for _, v in ipairs(G.deck.cards) do
			v.ability.twitch_booster_target = nil
			v.ability.twitch_prevent_action = nil
		end
	end
end
