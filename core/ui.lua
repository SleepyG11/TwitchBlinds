local nativefs = require("nativefs")

local controllers_to_load = {
	"booster_top",
	"game_top",
}
local panels_to_load = {
	"blind_voting_process",
	"command_info_1",
	"command_info_1_short",
	"command_info_2",
	"voting_process_3",
}

--- @class TWBLPanelController
TWBLPanelController = Object:extend()

function TWBLPanelController:is_current_panel(panel_key, strict)
	local current_key = self.panel and self.panel.key_append or nil
	if strict then
		return current_key == panel_key
	else
		return not panel_key or (current_key == panel_key)
	end
end
function TWBLPanelController:init(key_append)
	self.key_append = key_append

	--- @type TWBLPanel
	self.panel = nil

	--- @type TWBLPanel
	self.previous_panel = nil

	return self
end

function TWBLPanelController:get_panel_UIBox(definition)
	if not definition then
		return
	end
	return UIBox({
		definition = definition,
		config = {
			align = "cmri",
			offset = { x = 0, y = 0 },
			major = G.ROOM_ATTACH,
			id = "twbl_panel",
		},
	})
end

function TWBLPanelController:before_remove(panel, continue)
	continue()
end
function TWBLPanelController:remove(panel_key, write)
	if self:is_current_panel(panel_key) and self.panel then
		self:set(nil, write, true)
	end
end
function TWBLPanelController:reset()
	self.panel = nil
	self.previous_panel = nil
end
function TWBLPanelController:set(panel_key, write, full_reload, ...)
	local args = { panel_key, full_reload, ... }
	if self:is_current_panel(panel_key, true) then
		if self.panel then
			self:update(unpack(args))
		end
		return panel_key
	end

	local previous_panel = self.panel or nil
	local target_panel = panel_key and TW_BL.UI.panels[panel_key] or nil

	self.previous_panel = self.panel
	self.panel = target_panel or nil

	if write then
		self:save()
	end

	local continue = function()
		if self.previous_panel then
			self.previous_panel:reset()
		end
		if target_panel then
			target_panel.element = self:get_panel_UIBox(target_panel:get_definition())
			self:update(unpack(args))
			self:update_status()
			self:after_set(target_panel, function() end)
		end
	end

	if previous_panel and previous_panel.element then
		self:before_remove(previous_panel, continue)
	else
		continue()
	end

	return target_panel and panel_key or nil
end
function TWBLPanelController:after_set(panel, continue)
	continue()
end

function TWBLPanelController:notify(panel_key, message)
	if self:is_current_panel(panel_key) and self.panel then
		self.panel:notify(message)
	end
end
function TWBLPanelController:update(panel_key, full_reload, ...)
	if self:is_current_panel(panel_key) and self.panel then
		self.panel:update(full_reload, ...)
	end
end
function TWBLPanelController:update_status(status)
	if not (self.panel and self.panel.element) then
		return
	end

	local text = self.panel:localize_status(status)
	if not text then
		if TW_BL.CHAT_COMMANDS.get_is_any_collector_connected() then
			text = localize("k_twbl_status_connected")
		else
			text = localize("k_twbl_status_disconnected")
		end
	end

	local status_element = self.panel.element:get_UIE_by_ID("twbl_voting_status")
	if status_element then
		status_element.config.object.config.string = { text }
		status_element.config.object:update_text(true)
		self.panel.element:recalculate()
	end
end

function TWBLPanelController:save()
	TW_BL.G["ui_controller_" .. self.key_append .. "_panel"] = self.panel and self.panel.key_append or nil
end
function TWBLPanelController:load()
	self:set(TW_BL.G["ui_controller_" .. self.key_append .. "_panel"], false, true)
end

--- @class TWBLPanel
--- @field parent TWBLPanelController?
TWBLPanel = setmetatable(Object:extend(), {
	__call = function(table, ...)
		table.__index = function(t, index)
			if index == "parent" then
				for k, v in pairs(TW_BL.UI.controllers) do
					if v.panel == t then
						return v
					end
				end
				return nil
			else
				return rawget(table, index)
			end
		end
		local obj = setmetatable({}, table)
		obj:init(...)
		return obj
	end,
})

function TWBLPanel:init(key_append, default_args)
	self.key_append = key_append

	self.default_args = default_args
	self.args = self.default_args

	self.element = nil
end

