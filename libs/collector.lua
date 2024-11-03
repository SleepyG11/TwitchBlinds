local json = require("json")

---@class TwitchCollector
---@field channel_name string?
---@field socket wsclient?
---@field connection_status integer
---@field STATUS table<string, integer>
---@field chatters table<string>
TwitchCollector = {}
TwitchCollector.__index = TwitchCollector

---@return TwitchCollector
function TwitchCollector.new()
	local collector = {
		--- Twitch channel name connected to
		--- @type string?
		channel_name = nil,

		--- Web socket connected to twitch chat
		--- @type table?
		socket = nil,

		--- Connection status
		--- @type integer
		connection_status = 0,

		STATUS = {
			NO_CHANNEL_NAME = -1,
			DISCONNECTED = 0,
			CONNECTING = 1,
			CONNECTED = 2,
		},

		https_thread = love.thread.newThread([[
            local https = require('https')
            local https_chatter_input = love.thread.getChannel("twbl_https_chatter_input")
            local https_chatter_output = love.thread.getChannel("twbl_https_chatter_output")
            while true do
                local channel_name = https_chatter_input:demand()
                if channel_name then
                    pcall(function()
                        local request_body = '[{"operationName":"CommunityTab","variables":{"login":"'
                            .. string.lower(channel_name)
                            .. '"},"extensions":{"persistedQuery":{"version":1,"sha256Hash":"2e71a3399875770c1e5d81a9774d9803129c44cf8f6bad64973aa0d239a88caf"}}}]'
                        local code, raw_response, headers = https.request("https://gql.twitch.tv/gql", {
                            method = "POST",
                            data = request_body,
                            headers = {
                                ["content-type"] = "application/json",
                                ["client-id"] = "kimne78kx3ncx6brgo4mv6wki5h1ko",
                            },
                        })
                        if tostring(code) == '200' then https_chatter_output:push(raw_response) end
                    end)
                end
            end
        ]]),
		https_chatter_input = love.thread.getChannel("twbl_https_chatter_input"),
		https_chatter_output = love.thread.getChannel("twbl_https_chatter_output"),

		chatters = {},
		chatters_timeout = 60,
	}

	collector.https_thread:start()

	setmetatable(collector, TwitchCollector)
	return collector
end

--- Called every time when message is collected
--- @param username string Twitch username
--- @param message string Message content
function TwitchCollector:onmessage(username, message) end

--- Called when socket is closed
function TwitchCollector:ondisconnect() end

--- Called when connection status is changed
--- @param status integer New status
function TwitchCollector:onnewconnectionstatus(status) end

function TwitchCollector:set_connection_status(status)
	if self.connection_status ~= status then
		self.connection_status = status
		self:onnewconnectionstatus(status)
	end
end

--- Connect to Twitch chat
--- @param channel_name string Channel name
--- @param silent boolean? Supress onclose event
function TwitchCollector:connect(channel_name, silent)
	local selfRef = self

	if selfRef.socket then
		-- Ignore this event
		if silent then
			function selfRef.socket:onclose() end
		end
		selfRef.chatters = {}
		selfRef.socket:close()
		selfRef.socket = nil
	end

	selfRef.channel_name = channel_name

	if not channel_name or channel_name == "" then
		print("Connecting to [nothing]")
		return selfRef:set_connection_status(selfRef.STATUS.NO_CHANNEL_NAME)
	end
	print("Connecting to " .. channel_name)

	local socket = WebSocket.new("irc-ws.chat.twitch.tv", 80, "/")

	function socket:onmessage(message)
		if string_starts(message, "PING") then
			socket:send("PONG")
			socket:send("PING")
			selfRef:update_chatters_list()
			return
		end
		if string_starts(message, "PONG") then
			selfRef:set_connection_status(selfRef.STATUS.CONNECTED)
			return
		end
		if string_starts(message, ":justinfan13847!justinfan13847@justinfan13847.tmi.twitch.tv JOIN #") then
			selfRef:set_connection_status(selfRef.STATUS.CONNECTED)
			selfRef:update_chatters_list()
			return
		end
		local display_name = message:match("display%-name=([^;]+)")
		local privmsg_content = message:match("PRIVMSG #" .. channel_name .. " :(.+)")
		if display_name and privmsg_content then
			selfRef:onmessage(display_name, privmsg_content:sub(1, -3))
		end
	end

	function socket:onopen()
		selfRef:set_connection_status(selfRef.STATUS.CONNECTING)
		socket:send("CAP REQ :twitch.tv/tags twitch.tv/commands")
		socket:send("PASS SCHMOOPIIE")
		socket:send("NICK justinfan13847")
		socket:send("USER justinfan13847 8 * :justinfan13847")
		socket:send("JOIN #" .. string.lower(channel_name))
	end

	function socket:onclose(code, reason)
		selfRef:ondisconnect()
		selfRef.socket = nil
		selfRef:set_connection_status(selfRef.STATUS.DISCONNECTED)
	end

	selfRef.socket = socket
end

--- Disconnect
--- @param silent boolean? Supress onclose event
function TwitchCollector:disconnect(silent)
	if self.socket then
		if silent then
			function self.socket:onclose() end
		end
		self.socket:close()
	end
	self.socket = nil
	self:set_connection_status(self.STATUS.DISCONNECTED)
end

--- Reconnect
function TwitchCollector:reconnect()
	self:connect(self.channel_name, true)
end

--- Update socket status. Should be called inside `love.update()`
function TwitchCollector:update(dt)
	if self.socket then
		self.socket:update()
	end
	self.chatters_timeout = math.max(0, self.chatters_timeout - dt)
	if self.chatters_timeout == 0 then
		self:update_chatters_list()
	end
	local raw_chatters_data = self.https_chatter_output:pop()
	if raw_chatters_data then
		pcall(function()
			local chatters_data = json.decode(raw_chatters_data)[1].data.user.channel.chatters
			local result = {}
			for _, chatter in ipairs(chatters_data.moderators) do
				result[#result + 1] = string_capitalize(chatter.login)
			end
			for _, chatter in ipairs(chatters_data.vips) do
				result[#result + 1] = string_capitalize(chatter.login)
			end
			for _, chatter in ipairs(chatters_data.viewers) do
				result[#result + 1] = string_capitalize(chatter.login)
			end
			self.chatters = result
		end)
	end
end

function TwitchCollector:update_chatters_list()
	self.chatters_timeout = 60
	self.https_chatter_input:push(self.channel_name)
end
