SMODS.Atlas({
	key = "twbl_blind_atlas_jimbo",
	px = 34,
	py = 34,
	path = "blinds/jimbo.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "jimbo",
	dollars = 5,
	mult = 2,
	boss = { min = 3, max = 6 },
	boss_colour = HEX("0077e8"),

	atlas = "twbl_blind_atlas_jimbo",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return TW_BL.blinds.is_in_range(self, true) and pseudorandom("twbl_jimbo_encounter") < 0.05
	end,
	twbl_once_per_run = true,

	set_blind = function(self)
		local is_finished = false
		G.E_MANAGER:add_event(Event({
			func = function()
				return is_finished
			end,
		}))

		ease_background_colour_blind()

		G.E_MANAGER.queues["twbl_cutscenes"] = G.E_MANAGER.queues["twbl_cutscenes"] or {}
		G.twbl_force_event_queue = "twbl_cutscenes"
		G.twbl_force_speedfactor = 1

		SMODS.bypass_create_card_discovery_center = true

		-- Real doc
		local jimbo_card = create_card("Joker", G.play, false, nil, nil, nil, "j_joker", nil)
		jimbo_card.states.visible = false
		jimbo_card:set_eternal(true)
		G.play:emplace(jimbo_card)
		jimbo_card.ability.__twbl_jimbo = true

		-- Talking doc
		local talking_card = Card_Character({
			x = jimbo_card.T.x,
			y = jimbo_card.T.y,
			w = jimbo_card.T.w,
			h = jimbo_card.T.h,
			center = "j_joker",
		})
		local pseudo_card = talking_card.children.card
		pseudo_card:set_eternal(true)

		talking_card:add_speech_bubble("twbl_blinds_jimbo_" .. math.random(7), nil, { quip = true })
		talking_card:say_stuff(5)

		delay(3)
		G.E_MANAGER:add_event(Event({
			func = function()
				G.twbl_force_speedfactor = nil
				talking_card:remove_speech_bubble()
				talking_card.children.particles:fade(0.2, 1)
				pseudo_card.states.visible = false

				jimbo_card.states.visible = true
				G.play:remove_card(jimbo_card)
				G.jokers:emplace(jimbo_card)
				jimbo_card:add_to_deck()

				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.2,
					func = function()
						talking_card:remove()
						G.twbl_force_event_queue = nil
						is_finished = true
						return true
					end,
				}))

				return true
			end,
		}))

		SMODS.bypass_create_card_discovery_center = nil
	end,

	twbl_load = function(self)
		for _, card in pairs(G.I.CARD) do
			if card.ability and card.ability.__twbl_jimbo then
				G.GAME.blind.__twbl_jimbo_card = card
				break
			end
		end
	end,
	defeat = function(self)
		for _, card in pairs(G.I.CARD) do
			if card.ability and card.ability.__twbl_jimbo then
				card.ability.__twbl_jimbo = nil
				break
			end
		end
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_jimbo_ex")
	end,
	weighted_voting = true,
	update_weight_func = function(old_score, variant)
		if variant == "down" then
			return old_score + 0.1
		elseif variant == "up" then
			return old_score - 0.1
		else
			return old_score
		end
	end,
	check_weight_boundaries = true,
	default_weight_score = 0.5,
	set_vote_variants = function()
		return { "down", "up" }
	end,
	command = "grow",
	command_max_uses = 1,
	progress_w = 8,
	get_items = function(_, args)
		return {
			left = {
				command = args.command .. " down",
			},
			right = {
				command = args.command .. " up",
			},
			progress = {
				{
					pos = 0,
					text = localize({
						type = "variable",
						key = "twbl_jimbo_grow_down",
						vars = {},
					}),
				},
				{
					pos = 0.1,
					line = true,
				},
				{
					pos = 0.2,
					line = true,
				},
				{
					pos = 0.3,
					line = true,
				},
				{
					pos = 0.4,
					line = true,
				},
				{
					pos = 0.5,
					center = true,
					line = true,
					text = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
					colour = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
				},
				{
					pos = 0.6,
					line = true,
				},
				{
					pos = 0.7,
					line = true,
				},
				{
					pos = 0.8,
					line = true,
				},
				{
					pos = 0.9,
					line = true,
				},
				{
					pos = 1,
					text = localize({
						type = "variable",
						key = "twbl_jimbo_grow_up",
						vars = {},
					}),
				},
			},
		}
	end,
	on_new_provider_command = function(event, args)
		local arg1 = event.words[1]
		if
			G.GAME.blind.__twbl_jimbo_card
			and not G.GAME.blind.__twbl_jimbo_card.REMOVED
			and TW_BL.chat_commands.default_command_check(event, {
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
			local card = G.GAME.blind.__twbl_jimbo_card
			local current_size = card.ability.twbl_resize or 1
			local min_size = 1 / 3
			local max_size = 1.5
			local step = (max_size - min_size) / 10

			local new_size, colour
			if arg1 == "up" then
				-- increase jimbo
				new_size = math.min(current_size + step, max_size)
				colour = G.C.CHIPS
			elseif arg1 == "down" then
				-- decrease jimbo
				new_size = math.max(current_size - step, min_size)
				colour = G.C.RED
			end
			TW_BL.utils.resize_card(card, new_size / current_size)
			TW_BL.utils.vote_for_card(card, event, colour)
		end
	end,
	delay_load = true,
})
