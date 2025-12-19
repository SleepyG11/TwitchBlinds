--- @class TW_BL.BaseProvider: Object
local BaseProvider = Object:extend()

function BaseProvider:init(key)
	self.loc_key = key
	key = string.lower(key)
	self.key = key
	self.CONNECTION_STATUS = {
        NO_CHANNEL_NAME = -1,
        DISCONNECTED = 0,
        CONNECTING = 1,
        CONNECTING_TO_SERVICE = 1,
        CONNECTING_TO_CHANNEL = 2,
        CONNECTED = 3,
	}
	self.connection_status = self.CONNECTION_STATUS.NO_CHANNEL_NAME
	self.connection_status_text = "..."

	self.https_input = love.thread.getChannel("twbl_" .. key .. "_thread_input")
	self.https_output = love.thread.getChannel("twbl_" .. key .. "_thread_output")

	local thread_file = NFS.read(TW_BL.current_mod.path .. "/src/providers/" .. key .. "_thread.lua")
	self.https_thread =
		love.thread.newThread(love.filesystem.newFileData(thread_file, '=[SMODS twbl "threads/' .. key .. '"]'))
	self.https_thread:start()

	TW_BL.e_mitter.on("update", function(dt)
		self.https_input:push({ update = true, dt = dt })
		local event = self.https_output:pop()
		while event do
			if event.pong or event.log then
				print(event)
			elseif event.new_connection_status then
				self.connection_status = event.connection_status
				TW_BL.providers.update_status()
				TW_BL.e_mitter.emit("new_provider_connection_status", {
					provider = self.key,
					connection_status = self.connection_status,
				})
			elseif event.new_message then
				TW_BL.e_mitter.emit("new_provider_message", {
					provider = self.key,
					username = event.username,
					message = event.message,
				})
			end
			event = self.https_output:pop()
		end
	end)
end
function BaseProvider:ping()
	self.https_input:push({ ping = true })
end
function BaseProvider:set_channel_name(channel_name, connect)
	if channel_name == "" then
		channel_name = nil
	end
	self.https_input:push({ set_channel_name = true, channel_name = channel_name or nil, connect = connect })
end
function BaseProvider:connect()
	self.https_input:push({ connect = true })
end
function BaseProvider:reconnect()
	self.https_input:push({ reconnect = true })
end
function BaseProvider:disconnect()
	self.https_input:push({ disconnect = true })
end
function BaseProvider:paste(e) end

--

TW_BL.providers = {
	--- @type table<string, TW_BL.BaseProvider>
	dictionary = {},

	CONNECTION_STATUS = {
        NO_CHANNEL_NAME = -1,
        DISCONNECTED = 0,
        CONNECTING = 1,
        CONNECTING_TO_SERVICE = 1,
        CONNECTING_TO_CHANNEL = 2,
        CONNECTED = 3,
	},

	connection_status_text = "...",
}

TW_BL.providers.connection_status = TW_BL.providers.CONNECTION_STATUS.NO_CHANNEL_NAME
TW_BL.providers.dictionary.twitch = BaseProvider("Twitch")
TW_BL.providers.dictionary.youtube = BaseProvider("YouTube")
TW_BL.Twitch = TW_BL.providers.dictionary.twitch
TW_BL.Youtube = TW_BL.providers.dictionary.youtube

--

function TW_BL.Twitch:paste(e)
	G.CONTROLLER.text_input_hook = e.parent.UIBox:get_UIE_by_ID("twbl_set_channel_name_twitch").children[1].children[1]
	G.CONTROLLER.text_input_hook:click()
	for i = 1, 32 do
		G.FUNCS.text_input_key({ key = "right" })
	end
	for i = 1, 32 do
		G.FUNCS.text_input_key({ key = "backspace" })
	end

	local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ""
	local channel_name = string.lower(clipboard:match("twitch%.tv/([%w_]+)") or clipboard)

	for i = 1, #channel_name do
		local c = channel_name:sub(i, i)
		G.FUNCS.text_input_key({ key = c, twbl_keep_real = true })
	end

	G.FUNCS.text_input_key({ key = "return" })
end
function TW_BL.Youtube:paste(e)
	G.CONTROLLER.text_input_hook = e.parent.UIBox:get_UIE_by_ID("twbl_set_channel_name_youtube").children[1].children[1]
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

--

function TW_BL.providers.update_status()
	local loc_status = localize("twbl_connection_status")

	local result = TW_BL.providers.CONNECTION_STATUS.NO_CHANNEL_NAME
	for _, provider in pairs(TW_BL.providers.dictionary) do
		provider.connection_status_text = loc_status[provider.connection_status] or "..."
		result = math.max(result, provider.connection_status)
	end

	TW_BL.providers.connection_status = result
	TW_BL.providers.connection_status_text = loc_status[TW_BL.providers.connection_status] or "..." or "..."
end
function TW_BL.providers.diconnect()
	for _, provider in pairs(TW_BL.providers.dictionary) do
		provider:disconnect()
	end
end
function TW_BL.providers.connect()
	for _, provider in pairs(TW_BL.providers.dictionary) do
		provider:connect()
	end
end
function TW_BL.providers.reconnect()
	for _, provider in pairs(TW_BL.providers.dictionary) do
		provider:reconnect()
	end
end

--

function TW_BL.providers.fake_message(provider, username, message)
	TW_BL.e_mitter.emit("new_provider_message", {
		provider = provider,
		username = username,
		message = message,
		fake = true,
	})
end

--

TW_BL.e_mitter.on("localization_load", TW_BL.providers.update_status)

TW_BL.e_mitter.on("load", function()
	TW_BL.Twitch:set_channel_name(TW_BL.cc.twitch_channel_name.value, true)
	TW_BL.Youtube:set_channel_name(TW_BL.cc.youtube_channel_name.value, true)
end)

-- TW_BL.e_mitter.on("new_provider_connection_status", function(event)
-- 	print(string.format("New %s connection status: %s", event.provider, event.connection_status))
-- end)
-- TW_BL.e_mitter.on("new_provider_message", function(event)
-- 	print(string.format("New %s message: %s -> %s", event.provider, event.username, event.message))
-- end)
