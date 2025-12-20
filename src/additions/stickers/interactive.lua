local function try_to_use_card(_card, scale, exit_func)
	local cards_in_hand = TW_BL.utils.table_shallow_copy(G.hand.cards)
	pseudoshuffle(cards_in_hand, "twbl_interactive_shuffle")
	G.hand:unhighlight_all()
	if type(_card.can_use_consumeable) == "function" then
		local can_use = _card:can_use_consumeable(true, true)
		if not can_use then
			for _, __card in ipairs(cards_in_hand) do
				G.hand:add_to_highlighted(__card, true)
			end
			can_use = _card:can_use_consumeable(true, true)
			local cards_left = #cards_in_hand
			while cards_left > 0 and not can_use do
				G.hand:remove_from_highlighted(cards_in_hand[cards_left])
				can_use = _card:can_use_consumeable(true, true)
				cards_left = cards_left - 1
			end
		end
		if can_use then
			TW_BL.utils.resize_card(_card, 1 / scale)
			G.FUNCS.use_card({
				config = {
					ref_table = _card,
				},
			})
			G.E_MANAGER:add_event(Event({
				func = function()
					G.E_MANAGER:add_event(Event({
						func = function()
							exit_func()
							return true
						end,
					}))
					return true
				end,
			}))
		else
			TW_BL.UI.notify({
				target = "card",
				card = _card,
				message = localize("k_twbl_cant_use_ex"),
				colour = G.C.RED,
				scale = scale * 1.5,
				align = "cr",
				align_y_off = 0,
			})
			_card:start_dissolve()
			exit_func()
		end
	end
end

