function TW_BL.utils.command_card(area, event)
	local index = tonumber(event.words[1])
	return (index and area and area.cards) and area.cards[index] or nil, index
end

function TW_BL.utils.vote_for_card(card, event, colour, scale)
	card.ability.twbl_score = (card.ability.twbl_score or 0) + 1
	TW_BL.UI.notify({
		target = "card",
		card = card,
		message = event.username,
		colour = colour or G.C.ORANGE,
		scale = scale,
	})
end

function TW_BL.utils.get_most_voted_card(area, fallback_seed)
	if not (area and area.cards and #area.cards > 0) then
		return nil, nil
	end

	local max_score = 0
	local result_card, result_index = pseudorandom_element(area.cards, pseudoseed(fallback_seed))
	for index, card in ipairs(area.cards) do
		if card.ability.twbl_winner then
			return card, index
		end
		if (card.ability.twbl_score or 0) > max_score then
			result_card = card
			result_index = index
			max_score = card.ability.twbl_score
		end
		card.ability.twbl_score = nil
	end

	return result_card or nil, result_index or nil
end

function TW_BL.utils.reset_cards_score(area, with_winner)
	if area and area.cards then
		for _, card in ipairs(area.cards) do
			card.ability.twbl_score = nil
			if with_winner then
				card.ability.twbl_winner = nil
			end
		end
	end
end

function TW_BL.utils.poll_blind_effects(effects, amount, seed)
	local current_options = {}
	for key, v in pairs(effects) do
		current_options[key] = v
	end

	local result_effects = {}
	for i = 1, amount do
		local effect, rolled_key = pseudorandom_element(current_options, pseudoseed(seed .. "_effect"))
		local rolled_vars = effect.vars_list
			and pseudorandom_element(effect.vars_list, pseudoseed(seed .. "_effect_vars"))
		current_options[rolled_key] = nil
		table.insert(result_effects, {
			key = rolled_key,
			vars = rolled_vars or {},
		})
	end

	return result_effects
end