function TWBLPanel:resolve_args(full_update, args)
	local args_key = "ui_" .. self.key_append .. "_" .. self.parent.key_append .. "_args"
	local args_array = TW_BL.G[args_key]
	local do_update = false
	if args then
		do_update = true
		args_array = args
	end
	if not args_array then
		do_update = true
		args_array = self.default_args
	end
	if do_update then
		self.args = args_array
		TW_BL.G[args_key] = args_array
	end
	return args_array, do_update
end
function TWBLPanel:reset()
	if self.element then
		self.element:remove()
	end
	self.element = nil
end

function TWBLPanel:localize_status(status) end
function TWBLPanel:get_definition() end
function TWBLPanel:update(full_update, args, ...) end
function TWBLPanel:notify(message) end

function twbl_init_ui()
	local UI = {
		PARTS = {},

		--- @type table<string, TWBLPanel>
		panels = {},
		--- @type table<string, TWBLPanelController>
		controllers = {},

		settings = {
			element = nil,
		},

		waiting_for_chat = {
			element = nil,
		},
	}

	TW_BL.UI = UI

	-- Init
	------------------------------

	---@param controller TWBLPanelController
	function UI.register_controller(controller)
		UI.controllers[controller.key_append] = controller
	end
	---@param panel TWBLPanel
	function UI.register_panel(panel)
		UI.panels[panel.key_append] = panel
	end

	assert(load(nativefs.read(TW_BL.current_mod.path .. "ui/config.lua")))()
	for _, controller_key in ipairs(controllers_to_load) do
		assert(load(nativefs.read(TW_BL.current_mod.path .. "ui/controllers/" .. controller_key .. ".lua")))()
	end
	for _, panel_key in ipairs(panels_to_load) do
		assert(load(nativefs.read(TW_BL.current_mod.path .. "ui/panels/" .. panel_key .. ".lua")))()
	end

	-- Callbacks
	------------------------------

	function G.FUNCS.twbl_settings_change_blind_frequency(args)
		TW_BL.SETTINGS.current.blind_frequency = args.to_key
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_change_pool_type(args)
		TW_BL.SETTINGS.current.pool_type = args.to_key
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_change_forced_blind(args)
		TW_BL.SETTINGS.current.forced_blind = args.to_key > 1 and args.to_key - 1 or nil
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_change_chat_booster_sticker_appearance(args)
		TW_BL.SETTINGS.current.chat_booster_sticker_appearance = args.to_key
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_toggle_natural_blinds(args)
		TW_BL.SETTINGS.current.natural_blinds = args
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_paste_channel_name_twitch(e)
		G.CONTROLLER.text_input_hook = e.parent.UIBox:get_UIE_by_ID("twbl_set_channel_name").children[1].children[1]
		G.CONTROLLER.text_input_hook:click()
		for i = 1, 32 do
			G.FUNCS.text_input_key({ key = "right" })
		end
		for i = 1, 32 do
			G.FUNCS.text_input_key({ key = "backspace" })
		end

		local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ""
		local channel_name = clipboard:match("twitch%.tv/([%w_]+)") or clipboard

		for i = 1, #channel_name do
			local c = channel_name:sub(i, i)
			G.FUNCS.text_input_key({ key = c, twbl_keep_real = true })
		end

		G.FUNCS.text_input_key({ key = "return" })
	end

	function G.FUNCS.twbl_settings_paste_channel_name_youtube(e)
		G.CONTROLLER.text_input_hook = e.parent.UIBox:get_UIE_by_ID("twbl_set_yt_channel_name").children[1].children[1]
		G.CONTROLLER.text_input_hook:click()
		for i = 1, 32 do
			G.FUNCS.text_input_key({ key = "right" })
		end
		for i = 1, 32 do
			G.FUNCS.text_input_key({ key = "backspace" })
		end

		local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ""
		local channel_name = clipboard:match("youtube%.com/(@[%w_]+)")
			or clipboard:match("youtube%.com/channel/([%w_]+)")
			or ""

		for i = 1, #channel_name do
			local c = channel_name:sub(i, i)
			G.FUNCS.text_input_key({ key = c, twbl_keep_real = true })
		end

		G.FUNCS.text_input_key({ key = "return" })
	end

	function G.FUNCS.twbl_settings_save_channel_name_twitch()
		TW_BL.SETTINGS.current.channel_name = TW_BL.SETTINGS.temp.channel_name
		TW_BL.SETTINGS.save()
		TW_BL.CHAT_COMMANDS.twitch_collector:connect(TW_BL.SETTINGS.current.channel_name, true)
	end

	function G.FUNCS.twbl_settings_save_channel_name_youtube()
		TW_BL.SETTINGS.current.yt_channel_name = TW_BL.SETTINGS.temp.yt_channel_name
		TW_BL.SETTINGS.save()
		TW_BL.CHAT_COMMANDS.youtube_collector:connect(TW_BL.SETTINGS.current.yt_channel_name, true)
	end

	function G.FUNCS.twbl_settings_change_delay_for_chat(args)
		TW_BL.SETTINGS.current.delay_for_chat = args.to_key
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_change_blind_pool_type(args)
		TW_BL.SETTINGS.current.blind_pool_type = args.to_key
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_toggle_mystic_variants(args)
		TW_BL.SETTINGS.current.mystic_variants = args
		TW_BL.SETTINGS.save()
	end

	function G.FUNCS.twbl_settings_toggle_discovery_bypass(args)
		TW_BL.SETTINGS.current.discovery_bypass = args
		TW_BL.SETTINGS.save()
	end

	-- Functions
	------------------------------

	function UI.set_panel(controller_key, panel_key, write, full_reload, ...)
		return UI.controllers[controller_key]:set(panel_key, write, full_reload, ...)
	end

	function UI.remove_panel(controller_key, panel_key, write)
		return UI.controllers[controller_key]:remove(panel_key, write)
	end

	function UI.update_panel(controller_key, panel_key, full_reload, ...)
		return UI.controllers[controller_key]:update(panel_key, full_reload, ...)
	end

	function UI.create_panel_notify(controller_key, panel_key, message)
		return UI.controllers[controller_key]:notify(panel_key, message)
	end

	function UI.reset()
		for k, v in pairs(UI.controllers) do
			v:reset()
		end
		for k, v in pairs(UI.panels) do
			v:reset()
		end
		UI.create_waiting_for_chat_panel(true)
	end

	function UI.get_panels_from_game()
		for k, v in pairs(UI.controllers) do
			v:load()
		end
		UI.create_waiting_for_chat_panel(true)
	end

	function UI.create_waiting_for_chat_panel(force)
		if not force and UI.waiting_for_chat.element then
			return
		end
		UI.waiting_for_chat.element = UIBox({
			definition = {
				n = G.UIT.R,
				config = {
					colour = G.C.L_BLACK,
					r = 0.1,
					padding = 0.075,
				},
				nodes = {
					{
						n = G.UIT.R,
						config = {
							colour = G.C.BLACK,
							r = 0.1,
							padding = 0.25,
						},
						nodes = {
							{
								n = G.UIT.O,
								config = {
									object = DynaText({
										string = { localize("k_twbl_waiting_for_chat") .. " " .. "20" },
										colours = { G.C.UI.TEXT_LIGHT },
										shadow = true,
										float = false,
										bump = true,
										silent = true,
										pop_in = 0.1,
										scale = 0.5,
									}),
									id = "twbl_waiting_for_chat_text",
								},
							},
						},
					},
				},
			},
			config = {
				align = "cm",
				offset = { x = 1, y = 0 },
				major = G.ROOM_ATTACH,
				id = "twbl_waiting_for_chat",
			},
		})
		UI.waiting_for_chat.text_element = UI.waiting_for_chat.element:get_UIE_by_ID("twbl_waiting_for_chat_text")
		UI.waiting_for_chat.element.attention_text = true
		UI.waiting_for_chat.element.states.visible = false
	end

	-- Events
	------------------------------

	TW_BL.EVENTS.add_listener("new_connection_status", "ui_update_status", function(collector, status, channel_name)
		for k, v in pairs(UI.controllers) do
			v:update_status()
		end
		UI.settings.update_status()
	end)

	local last_remaining_time = nil

	TW_BL.EVENTS.add_listener("game_update", "waiting_for_chat_panel", function()
		UI.create_waiting_for_chat_panel()
		UI.waiting_for_chat.element.states.visible = TW_BL.EVENTS.delay_requested
		local remaining_time = math.floor(TW_BL.EVENTS.delay_dt) or 0
		if
			last_remaining_time ~= remaining_time
			and TW_BL.EVENTS.delay_requested
			and UI.waiting_for_chat.text_element
			and UI.waiting_for_chat.text_element.config.object
		then
			UI.waiting_for_chat.text_element.config.object.config.string =
				{ localize("k_twbl_waiting_for_chat") .. " " .. remaining_time }
			UI.waiting_for_chat.text_element.config.object:update_text(true)
		end
	end)

	return UI
end
