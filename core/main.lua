local nativefs = require("nativefs")

--- @class TwitchBlinds
--- @field G table<string, any> Place for run data
TwitchBlinds = setmetatable(Object:extend(), {
	__index = function(table, index)
		if index == "G" then
			return G.GAME and G.GAME.twbl or {}
		else
			return rawget(table, index)
		end
	end,
	__newindex = function(table, index, value)
		if index == "G" then
			if G.GAME then
				G.GAME.twbl = (G.GAME.twbl or value or {})
			end
		else
			rawset(table, index, value)
		end
	end,
})
TW_BL = TwitchBlinds

assert(load(nativefs.read(SMODS.current_mod.path .. "core/events.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/settings.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/blinds.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/stickers.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/chat_commands.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/ui.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "core/utilities.lua")))()

function TwitchBlinds:init()
	self.current_mod = SMODS.current_mod

	self.EVENTS = twbl_init_events()
	self.SETTINGS = twbl_init_settings()

	self.__DEV_MODE = self.SETTINGS.current.dev_mode

	self.UI = twbl_init_ui()
	self.BLINDS = twbl_init_blinds()
	self.STICKERS = twbl_init_stickers()
	self.CHAT_COMMANDS = twbl_init_chat_commands()

	TW_BL.CHAT_COMMANDS.collector:connect(TW_BL.SETTINGS.current.channel_name, true)

	self.UTILITIES = twbl_init_utilities()

	-- Overriding

	local main_menu_ref = Game.main_menu
	function Game:main_menu(...)
		TW_BL.G = {}
		main_menu_ref(self, ...)
		TW_BL:main_menu()
	end

	local love_update_ref = love.update
	function love.update(dt, ...)
		love_update_ref(dt, ...)
		TW_BL.EVENTS.process_dt(dt)
	end

	local get_new_boss_ref = get_new_boss
	function get_new_boss(...)
		TW_BL.G = {}
		local is_first_boss = not G.GAME.round_resets.blind_choices.Boss
		local caused_by_boss_defeate = (
			G.GAME.round_resets.blind_states.Small == "Upcoming" or G.GAME.round_resets.blind_states.Small == "Hide"
		)
			and G.GAME.round_resets.blind_states.Big == "Upcoming"
			and G.GAME.round_resets.blind_states.Boss == "Upcoming"

		local is_overriding = false

		local result = nil
		local start_voting_process = false
		local force_voting_process = false
		local voting_ante_offset = 0

		if not TW_BL.G.blind_chat_antes then
			-- If no data in save, then assume that we don't see chat at most 1 ante
			TW_BL.G.blind_chat_antes = is_first_boss and 0 or 1
		end

		if G.GAME.round_resets.blind_choices.Small == TW_BL.BLINDS.chat_blind then
			is_overriding = true
			G.GAME.round_resets.blind_choices.Small = get_new_boss_ref(...)
		end
		if G.GAME.round_resets.blind_choices.Big == TW_BL.BLINDS.chat_blind then
			is_overriding = true
			G.GAME.round_resets.blind_choices.Big = get_new_boss_ref(...)
		end

		if TW_BL.__DEV_MODE and TW_BL.SETTINGS.current.forced_blind then
			-- Dev mode: set boss
			start_voting_process = true
			force_voting_process = true
			result = TW_BL.BLINDS.chat_blind
		elseif caused_by_boss_defeate or is_first_boss then
			if TW_BL.SETTINGS.current.blind_frequency == 1 then
				-- Disabled by settings
				TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", false, true)
				result = get_new_boss_ref(...)
			elseif TW_BL.SETTINGS.current.blind_frequency == 2 then
				start_voting_process = true
				if is_first_boss or TW_BL.G.blind_chat_antes < 1 then
					-- If in this ante blind was chat, return vanilla one
					voting_ante_offset = 1
					force_voting_process = is_first_boss
					result = get_new_boss_ref(...)
				else
					-- If previous was no chat, return chat
					result = TW_BL.BLINDS.chat_blind
				end
			elseif TW_BL.SETTINGS.current.blind_frequency == 3 then
				-- Forced by settings
				start_voting_process = true
				force_voting_process = is_first_boss
				result = TW_BL.BLINDS.chat_blind
			else
				-- If I miss something
				result = get_new_boss_ref(...)
			end
		else
			if G.GAME.round_resets.blind_choices.Boss == TW_BL.BLINDS.chat_blind then
				-- Can't reroll chat
				result = TW_BL.BLINDS.chat_blind
			elseif TW_BL.G.blind_chat_antes == 0 then
				-- Can't reroll blind selected by chat
				-- Subject to change?
				result = G.GAME.round_resets.blind_choices.Boss
			else
				-- Reroll vanilla boss as usual
				result = get_new_boss_ref(...)
			end
		end

		if is_first_boss or caused_by_boss_defeate then
			-- Count how many antes ago was chat blind
			TW_BL.G.blind_chat_antes = (result == TW_BL.BLINDS.chat_blind and 0) or (TW_BL.G.blind_chat_antes + 1)
		end

		if start_voting_process and not is_overriding then
			if force_voting_process or not TW_BL.CHAT_COMMANDS.can_collect.vote then
				TW_BL.CHAT_COMMANDS.set_vote_variants(
					"voting_blind",
					TW_BL.CHAT_COMMANDS.get_vote_variants_for_blinds(),
					true
				)
				TW_BL.BLINDS.generate_new_voting_blinds(
					TW_BL.SETTINGS.current.pool_type,
					voting_ante_offset,
					TW_BL.BLINDS.blinds_to_vote,
					true
				)

				TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", true, true)
				TW_BL.CHAT_COMMANDS.toggle_max_uses("vote", 1, true)
				TW_BL.CHAT_COMMANDS.reset("voting_blind", "vote")
				TW_BL.UI.set_panel("game_top", "blind_voting_process", true, true)
			else
				TW_BL.UI.remove_panel("game_top", "blind_voting_process", true)
			end
		end

		return result
	end

	local select_blind_ref = G.FUNCS.select_blind
	function G.FUNCS.select_blind(...)
		local args = { ... }
		TW_BL.G = TW_BL.G or {}
		-- Replace with blind selected by chat (or use first if no votes)
		if G.GAME.blind_on_deck and G.GAME.round_resets.blind_choices[G.GAME.blind_on_deck] then
			local current_blind = G.GAME.round_resets.blind_choices[G.GAME.blind_on_deck]
			if current_blind == TW_BL.BLINDS.chat_blind then
				if G.GAME.blind_on_deck ~= "Boss" then
					-- If somehow chat is in non-boss position, then insert random boss here
					TW_BL.BLINDS.replace_blind(G.GAME.blind_on_deck, get_new_boss_ref())
					return
				end

				if TW_BL.EVENTS.request_delay(5, function()
					G.FUNCS.select_blind(unpack(args))
				end) then
					return
				end

				local blinds_to_choose =
					TW_BL.BLINDS.get_voting_blinds_from_game(TW_BL.SETTINGS.current.pool_type, true)
				if not blinds_to_choose then
					return select_blind_ref(...)
				end
				local win_variant, win_score, win_percent = TW_BL.CHAT_COMMANDS.get_vote_winner("voting_blind")
				local picked_blind = (
					TW_BL.__DEV_MODE
					and TW_BL.SETTINGS.current.forced_blind
					and TW_BL.BLINDS.loaded[TW_BL.SETTINGS.current.forced_blind]
				) or blinds_to_choose[tonumber(win_variant or "1")]

				TW_BL.BLINDS.set_voting_blinds_to_game(nil)
				TW_BL.CHAT_COMMANDS.set_vote_variants("voting_blind", {}, true)
				TW_BL.CHAT_COMMANDS.toggle_can_collect("vote", false, true)
				TW_BL.BLINDS.replace_blind(G.GAME.blind_on_deck, picked_blind)
				TW_BL.UI.remove_panel("game_top", "blind_voting_process", true)
				return
			elseif current_blind == TW_BL.BLINDS.get_key("lucky_wheel") then
				if
					pseudorandom(pseudoseed("twbl_wheels_nope"))
					> G.GAME.probabilities.normal
						/ G.P_BLINDS[TW_BL.BLINDS.get_key("lucky_wheel")].config.extra.nope_odds
				then
					TW_BL.BLINDS.replace_blind(G.GAME.blind_on_deck, TW_BL.BLINDS.get_key("nope"))
					return
				end
			end
		end
		return select_blind_ref(...)
	end
end

function TwitchBlinds:start_run()
	TW_BL.G = {}
	TW_BL.CHAT_COMMANDS.reset(true)
	TW_BL.CHAT_COMMANDS.get_vote_variants_from_game({})
	TW_BL.CHAT_COMMANDS.get_can_collect_from_game({})
	TW_BL.CHAT_COMMANDS.get_max_uses_from_game({
		vote = not TW_BL.__DEV_MODE,
	})

	TW_BL.UI.reset()
	TW_BL.UI.get_panels_from_game()

	TW_BL.CHAT_COMMANDS.set_enabled(true)
end

function TwitchBlinds:main_menu()
	TW_BL.CHAT_COMMANDS.set_enabled(false)
	TW_BL.CHAT_COMMANDS.reset(true)
end