-- TODO: cleanup
local effect_options = {
	["Standard"] = {
		rate = 0.4,

		card_scale = 1 / 2,

		open = function(self, card, center)
			local area =
				CardArea(0, 0, 7, G.CARD_H * self.card_scale, { card_limit = 5, type = "title_2", highlight_limit = 0 })
			for i = 1, 5 do
				local _card = SMODS.create_card({
					set = "Enhanced",
					area = area,
					no_edition = true,
					key_append = "twbl_std",
					bypass_discovery_center = true,
				})
				local _edition = SMODS.poll_edition({
					key = "twbl_std_edition" .. G.GAME.round_resets.ante,
					mod = 6,
					no_negative = true,
				})
				local _seal = SMODS.poll_seal({
					key = "twbl_std_seal" .. G.GAME.round_resets.ante,
					mod = 5,
				})
				_card:set_edition(_edition)
				_card:set_seal(_seal, true)
				area:emplace(_card)
				_card:start_materialize()
				TW_BL.utils.resize_card(_card, self.card_scale)
			end
			TW_BL.utils.reset_cards_score(area, true)
			SMODS.OPENED_BOOSTER._twbl_interactive_area = area
			TW_BL.chat_commands.set({
				command = "target",
				command_max_uses = 1,
				reset_command_use = true,
			})
			TW_BL.e_mitter.on("new_provider_command", function(event)
				local target_card = TW_BL.utils.command_card(area, event)
				if
					target_card
					and TW_BL.chat_commands.default_command_check(event, {
						command = "target",
						can_use_command = true,
						increment_command_use = true,
					})
				then
					TW_BL.utils.vote_for_card(target_card, event, nil, self.card_scale)
				end
			end, {
				key = "interactive_action",
				tags = {
					on_run = true,
				},
			})
			TW_BL.UI.top_booster_panel.show(function()
				return TW_BL.UI.voting_with_area_UIBox({
					w = false,
					minw = 2,
					status = false,
					items = {
						{
							command = TW_BL.L.command_with_arg("target", "pos_Card_singular"),
							text = localize({ type = "variable", key = "twbl_interactive_Standard_single", vars = {} }),
							description = TW_BL.L.command_use_limits(1),
							minw = 5,
						},
					},
					area = area,
					area_position = "bottom",
				})
			end, true)
		end,
		exit = function(self, card, center, exit_func)
			local area = SMODS.OPENED_BOOSTER._twbl_interactive_area
			local _card, _index = TW_BL.utils.get_most_voted_card(area, "twbl_interactive_winner")
			TW_BL.utils.reset_cards_score(area, true)
			for _, __card in ipairs(area.cards) do
				if __card ~= _card then
					__card:start_dissolve()
				end
			end
			if _card then
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 1,
					func = function()
						area:remove_card(_card)
						TW_BL.utils.resize_card(_card, 1 / self.card_scale)
						G.playing_card = (G.playing_card and G.playing_card + 1) or 1
						G.deck:emplace(_card)
						play_sound("card1", 0.8, 0.6)
						play_sound("generic1")
						_card.playing_card = G.playing_card
						_card:add_to_deck()
						table.insert(G.playing_cards, _card)
						G.deck.config.card_limit = G.deck.config.card_limit + 1
						SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
						return true
					end,
				}))
				exit_func()
			end
		end,
	},
	["Arcana"] = {
		rate = 0.4,
		spectral_rate = 0.15,

		card_scale = 1 / 2.5,

		open = function(self, card, center)
			local mode = "multiple"
			-- local mode = pseudorandom("twbl_sticker_interactive_single") > 8 and "single" or "multiple"
			SMODS.OPENED_BOOSTER._twbl_interactive_mode = mode
			if mode == "multiple" then
				local area = CardArea(
					0,
					0,
					G.CARD_W / (2.5 * self.card_scale * 2) * 4,
					0.55 * 1.5,
					{ card_limit = 4, type = "title_2", highlight_limit = 0 }
				)
				function area:align_cards(...)
					CardArea.align_cards(self, ...)
					for _index, __card in ipairs(self.cards or {}) do
						if not __card.states.drag.is then
							__card.T.x = self.T.x + self.T.w / (self.config.card_limit + 1) * (_index - 1)
						end
					end
				end

				local banned_cards = {
					c_ankh = true,
					c_hex = true,
					c_ectoplasm = true,
				}

				local _tarot_pool, tarot_pool_key = get_current_pool("Tarot", nil, nil, "twbl_interactive_pool")
				local tarot_pool = TW_BL.utils.table_shallow_copy(_tarot_pool)
				local _spectral_pool, spectral_pool_key =
					get_current_pool("Spectral", nil, nil, "twbl_interactive_pool")
				local spectral_pool =
					TW_BL.utils.table_shallow_copy(TW_BL.utils.table_filter(_spectral_pool, function(v)
						return not banned_cards[v]
					end))

				local rolled_centers = {}
				for i = 1, 4 do
					local card_pool, card_pool_key = tarot_pool, tarot_pool_key
					if
						self.spectral_rate
						> pseudorandom("twbl_sticker_interactive_card_pool" .. G.GAME.round_resets.ante)
					then
						card_pool, card_pool_key = spectral_pool, spectral_pool_key
					end
					card_pool = TW_BL.utils.table_filter(card_pool, function(v)
						return not rolled_centers[v]
					end)
					local _center = pseudorandom_element(
						card_pool,
						pseudoseed("twbl_sticker_interactive_choice" .. G.GAME.round_resets.ante)
					)

					if SMODS.size_of_pool(card_pool) == 0 then
						table.insert(card_pool, "c_fool")
					end

					local it = 1
					while _center == "UNAVAILABLE" do
						it = it + 1
						_center = pseudorandom_element(card_pool, pseudoseed(card_pool_key .. "_resample" .. it))
					end

					rolled_centers[_center] = true

					local _card = SMODS.create_card({
						key = _center,
						area = area,
						bypass_discovery_center = true,
					})

					area:emplace(_card)
					_card:start_materialize()
					TW_BL.utils.resize_card(_card, self.card_scale)
				end
				TW_BL.utils.reset_cards_score(area, true)
				SMODS.OPENED_BOOSTER._twbl_interactive_area = area
				TW_BL.chat_commands.set({
					command = "target",
					command_max_uses = 1,
					reset_command_use = true,
				})
				TW_BL.e_mitter.on("new_provider_command", function(event)
					local target_card = TW_BL.utils.command_card(area, event)
					if
						target_card
						and TW_BL.chat_commands.default_command_check(event, {
							command = "target",
							can_use_command = true,
							increment_command_use = true,
						})
					then
						TW_BL.utils.vote_for_card(target_card, event, nil, self.card_scale)
					end
				end, {
					key = "interactive_action",
					tags = {
						on_run = true,
					},
				})
				TW_BL.UI.top_booster_panel.show(function()
					return TW_BL.UI.voting_with_area_UIBox({
						w = false,
						minw = 2,
						status = false,
						items = {
							{
								command = TW_BL.L.command_with_arg("target", "pos_Consumeable_singular"),
								text = localize({
									type = "variable",
									key = "twbl_interactive_ArcanaSpectral_multiple",
									vars = {},
								}),
								description = TW_BL.L.command_use_limits(1),
							},
						},
						area = area,
						area_position = "right",
					})
				end, true)
			else
			end
		end,
		exit = function(self, card, center, exit_func)
			local area = SMODS.OPENED_BOOSTER._twbl_interactive_area
			local mode = SMODS.OPENED_BOOSTER._twbl_interactive_mode
			if mode == "multiple" then
				local _card, _index = TW_BL.utils.get_most_voted_card(area, "twbl_interactive_winner")
				TW_BL.utils.reset_cards_score(area, true)
				for _, __card in ipairs(area.cards) do
					if __card ~= _card then
						__card:start_dissolve()
					end
				end
				if _card then
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 1,
						func = function()
							try_to_use_card(_card, self.card_scale, exit_func)
							return true
						end,
					}))
				else
					exit_func()
				end
			end
		end,
	},
}
effect_options["Spectral"] = effect_options["Arcana"]

