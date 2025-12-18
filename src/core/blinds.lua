TW_BL.blinds = {}

function TW_BL.blinds.is_in_range(v, check_max)
	local target_ante = math.max(1, G.GAME.round_resets.ante)
	local showdown = target_ante >= 2 and target_ante % G.GAME.win_ante == 0
	local ignore_showdown_check = v.ignore_showdown_check
	local combined_boss = TW_BL.utils.table_merge({}, v.boss or {}, v.twbl_boss or {})
	local is_showdown_boss = combined_boss.showdown or false
	if check_max and combined_boss.max and combined_boss.max < target_ante then
		return false
	end
	return ignore_showdown_check
		or (not is_showdown_boss and (combined_boss.min <= target_ante and not showdown))
		or is_showdown_boss and showdown
end

--- Set game blind safely
--- @param blind_type 'Small' | 'Big' | 'Boss' Blind to replace
--- @param blind_name string Blind key to set
function TW_BL.blinds.replace_blind(blind_type, blind_name)
	local blind_type_lower = string.lower(blind_type)
	if not G.GAME.round_resets.blind_choices[blind_type] then
		return
	end
	if not (G.blind_select_opts and G.blind_select_opts[blind_type_lower]) then
		G.GAME.round_resets.blind_choices[blind_type] = blind_name
		return
	end
	stop_use()
	G.CONTROLLER.locks.boss_reroll = true
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			play_sound("other1")
			G.blind_select_opts[blind_type_lower]:set_role({ xy_bond = "Weak" })
			G.blind_select_opts[blind_type_lower].alignment.offset.y = 20
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.3,
		func = function()
			local par = G.blind_select_opts[blind_type_lower].parent
			G.GAME.round_resets.blind_choices[blind_type] = blind_name
			G.blind_select_opts[blind_type_lower]:remove()
			G.blind_select_opts[blind_type_lower] = UIBox({
				T = { par.T.x, 0, 0, 0 },
				definition = {
					n = G.UIT.ROOT,
					config = { align = "cm", colour = G.C.CLEAR },
					nodes = {
						UIBox_dyn_container(
							{ create_UIBox_blind_choice(blind_type) },
							false,
							get_blind_main_colour(blind_type),
							mix_colours(G.C.BLACK, get_blind_main_colour(blind_type), 0.8)
						),
					},
				},
				config = {
					align = "bmi",
					offset = { x = 0, y = G.ROOM.T.y + 9 },
					major = par,
					xy_bond = "Weak",
				},
			})
			par.config.object = G.blind_select_opts[blind_type_lower]
			par.config.object:recalculate()
			G.blind_select_opts[blind_type_lower].parent = par
			G.blind_select_opts[blind_type_lower].alignment.offset.y = 0

			G.E_MANAGER:add_event(Event({
				blocking = false,
				trigger = "after",
				delay = 0.5,
				func = function()
					G.CONTROLLER.locks.boss_reroll = nil
					return true
				end,
			}))

			save_run()
			return true
		end,
	}))
end

--- @param args? { allow_repeats?: boolean, blind_pool_type?: number, target_ante?: number }
function TW_BL.blinds.get_blinds_pool(args)
	args = args or {}

	local current_ante = math.max(1, G.GAME.round_resets.ante)
	local target_ante = math.max(1, args.target_ante or G.GAME.round_resets.ante)
	local showdown = target_ante >= 2 and target_ante % G.GAME.win_ante == 0

	local include_twitch_blinds = false
	local include_not_twitch_blinds = false

	if args.blind_pool_type == 1 then
		-- Only twitch blinds
		include_twitch_blinds = true
		-- But we use every showdown blind
		include_not_twitch_blinds = showdown
	elseif args.blind_pool_type == 2 then
		-- All other blinds
		include_twitch_blinds = false
		include_not_twitch_blinds = true
	elseif args.blind_pool_type == 3 then
		-- All blinds
		include_not_twitch_blinds = true
		include_twitch_blinds = true
	else
		-- If I miss something
		include_not_twitch_blinds = true
		include_twitch_blinds = true
	end

	G.GAME.bosses_used = G.GAME.bosses_used or {}
	local min_use = math.huge

	local result_blinds = {}
	for k, v in pairs(G.P_BLINDS) do
		if
			not (
				not (v.twbl_boss or v.boss)
				-- skip banned blinds
				or (G.GAME.banned_keys or {})[k]
				-- skip bosses which shouldn't appear in voting at all
				or v.twbl_ignore
				-- skip twitch blind if we dont need it
				or (v.twbl_is_twitch_blind and not include_twitch_blinds)
				-- skip other blind if we dont need it
				or (not v.twbl_is_twitch_blind and not include_not_twitch_blinds)
				-- skip blinds which only once per run
				or (v.twbl_once_per_run and (TW_BL.G.blinds_encountered or {})[k])
			)
		then
			local ignore_showdown_check = v.ignore_showdown_check
			local combined_boss = TW_BL.utils.table_merge({}, v.boss or {}, v.twbl_boss or {})
			local is_showdown_boss = combined_boss.showdown or false
			local in_pool_func = v.in_pool
			if v.twbl_is_twitch_blind then
				in_pool_func = v.twbl_in_pool
			end

			local can_appear = false
			if ignore_showdown_check then
				can_appear = true
			elseif in_pool_func and type(in_pool_func) == "function" then
				if is_showdown_boss == showdown then
					can_appear = true
				end
			elseif not is_showdown_boss and (combined_boss.min <= target_ante and not showdown) then
				can_appear = true
			elseif is_showdown_boss and showdown then
				can_appear = true
			end

			if can_appear then
				G.GAME.round_resets.ante = target_ante
				if type(in_pool_func) == "function" then
					can_appear = in_pool_func(v) or false
				end
				G.GAME.round_resets.ante = current_ante
			end
			if can_appear then
				result_blinds[k] = G.GAME.bosses_used[k] or 0
				min_use = math.min(min_use, result_blinds[k])
			end
		end
	end

	if not args.allow_repeats then
		for k, v in pairs(result_blinds) do
			if v > min_use then
				result_blinds[k] = nil
			end
		end
	end

	return result_blinds
