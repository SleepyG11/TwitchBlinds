SMODS.Atlas({
	key = "twbl_blind_atlas_garden",
	px = 34,
	py = 34,
	path = "blinds/garden.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "garden",
	dollars = 5,
	mult = 2,
	boss = { min = 3, max = 6 },
	boss_colour = HEX("1fa456"),

	atlas = "twbl_blind_atlas_garden",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return TW_BL.blinds.is_in_range(self, true) and pseudorandom("twbl_garden_encounter") < 0.05
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

		-- Real Flower Pot
		local pot_card = create_card("Joker", G.play, false, nil, nil, nil, "j_flower_pot", nil)
		pot_card:set_eternal(true)
		G.play:emplace(pot_card)
		pot_card:start_materialize()
		pot_card.ability.__twbl_jimbo = true

		-- Real Doc
		local doc_card = create_card("Joker", G.play, false, nil, nil, nil, "j_scholar", nil)
		doc_card.states.visible = false
		doc_card:set_edition({ negative = true }, true, true)
		G.play:emplace(doc_card)

		-- Talking doc
		local talking_card = Card_Character({
			x = doc_card.T.x,
			y = doc_card.T.y,
			w = doc_card.T.w,
			h = doc_card.T.h,
			center = "j_scholar",
		})
		doc_card:remove()
		talking_card.children.particles:set_role({
			role_type = "Minor",
			xy_bond = "Strong",
			r_bond = "Strong",
			major = talking_card,
		})
		local pseudo_card = talking_card.children.card
		pseudo_card:set_edition({ negative = true }, true, true)
		G.play:emplace(pseudo_card)

		talking_card:add_speech_bubble("twbl_blinds_garden_" .. math.random(4), nil, { quip = true })
		talking_card:say_stuff(5)

		delay(3)
		G.E_MANAGER:add_event(Event({
			func = function()
				G.twbl_force_speedfactor = nil

				talking_card:remove_speech_bubble()
				talking_card.children.particles:fade(0.2, 1)
				pseudo_card:start_dissolve()

				G.E_MANAGER:add_event(Event({
					func = function()
						G.play:remove_card(pot_card)
						G.jokers:emplace(pot_card)
						pot_card:add_to_deck(true)
						talking_card:remove()
						G.twbl_force_speedfactor = nil
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
		return localize("k_twbl_choose_ex")
	end,
	command = "vote",
	command_max_uses = 1,
	voting = true,
	set_vote_variants = function()
		return { "1", "2", "3" }
	end,
	set_effects = function()
		local result = {}

		local _edition_pool, _edition_pool_key = get_current_pool("Edition")
		local edition_pool = TW_BL.utils.table_shallow_copy(_edition_pool)
		table.insert(edition_pool, "__twbl_no_edition")

		local rolled_editions = {}
		for i = 1, 3 do
			edition_pool = TW_BL.utils.table_filter(edition_pool, function(v)
				return not rolled_editions[v]
			end)
			local _edition =
				pseudorandom_element(edition_pool, pseudoseed("twbl_garden_edition_choice" .. G.GAME.round_resets.ante))

			if SMODS.size_of_pool(edition_pool) == 0 then
				table.insert(_edition_pool, "__twbl_no_edition")
			end

			local it = 1
			while _edition == "UNAVAILABLE" do
				it = it + 1
				_edition = pseudorandom_element(edition_pool, pseudoseed(_edition_pool_key .. "_resample" .. it))
			end

			rolled_editions[_edition] = true
			table.insert(result, {
				key = _edition,
				no_edition = _edition == "__twbl_no_edition",
			})
		end

		return result
	end,
	get_items = function(effects, args)
		local items = {}

		for index, effect in ipairs(effects) do
			local text
			if effect.no_edition then
				text = localize("twbl_no_edition")
			else
				text = localize({
					type = "name_text",
					key = effect.key,
					set = "Edition",
					vars = {},
				})
			end
			table.insert(items, {
				text = text,
				mystic = index == 3,
				-- TODO: UI for displaying edition info_queue
			})
		end

		return items
	end,
	apply_effect = function(effect)
		if G.GAME.blind.__twbl_jimbo_card and not G.GAME.blind.__twbl_jimbo_card.REMOVED then
			G.GAME.blind.__twbl_jimbo_card:set_edition(not effect.no_edition and effect.key or nil, true)
		end
	end,
	delay_load = true,
})