SMODS.Atlas({
	key = "twbl_sticker_atlas_interactive",
	px = 71,
	py = 95,
	path = "stickers/interactive.png",
})

SMODS.Sticker({
	key = "interactive",
	badge_colour = HEX("8e15ad"),
	config = {},
	rate = 0,
	discovered = true,

	atlas = "twbl_sticker_atlas_interactive",

	in_pool = function()
		return false
	end,
	should_apply = function(self, card, center, area, bypass_roll)
		if TW_BL.b_is_in_multiplayer() then
			return false
		end
		if card.ability and card.ability.twbl_sticker_interactive_checked then
			return false
		end
		if not card.ability then
			card.ability = {}
		end
		card.ability.twbl_sticker_interactive_checked = true
		return TW_BL.cc.interactive_sticker.value > 1
			and center.set == "Booster"
			and effect_options[center.kind]
			and (
				bypass_roll
				or TW_BL.cc.interactive_sticker.value == 3
				or (
					TW_BL.cc.interactive_sticker.value == 2
					and (effect_options[center.kind].rate or 0)
						> pseudorandom(pseudoseed("twbl_sticker_interactive_natural"))
				)
			)
	end,

	twbl_naturally_apply = function(self, card, center, area, bypass_roll)
		if self:should_apply(card, center, area, bypass_roll) then
			self:apply(card, true)
			return true
		end
	end,

	twbl_on_booster_open = function(self, card)
		local center = card.config.center
		local kind = center.kind
		if kind and effect_options[kind] then
			effect_options[kind]:open(card, center)
		end
	end,
	twbl_on_booster_exit = function(self, card, _exit_func)
		if G.GAME.pack_choices then
			G.GAME.pack_choices = 0
		end

		local exited = false
		local exit_func = function()
			if exited then
				return
			end
			exited = true
			_exit_func()
		end
		stop_use()
		TW_BL.e_mitter.off("new_provider_command", "interactive_action")

		local center = card.config.center
		local kind = center.kind

		if kind and effect_options[kind] then
			effect_options[kind]:exit(card, center, exit_func)
		else
			exit_func()
		end
	end,
})

local end_consumeable_ref = G.FUNCS.end_consumeable
function G.FUNCS.end_consumeable(...)
	if G.STATE == G.STATES.SMODS_BOOSTER_OPENED and SMODS.OPENED_BOOSTER then
		if SMODS.OPENED_BOOSTER.ability.twbl_interactive and not SMODS.OPENED_BOOSTER.twbl_interactive_consumed then
			local args = { ... }
			SMODS.Stickers["twbl_interactive"]:twbl_on_booster_exit(SMODS.OPENED_BOOSTER, function()
				G.E_MANAGER:add_event(Event({
					func = function()
						G.E_MANAGER:add_event(Event({
							func = function()
								TW_BL.UI.top_booster_panel.hide()
								end_consumeable_ref(unpack(args))
								return true
							end,
						}))
						return true
					end,
				}))
			end)
			SMODS.OPENED_BOOSTER.twbl_interactive_consumed = true
			return
		end
	end
	return end_consumeable_ref(...)
end