end

--- @param args? { increment_usage?: boolean, allow_repeats?: boolean, blind_pool_type?: number, target_ante?: number }
function TW_BL.blinds.poll_blind(args, duplicates_list)
	args = args or {}
	duplicates_list = duplicates_list or {}
	local pool = TW_BL.blinds.get_blinds_pool(args)

	for k, _ in pairs(duplicates_list) do
		pool[k] = nil
	end

	local pullable = {}
	local total_weight = 0
	for key, _ in pairs(pool) do
		local blind = G.P_BLINDS[key]
		local weight = (
			type(blind.twbl_get_weight) == "function"
			and blind:twbl_get_weight(blind.twbl_default_weight or blind.default_weight or 5)
		)
			or type(blind.get_weight) == "function" and blind:get_weight(blind.default_weight)
			or (blind.default_weight or 5)
		total_weight = total_weight + weight
		table.insert(pullable, {
			weight = weight,
			key = key,
		})
	end

	-- GAMBLING!
	local roll = pseudorandom("twbl_boss_poll" .. (args.target_ante or G.GAME.round_resets.ante))

	if #pullable > 0 then
		local weight_i = 0
		for _, item in ipairs(pullable) do
			weight_i = weight_i + item.weight
			if roll > 1 - (weight_i / total_weight) then
				if args.increment_usage then
					G.GAME.bosses_used = G.GAME.bosses_used or {}
					G.GAME.bosses_used[item.key] = (G.GAME.bosses_used[item.key] or 0) + 1
				end
				return item.key, false
			end
		end
	end

	return "bl_twbl_blank", true
end

--- @param args? { amount?: number, increment_usage?: boolean, allow_repeats?: boolean, blind_pool_type?: number, target_ante?: number }
--- @return string[]
function TW_BL.blinds.poll_blinds(args, duplicates_list)
	args = args or {}
	local result = {}
	duplicates_list = duplicates_list or {}
	for i = 1, (args.amount or 3) do
		local blind, is_fallback = TW_BL.blinds.poll_blind(args, duplicates_list)
		duplicates_list[blind] = true
		table.insert(result, blind)
	end
	return result
end

--

local old_reset_blinds = reset_blinds
function reset_blinds(...)
	TW_BL.FLAGS.reset_blinds = true
	local result = old_reset_blinds(...)
	TW_BL.FLAGS.reset_blinds = nil
	return result
end

