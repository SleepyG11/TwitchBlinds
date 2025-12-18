TW_BL.PLACEHOLDER_BLIND_ATLAS = "twbl_blind_atlas_placeholder"
SMODS.Atlas({
	key = TW_BL.PLACEHOLDER_BLIND_ATLAS,
	px = 34,
	py = 34,
	path = "blinds/chat.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

--

--- @class TW_BL.bootstrap_interactive_blind_args
--- @field connected_status_text? string|fun(): string
--- @field command string
--- @field command_max_uses? number
--- @field command_use_refresh_timeout? number
--- @field voting? boolean
--- @field set_vote_variants? fun(effects: table[]): string[]
--- @field delay_load? boolean
--- @field set_effects? fun(): table[]
--- @field apply_effect? fun(effect: table)
--- @field get_items fun(effects: table[], args: TW_BL.bootstrap_interactive_blind_args): table[]
--- @field on_new_provider_command? fun(event: table, args: TW_BL.bootstrap_interactive_blind_args, card?: Card): boolean?
--- @field cards_voting? boolean
--- @field get_cardarea? fun(): CardArea

---
---@param blind any
---@param args TW_BL.bootstrap_interactive_blind_args
function TW_BL.blinds.bootstrap_interactive_blind(blind, args)
	args = args or {}
	local old_twbl_load = blind.twbl_load
	blind.twbl_load = function(self)
		if old_twbl_load then
			old_twbl_load(self)
		end
		if args.cards_voting then
			TW_BL.utils.reset_cards_score(args.get_cardarea())
		end
		TW_BL.blind_voting.stop_blind_voting(true)
		TW_BL.chat_commands.set({
			command = args.command,
			command_max_uses = args.command_max_uses or false,
			vote_id = args.voting and "blind_action" or nil,
			set_vote_variants = args.voting and args.set_vote_variants(G.GAME.blind.effect.effects or {}) or nil,
			reset_command_use = true,
			reset_vote_score = true,
		})
		local connected_status_text = (
			type(args.connected_status_text) == "function" and (args.connected_status_text() or "ERROR")
		) or args.connected_status_text
		if args.voting then
			TW_BL.UI.top_screen_panel.show(function()
				return TW_BL.UI.blind_action_voting_UIBox({
					status = true,
					connected_status_text = connected_status_text,
					command = args.command,
					items = args.get_items(G.GAME.blind.effect.effects or {}, args),
				})
			end, true)
		else
			TW_BL.UI.top_screen_panel.show(function()
				return TW_BL.UI.voting_UIBox({
					status = true,
					connected_status_text = connected_status_text,
					items = args.get_items({}, args),
				})
			end, true)
		end
		TW_BL.e_mitter.on("new_provider_command", function(event)
			local refresh = function()
				if args.command_use_refresh_timeout then
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = args.command_use_refresh_timeout,
						timer = "REAL",
						blocking = false,
						blockable = false,
						func = function()
							TW_BL.chat_commands.decrement_command_use(event.command, event.username)
							return true
						end,
					}))
				end
			end
			if args.voting then
				if
					TW_BL.chat_commands.default_command_check(event, {
						command = args.command,
						can_use_command = true,
						increment_command_use = true,
						vote_id = "blind_action",
						can_vote_for_variant = true,
						increment_vote_score = true,
					})
				then
					TW_BL.UI.notify({
						target = "panel",
						panel = "top_screen_panel",
						message = event.username,
					})
					refresh()
				end
			elseif args.cards_voting then
				if args.on_new_provider_command(event, args, TW_BL.utils.command_card(args.get_cardarea(), event)) then
					refresh()
				end
			else
				if args.on_new_provider_command(event, args) then
					refresh()
				end
			end
		end, {
			key = "blind_action",
			tags = {
				on_run = true,
			},
		})
	end
	blind.twbl_save_before_eval = function(self)
		TW_BL.e_mitter.off("new_provider_command", "blind_action")
		TW_BL.UI.top_screen_panel.hide()
		if args.voting then
			if not G.GAME.blind.effect.winner then
				local winner = TW_BL.chat_commands.get_vote_winner("blind_action")
				if winner then
					G.GAME.blind.effect.winner = winner.index
				end
			end
		elseif args.cards_voting then
			local result_card = TW_BL.utils.get_most_voted_card(args.get_cardarea(), self.key)
			if result_card then
				result_card.ability.twbl_winner = true
			end
		end
	end
	local old_set_blind = blind.set_blind
	blind.set_blind = function(self, ...)
		ease_background_colour_blind()
		if args.voting then
			G.GAME.blind.effect.effects = args.set_effects()
		elseif args.cards_voting then
			for _, card in ipairs((args.get_cardarea() or {}).cards or {}) do
				card.ability.twbl_winner = nil
			end
		end
		if old_set_blind then
			old_set_blind(self, ...)
		end
		if args.delay_load then
			G.E_MANAGER:add_event(Event({
				func = function()
					self:twbl_load()
					return true
				end,
			}))
		else
			self:twbl_load()
		end
	end
	local old_defeat = blind.defeat
	blind.defeat = function(self)
		local callback = type(args.apply_effect) == "function" and args.apply_effect or function(effect) end
		if old_defeat then
			old_defeat(self)
		end
		local arg
		if args.cards_voting then
			local area = args.get_cardarea() or {}
			arg = TW_BL.utils.get_most_voted_card(area, self.key)
			TW_BL.utils.reset_cards_score(area, true)
		elseif args.voting then
			arg = G.GAME.blind.effect.effects and G.GAME.blind.effect.effects[G.GAME.blind.effect.winner or 1]
		end
		return callback(arg)
	end

	return blind
end

--

TW_BL.load_file("src/additions/chat.lua")

TW_BL.load_files({
	"blank.lua",
	"chisel.lua",
	"precision.lua",
	"lock.lua",
	"sketch.lua",
	"eraser.lua",
	"chaos.lua",
	"flashlight.lua",
	"pin.lua",
	"stock_market.lua",
	"banana.lua",
	"nope.lua",
	"lucky_wheel.lua",
	"greed.lua",
	"misstock.lua",
	"trash_can.lua",
	"acceptance.lua",
	"isaac.lua",
	"jimbo.lua",
	"circus.lua",
	"garden.lua",
}, "src/additions/blinds/")

TW_BL.load_files({
	"plum_hammer.lua",
}, "src/additions/blinds/showdown/")

TW_BL.load_files({
	"interactive.lua",
}, "src/additions/stickers/")
