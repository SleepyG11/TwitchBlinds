local WebSocket = require("twbl/libs/websocket")
local SOCKET_HOST = "51.79.74.23"
local SOCKET_PORT = 8080
local SOCKET_PATH = "/twbl-proxy"

local socket
local CONNECTION_STATUS = {
	NO_CHANNEL_NAME = -1,
	DISCONNECTED = 0,
	CONNECTING = 1,
	CONNECTED = 2,
}
local connection_status = CONNECTION_STATUS.NO_CHANNEL_NAME
local retry_consumed = true
local retry_interval = 0
local channel_name = nil

local https_input = love.thread.getChannel("twbl_twitch_thread_input")
local https_output = love.thread.getChannel("twbl_twitch_thread_output")

local function string_starts(s, start)
	return string.sub(s, 1, string.len(start)) == start
end

--

function send_new_message(username, message)
	https_output:push({ new_message = true, username = username, message = message })
end
function send_new_connection_status()
	https_output:push({ new_connection_status = true, connection_status = connection_status })
end

--

function connect(keep)
	if socket then
		if keep and connection_status == CONNECTION_STATUS.CONNECTED then
			return
		end
		disconnect(false, true)
	end

	retry_consumed = true
	retry_interval = 0

	if not channel_name then
		set_connection_status(CONNECTION_STATUS.NO_CHANNEL_NAME)
		return
	end

	set_connection_status(CONNECTION_STATUS.CONNECTING)
	socket = WebSocket.new(SOCKET_HOST, SOCKET_PORT, SOCKET_PATH)

	function socket:onmessage(message)
		-- check is this html response and if so, disconnect
		if string_starts(message, "PING") then
			socket:send("PONG")
			socket:send("PING")
			return
		end
		if string_starts(message, "PONG") then
			set_connection_status(CONNECTION_STATUS.CONNECTED)
			return
		end
		if string_starts(message, ":justinfan13847!justinfan13847@justinfan13847.tmi.twitch.tv JOIN #") then
			set_connection_status(CONNECTION_STATUS.CONNECTED)
			return
		end
		local display_name = message:match("display%-name=([^;]+)")
		local privmsg_content = message:match("PRIVMSG #" .. channel_name .. " :(.+)")
		if display_name and privmsg_content then
			send_new_message(display_name, privmsg_content:sub(1, -3))
		end
	end

	function socket:onopen()
		socket:send("CAP REQ :twitch.tv/tags twitch.tv/commands")
		socket:send("PASS SCHMOOPIIE")
		socket:send("NICK justinfan13847")
		socket:send("USER justinfan13847 8 * :justinfan13847")
		socket:send("JOIN #" .. channel_name)
	end

	function socket:onclose(code, reason)
		disconnect(true)
	end
end
function disconnect(by_socket, by_reconnect)
	if socket then
		if by_reconnect then
			function socket:onclose() end
		end
		if not by_socket then
			socket:close()
		else
			retry_consumed = false
			retry_interval = 5
		end
		socket = nil
	end

	if not by_reconnect then
		set_connection_status(channel_name and CONNECTION_STATUS.DISCONNECTED or CONNECTION_STATUS.NO_CHANNEL_NAME)
	end
end
function reconnect()
	disconnect(false, true)
	connect()
end

function update(dt)
	if socket then
		socket:update()
	end
	if retry_interval > 0 then
		retry_interval = retry_interval - dt
	elseif not retry_consumed then
		retry_consumed = true
		connect()
	end
end

--

function set_channel_name(new_channel_name)
	new_channel_name = new_channel_name and string.lower(new_channel_name)
	if new_channel_name ~= channel_name then
		channel_name = new_channel_name
		disconnect(false, false)
	end
end
function set_connection_status(new_status, silent)
	if connection_status ~= new_status then
		connection_status = new_status
		if not silent then
			send_new_connection_status()
		end
	end
end

--

(function()
	while true do
		local update_dt = 0
		local event = https_input:demand()
		if event then
			if event.ping then
				https_output:push({
					pong = true,
					channel_name = channel_name,
					connection_status = connection_status,
				})
			elseif event.update then
				update_dt = update_dt + event.dt
			elseif event.set_channel_name then
				set_channel_name(event.channel_name or nil)
				if event.connect then
					connect()
				end
			elseif event.connect then
				connect()
			elseif event.reconnect then
				reconnect()
			elseif event.disconnect then
				disconnect(false, false)
			end
		end
		if update_dt > 0 then
			update(update_dt)
		end
	end
end)()