local get_new_boss_ref = get_new_boss
function get_new_boss(...)
	TW_BL.G = {}

	if TW_BL.b_is_in_multiplayer() then
		return get_new_boss_ref(...)
	end

	local caused_by_reset = TW_BL.FLAGS.reset_blinds
	local is_first_boss = not G.GAME.round_resets.blind_choices.Boss

	local result = nil
	local start_voting_process = false
	local voting_ante_offset = 0
	local stop_voting_process = false

	-- If no data in save, then assume that we don't see chat at most 1 ante
	if not TW_BL.G.blind_chat_antes then
		TW_BL.G.blind_chat_antes = is_first_boss and 0 or 1
	end

	-- If any non-boss blind is chat blind, remove it
	for type, choice in pairs(G.GAME.round_resets.blind_choices) do
		if type ~= "Boss" and choice == TW_BL.CHAT_BLIND then
			G.GAME.round_resets.blind_choices[type] = get_new_boss_ref(...)
		end
	end

	if caused_by_reset or is_first_boss then
		if TW_BL.cc.blind_voting_frequency.value == 1 then
			-- Disabled by settings
			result = get_new_boss_ref(...)
			stop_voting_process = true
		elseif TW_BL.cc.blind_voting_frequency.value == 2 then
			start_voting_process = true
			if is_first_boss or TW_BL.G.blind_chat_antes < 1 then
				-- If in this ante blind was chat, return vanilla one
				voting_ante_offset = 1
				result = get_new_boss_ref(...)
			else
				-- If previous was no chat, return chat
				result = TW_BL.CHAT_BLIND
			end
		elseif TW_BL.cc.blind_voting_frequency.value == 3 then
			-- Forced by settings
			start_voting_process = true
			result = TW_BL.CHAT_BLIND
		else
			-- If I miss something
			result = get_new_boss_ref(...)
			stop_voting_process = true
		end
	else
		TW_BL.G.nope_from_reroll = TW_BL.G.nope_from_reroll or 0
		local can_reroll_to_nope = TW_BL.G.nope_from_reroll < 1 and G.GAME.round_resets.ante % G.GAME.win_ante ~= 0
		if G.GAME.round_resets.blind_choices.Boss == TW_BL.CHAT_BLIND then
			if can_reroll_to_nope then
				-- Reroll to Nope!
				TW_BL.G.nope_from_reroll = TW_BL.G.nope_from_reroll + 1
				result = "bl_twbl_nope"
				stop_voting_process = true
			else
				-- Can't reroll chat
				result = TW_BL.CHAT_BLIND
			end
		elseif TW_BL.G.blind_chat_antes == 0 then
			if can_reroll_to_nope then
				-- Reroll to Nope!
				TW_BL.G.nope_from_reroll = TW_BL.G.nope_from_reroll + 1
				result = "bl_twbl_nope"
				stop_voting_process = true
			else
				-- Can't reroll blind selected by chat
				-- Subject to change?
				result = G.GAME.round_resets.blind_choices.Boss
			end
		else
			-- Reroll vanilla boss as usual
			result = get_new_boss_ref(...)
		end
	end

	if caused_by_reset or is_first_boss then
		-- Count how many antes ago was chat blind
		TW_BL.G.blind_chat_antes = (result == TW_BL.CHAT_BLIND and 0) or (TW_BL.G.blind_chat_antes + 1)
	end

	if start_voting_process then
		TW_BL.blind_voting.start_blind_voting(G.GAME.round_resets.ante + voting_ante_offset, true)
	elseif stop_voting_process then
		TW_BL.blind_voting.stop_blind_voting()
	end

	return result
end

local select_blind_ref = G.FUNCS.select_blind
function G.FUNCS.select_blind(...)
	local args = { ... }
	TW_BL.G = TW_BL.G or {}
	if G.GAME.blind_on_deck and G.GAME.round_resets.blind_choices[G.GAME.blind_on_deck] then
		local current_blind = SMODS.Blinds[G.GAME.round_resets.blind_choices[G.GAME.blind_on_deck] or ""]
		if
			current_blind
			and type(current_blind.twbl_select_blind) == "function"
			and current_blind:twbl_select_blind(args, unpack(args))
		then
			return
		end
	end
	return select_blind_ref(...)
end

local old_load = Blind.load
function Blind:load(...)
	local result = old_load(self, ...)
	if self.config.blind and type(self.config.blind.twbl_load) == "function" then
		self.config.blind:twbl_load()
	end
	return result
end

local old_set = Blind.set_blind
function Blind:set_blind(...)
	local result = old_set(self, ...)
	if self.config and self.config.blind and self.config.blind.key then
		TW_BL.G.blinds_encountered = TW_BL.G.blinds_encountered or {}
		TW_BL.G.blinds_encountered[self.config.blind.key] = true
	end
	return result
end

local old_update_round_eval = Game.update_round_eval
function Game:update_round_eval(...)
	if
		not G.STATE_COMPLETE
		and G.GAME.blind
		and G.GAME.blind.config.blind
		and type(G.GAME.blind.config.blind.twbl_save_before_eval) == "function"
	then
		G.GAME.blind.config.blind:twbl_save_before_eval()
	end
	return old_update_round_eval(self, ...)
end

TW_BL.refs.get_new_boss = get_new_boss_ref
TW_BL.refs.select_blind = select_blind_ref
