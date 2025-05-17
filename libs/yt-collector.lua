---@class YoutubeCollector
---@field channel_name string?
---@field connection_status integer
---@field STATUS table<string, integer>
YoutubeCollector = {}
YoutubeCollector.__index = YoutubeCollector

local nativefs = require("nativefs")

function YoutubeCollector.new()
	local collector = {
		--- Youtube channel name connected to
		--- @type string?
		channel_name = nil,

		--- Connection status
		--- @type integer
		connection_status = 0,

		STATUS = {
			NO_CHANNEL_NAME = -1,
			DISCONNECTED = 0,
			CONNECTING = 1,
			CONNECTED = 2,
		},

		https_thread = love.thread.newThread(nativefs.read(TW_BL.current_mod.path .. "libs/yt-collector-thread.lua")),
		https_input = love.thread.getChannel("twbl_yt_https_input"),
		https_output = love.thread.getChannel("twbl_yt_https_output"),

		polling_timeout = 1.5,
		disconnected = false,
	}

	collector.https_thread:start()

	setmetatable(collector, YoutubeCollector)
	return collector
end

--- Events
----------------------------

--- Called every time when message is collected
--- @param username string Youtube username
--- @param message string Message content
function YoutubeCollector:onmessage(username, message) end

--- Called when collecton no longer accepts new messages
function YoutubeCollector:ondisconnect() end

--- Called when connection status is changed
--- @param status integer New status
function YoutubeCollector:onnewconnectionstatus(status) end

--- Status
----------------------------

function YoutubeCollector:set_connection_status(status)
	if self.connection_status ~= status then
		self.connection_status = status
		self:onnewconnectionstatus(status)
	end
end

--- Connection
----------------------------

--- Connect to Youtube chat
--- @param channel_name string Channel name
--- @param silent boolean? Supress onclose event
function YoutubeCollector:connect(channel_name, silent)
	if not silent then
		self:ondisconnect()
		self:set_connection_status(self.STATUS.DISCONNECTED)
	end
	self.disconnected = false
	self.channel_name = channel_name
	self.https_input:push(channel_name or "")
	self.polling_timeout = 1.5
	if not channel_name or channel_name == "" then
		self:set_connection_status(self.STATUS.NO_CHANNEL_NAME)
	end
end

--- Disconnect
--- @param silent boolean? Supress onclose event
function YoutubeCollector:disconnect(silent)
	self.disconnected = true
	self.https_input:push("")
	self.polling_timeout = 1.5
	self:set_connection_status(self.STATUS.DISCONNECTED)
	if not silent then
		self:ondisconnect()
	end
end

--- Reconnect
function YoutubeCollector:reconnect()
	self:connect(self.channel_name, true)
end

--- Updating
----------------------------

--- Update socket status. Should be called inside `love.update()`
function YoutubeCollector:update(dt)
	self.polling_timeout = math.max(0, self.polling_timeout - dt)
	if self.polling_timeout == 0 then
		self.polling_timeout = 1.5
		if not self.disconnected then
			self.https_input:push(self.channel_name or "")
		end
	end
	local polling_data = self.https_output:pop()
	if polling_data then
		if polling_data.log then
			print(polling_data.log)
		end
		if polling_data.status then
			if polling_data.status == self.STATUS.DISCONNECTED then
				self.disconnected = true
			end
			self:set_connection_status(polling_data.status)
		end
		if polling_data.messages then
			for _, message in ipairs(polling_data.messages) do
				if message.author and message.text then
					self:onmessage(message.author, message.text)
				end
			end
		end
	end
end
