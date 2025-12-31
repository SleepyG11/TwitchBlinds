SMODS.Atlas({
	key = "twbl_blind_atlas_grape_knife",
	px = 34,
	py = 34,
	path = "blinds/blank.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "grape_knife",
	dollars = 8,
	mult = 2,
	boss = { showdown = true, min = 2 },

	boss_colour = HEX("6F2DA8"),

	atlas = "twbl_blind_atlas_grape_knife",

	in_pool = function()
		return false
	end,

	twbl_is_twitch_blind = true,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_showdown_ex")
	end,
	weighted_voting = true,
	update_weight_func = function(old_score, variant)
		if variant == "left" then
			return old_score + 0.1
		elseif variant == "right" then
			return old_score - 0.1
		else
			return old_score
		end
	end,
	check_weight_boundaries = true,
	default_weight_score = 0.5,
	set_vote_variants = function()
		return { "left", "right" }
	end,
	command = "vote",
	command_max_uses = 1,
	command_use_refresh_timeout = 5,
	progress_w = 10,
	get_items = function(_, args)
		return {
			left = {
				command = args.command .. " left",
			},
			right = {
				command = args.command .. " right",
			},
			progress = {
				{
					pos = 0.1,
					text = localize({
						type = "variable",
						key = "twbl_grape_knife_seals",
						vars = {},
					}),
					center = true,
				},
				{
					pos = 0.19,
					line = true,
					text = localize({
						type = "variable",
						key = "twbl_grape_knife_most_common_rank",
						vars = {},
					}),
				},
				{
					pos = 0.41,
					line = true,
				},
				{
					pos = 0.5,
					center = true,
					text = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
					colour = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
				},
				{
					pos = 0.59,
					line = true,
				},
				{
					pos = 0.81,
					line = true,
					text = localize({
						type = "variable",
						key = "twbl_grape_knife_most_common_suit",
						vars = {},
					}),
				},
				{
					pos = 0.9,
					text = localize({
						type = "variable",
						key = "twbl_grape_knife_enhanced",
						vars = {},
					}),
					center = true,
				},
			},
		}
	end,
	on_new_provider_command = function(event, args)
		if
			TW_BL.chat_commands.default_command_check(event, {
				command = args.command,
				can_use_command = true,
				increment_command_use = true,
				vote_id = "blind_action",
				can_vote_for_variant = true,
				increment_vote_score = true,
				update_weight = true,
				update_weight_func = args.update_weight_func,
				check_weight_boundaries = args.check_weight_boundaries,
			})
		then
			local weight = TW_BL.chat_commands.get_weighted_vote_score("blind_action")

			-- 0.2 = seals
			-- 0.4 = most common rank
			-- 0.6 = nothing
			-- 0.8 = most common suit
			-- 1.0 = enhanced

			if weight < 0.2 then
				for _, card in ipairs(G.playing_cards) do
					card:set_debuff(not not card.seal)
				end
			elseif weight <= 0.4 then
				local stats = {}
				for _, card in ipairs(G.playing_cards) do
					if card.base and card.base.value then
						stats[card.base.value] = (stats[card.base.value] or 0) + 1
					end
				end
				local most_count, most_field = 0, nil
				for key, count in pairs(stats) do
					if not most_field then
						most_field = key
					end
					if count > most_count then
						most_field = key
						most_count = count
					end
				end
				for _, card in ipairs(G.playing_cards) do
					card:set_debuff(not not (card.base and card.base.value and card.base.value == most_field))
				end
			elseif weight > 0.8 then
				for _, card in ipairs(G.playing_cards) do
					card:set_debuff(card.config.center.key ~= "c_base")
				end
			elseif weight >= 0.6 then
				local stats = {}
				for _, card in ipairs(G.playing_cards) do
					if card.base and card.base.suit then
						stats[card.base.suit] = (stats[card.base.suit] or 0) + 1
					end
				end
				local most_count, most_field = 0, nil
				for key, count in pairs(stats) do
					if not most_field then
						most_field = key
					end
					if count > most_count then
						most_field = key
						most_count = count
					end
				end
				for _, card in ipairs(G.playing_cards) do
					card:set_debuff(not not (card.base and card.base.suit and card.base.suit == most_field))
				end
			else
				for _, card in ipairs(G.playing_cards) do
					card:set_debuff(false)
				end
			end
		end
	end,
})
