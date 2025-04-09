local nativefs = require("nativefs")

local blinds_to_load = {
	"utility/blank",
	"utility/nope",

	"joker-modifiers/banana",
	"joker-modifiers/eraser",
	"joker-modifiers/expiration",
	"joker-modifiers/lock",
	"joker-modifiers/lucky_wheel",
	"joker-modifiers/pin",
	"joker-modifiers/sketch",
	"joker-modifiers/taxes",
	"joker-modifiers/vaporation",

	"shop-modifiers/misstock",
	"shop-modifiers/greed",

	"round-modifiers/chaos",
	"round-modifiers/chisel",
	"round-modifiers/clock",
	"round-modifiers/flashlight",
	"round-modifiers/precision",
	"round-modifiers/trash_can",
	"round-modifiers/incrementor",

	"lore/circus",
	"lore/isaac",
	"lore/jimbo",
	"lore/moon",
	"lore/sparkle",
	"lore/university",

	-- "card-packs/garden",
	"card-packs/vacation",

	"showdown/plum_hammer",
}

function twbl_init_blinds()
	local BLINDS = {
		--- @type string[]
		loaded = {},
		--- @type string[]
		regular = {},
		--- @type string[]
		showdown = {},

		storage = {},

		--- @type string
		chat_blind = nil,
		--- @type number
		blinds_to_vote = 3,
	}

	TW_BL.BLINDS = BLINDS

	function BLINDS.create(blind_definition, atlas_definition, no_register)
		local key = blind_definition.key
		SMODS.Atlas(atlas_definition or {
			key = "twbl_blind_atlas_" .. key,
			px = 34,
			py = 34,
			path = "blinds/" .. key .. ".png",
			atlas_table = "ANIMATION_ATLAS",
			frames = 21,
		})
		blind_definition.key = TW_BL.BLINDS.get_raw_key(key)
		blind_definition.atlas = "twbl_blind_atlas_" .. key
		blind_definition.pos = { x = 0, y = 0 }
		local blind = SMODS.Blind(blind_definition)
		if not no_register then
			return TW_BL.BLINDS.register(blind)
		else
			return blind
		end
	end

	function BLINDS.register(blind)
		table.insert(blind.showdown and BLINDS.showdown or BLINDS.regular, blind.key)
		table.insert(BLINDS.loaded, blind.key)
		BLINDS.storage[blind.key] = blind
		return blind
	end

	--- @param blind_name string
	--- @return string
	function BLINDS.get_raw_key(blind_name)
		return "twbl_" .. blind_name
	end

	--- @param blind_name string
	--- @return string
	function BLINDS.get_key(blind_name)
		return "bl_" .. BLINDS.get_raw_key(blind_name)
	end

	function BLINDS.get(name)
		return BLINDS.storage[BLINDS.get_key(name)]
	end

	function BLINDS.is_active_pool_tags(game_tags, blind_tags)
		game_tags = game_tags or {}
		blind_tags = blind_tags or {}

		local game_tags_size = 0
		for k, v in pairs(game_tags) do
			if v then
				game_tags_size = game_tags_size + 1
			end
		end

		if game_tags_size == 0 and #blind_tags == 0 then
			return true
		end

		for _, tag in ipairs(blind_tags) do
			if game_tags[tag] then
				return true
			end
		end
		return false
	end

	function BLINDS.can_natural_appear(blind)
		if not TW_BL.SETTINGS.current.natural_blinds or not blind.boss then
			return false
		end
		if blind.config and blind.config.tw_bl and blind.config.tw_bl.one_time then
			local key = "blind_encountered_" .. blind.key
			if TW_BL.G[key] then
				return false
			end
		end
		return math.max(G.GAME.round_resets.ante, 1) >= (blind.boss.min or 1)
	end

	function BLINDS.can_appear_in_voting(blind)
		if not blind.boss or not blind.config or not blind.config.tw_bl then
			return false
		end
		local range_to_check = blind.config.tw_bl
		return (not range_to_check.min or range_to_check.min <= math.max(0, G.GAME.round_resets.ante))
			and (not range_to_check.max or range_to_check.max >= math.max(0, G.GAME.round_resets.ante))
	end

	assert(load(nativefs.read(TW_BL.current_mod.path .. "additions/blinds/twitch_chat.lua")))()
	for _, blind_name in ipairs(blinds_to_load) do
		assert(load(nativefs.read(TW_BL.current_mod.path .. "additions/blinds/" .. blind_name .. ".lua")))()
	end
	BLINDS.chat_blind = BLINDS.get_key("twitch_chat")

	--- Get one random boss blind from pool
	--- @param pool { [string]: boolean } Pool to choose from
	--- @return string
	function BLINDS.get_random_boss_blind(pool)
		local eligible_bosses = {}
		for k, v in pairs(pool) do
			if v then
				eligible_bosses[k] = 0
			end
		end
		if TW_BL.SETTINGS.current.blind_pool_type < 2 then
			-- Remove already used blinds
			local min_use = math.huge
			for k, v in pairs(G.GAME.bosses_used) do
				if eligible_bosses[k] then
					eligible_bosses[k] = v
					if eligible_bosses[k] <= min_use then
						min_use = eligible_bosses[k]
					end
				end
			end
			for k, v in pairs(eligible_bosses) do
				if eligible_bosses[k] then
					if eligible_bosses[k] > min_use then
						eligible_bosses[k] = nil
					end
				end
			end
		end
		local _, boss = pseudorandom_element(eligible_bosses, pseudoseed("twbl_boss_pick"))
		-- If not bosses in pool, return blank
		if not boss then
			return TW_BL.BLINDS.get_key("blank")
		end
		G.GAME.bosses_used[boss] = (G.GAME.bosses_used[boss] or 0) + 1
		return boss
	end

	--- Get specified amount of random boss blinds from pool
	--- @param pool string[] List to choose from
	--- @param count number Amount of blinds to choose
	--- @return string[]
	function BLINDS.get_list_of_random_boss_blinds(pool, count)
		local current_pool = {}
		for _, v in ipairs(pool) do
			current_pool[v] = true
		end
		local result = {}
		for i = 1, count do
			local boss = BLINDS.get_random_boss_blind(current_pool)
			if #current_pool <= 1 then
				-- This means that single picked blind remains, we need new pool
				for _, v in ipairs(pool) do
					current_pool[v] = true
				end
			end
			table.insert(result, boss)
			if TW_BL.SETTINGS.current.blind_pool_type < 3 then
				for _, v in ipairs(result) do
					-- No repeat bosses
					current_pool[v] = nil
				end
			end
		end
		return result
	end

	--- Set game blind safely
	--- @param blind_type 'Small' | 'Big' | 'Boss' Blind to replace
	--- @param blind_name string Blind key to set
	function BLINDS.replace_blind(blind_type, blind_name)
		local blind_type_lower = string.lower(blind_type)
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

	--- Save voting blinds in game object
	--- @param blinds string[] | nil List of blinds
	--- @return boolean `true` if successfully, `false` if `G.GAME` is not ready
	function BLINDS.set_voting_blinds_to_game(blinds)
		if G.GAME then
			TW_BL.G.voting_blinds = blinds
			return true
		else
			return false
		end
	end

	--- Get voting blinds from game object
	--- @param pool_type integer Pool type to choose from
	--- @param generate_if_missing boolean Generate new list if not present
	--- @return string[]|nil
	function BLINDS.get_voting_blinds_from_game(pool_type, generate_if_missing)
		if G.GAME then
			if TW_BL.G.voting_blinds then
				return TW_BL.G.voting_blinds
			end

			local ante_offset = 0
			if TW_BL.SETTINGS.current.blind_frequency == 2 then
				ante_offset = 1
			end

			if generate_if_missing then
				return BLINDS.generate_new_voting_blinds(pool_type, ante_offset, BLINDS.blinds_to_vote, {}, true)
			end

			return nil
		else
			return nil
		end
	end

	--- Get new blinds pool
	--- @param pool_type integer Pool type to choose from
	--- @param ante_offset integer Difference between current ante and target ante
	--- @return string[]
	function BLINDS.get_blinds_pool(pool_type, ante_offset, tags)
		ante_offset = ante_offset or 0
		local eligible_bosses = {}

		local current_ante = math.max(1, G.GAME.round_resets.ante)
		local target_ante = math.max(1, G.GAME.round_resets.ante + ante_offset)
		local final_boss = target_ante >= 2 and target_ante % G.GAME.win_ante == 0

		local include_twitch_blinds = false
		local include_not_twitch_blinds = false

		if pool_type == 1 then
			-- Only twitch blinds
			include_twitch_blinds = true
			-- TODO: create some twitch final blinds to fill pool
			include_not_twitch_blinds = final_boss
		elseif pool_type == 2 then
			-- All other blinds
			include_twitch_blinds = false
			include_not_twitch_blinds = true
		elseif pool_type == 3 then
			-- All blinds
			include_not_twitch_blinds = true
			include_twitch_blinds = true
		else
			-- If I miss something
			include_not_twitch_blinds = true
			include_twitch_blinds = true
		end

		for k, v in pairs(G.P_BLINDS) do
			local extra = (v.config and v.config.tw_bl) or {}
			local is_twitch_blind = extra.twitch_blind or extra.in_pool or false
			if not v.boss then
				-- Skip no boss blinds
			elseif extra.ignore then
				-- Can't be set to vote (i.e. very specific boss like The Clock from Cryptid)
			elseif is_twitch_blind and not include_twitch_blinds then
				-- Skip twitch blind if we don't need it
			elseif not is_twitch_blind and not include_not_twitch_blinds then
				-- Skip other blind if we don't need it
			else
				local is_correct_boss_type = (v.boss.showdown or false) == final_boss
				-- TODO: finish tags idea
				local is_active_tags = true or extra.ignore_tags_check or BLINDS.is_active_pool_tags(tags, extra.tags)
				local config_to_check = is_twitch_blind and extra or v
				local range_to_check = is_twitch_blind and extra or v.boss
				local can_appear = false

				if
					type(config_to_check.in_pool) == "function"
					and (config_to_check.ignore_showdown_check or is_correct_boss_type)
					and is_active_tags
				then
					-- Use in_pool function
					-- Is this safe?
					G.GAME.round_resets.ante = G.GAME.round_resets.ante + ante_offset
					can_appear = config_to_check.in_pool(v) or false
					G.GAME.round_resets.ante = G.GAME.round_resets.ante - ante_offset
				elseif final_boss then
					-- Add final boss blind
					can_appear = is_correct_boss_type and is_active_tags
				else
					-- Add if mets range criteria
					can_appear = is_correct_boss_type
						and is_active_tags
						and (not range_to_check.min or range_to_check.min <= target_ante)
						and (not is_twitch_blind or (not range_to_check.max or range_to_check.max >= target_ante))
				end

				if can_appear then
					eligible_bosses[k] = true
				end
			end
		end

		for k, v in pairs(G.GAME.banned_keys) do
			if eligible_bosses[k] then
				eligible_bosses[k] = nil
			end
		end

		-- Prevent softlock
		eligible_bosses[BLINDS.chat_blind] = nil

		local result = {}
		for k, v in pairs(eligible_bosses) do
			table.insert(result, k)
		end

		return result
	end

	--- Generate new list of blinds for voting
	--- @param pool_type integer Pool type to choose from
	--- @param ante_offset integer Difference between current ante and target ante
	--- @param amount integer Amount of blinds to choose
	--- @param write boolean Save result in game object
	--- @return string[]|nil
	function BLINDS.generate_new_voting_blinds(pool_type, ante_offset, amount, tags, write)
		local pool = BLINDS.get_blinds_pool(pool_type, ante_offset, tags)
		local new_list = BLINDS.get_list_of_random_boss_blinds(pool, amount)
		if not write or BLINDS.set_voting_blinds_to_game(new_list) then
			return new_list
		end
		return nil
	end

	--

	TW_BL.EVENTS.add_listener("twitch_command", "chat_commands_init", function(command, username, variant)
		if command == "vote" and TW_BL.G.voting_blinds then
			if TW_BL.CHAT_COMMANDS.can_vote_for_variant("voting_blind", variant) then
				TW_BL.CHAT_COMMANDS.increment_command_use(command, username)
				TW_BL.CHAT_COMMANDS.increment_vote_score("voting_blind", variant)
				TW_BL.UI.update_panel("game_top", nil, false)
				TW_BL.UI.create_panel_notify("game_top", nil, username)
			end
		end
	end)

	return BLINDS
end
