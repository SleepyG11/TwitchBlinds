sendDebugMessage = sendDebugMessage or function() end

arg = args or {}
require("love.system")
local https = require("SMODS.https")
local json = require("json")

local CONNECTION_STATUS = {
	NO_CHANNEL_NAME = -1,
	DISCONNECTED = 0,
	CONNECTING = 1,
	CONNECTED = 2,
}
local connection_status = CONNECTION_STATUS.NO_CHANNEL_NAME
local retry_consumed = true
local retry_interval = 0
local polling_consumed = true
local polling_interval = 0
local channel_name = nil
local continuation = nil

local https_input = love.thread.getChannel("twbl_youtube_thread_input")
local https_output = love.thread.getChannel("twbl_youtube_thread_output")

--

function send_new_messages(messages)
	https_output:push({ new_messages = true, messages = messages })
end
function send_new_message(username, message)
	https_output:push({ new_message = true, username = username, message = message })
end
function send_new_connection_status()
	https_output:push({ new_connection_status = true, connection_status = connection_status })
end

--

function get_start_continuation()
	if not channel_name then
		retry_interval = 0
		retry_consumed = true
		return
	end
	set_connection_status(CONNECTION_STATUS.CONNECTING)
	local execute_channel_name = channel_name
	if string.sub(channel_name, 1, 1) ~= "@" then
		execute_channel_name = "channel/" .. channel_name
	end
	local url = "https://www.youtube.com/" .. execute_channel_name .. "/live"
	local success, new_continuation = pcall(function()
		local code, raw_response = https.request(url, {
			method = "GET",
			headers = {
				["User-Agent"] = "Mozilla/5.0",
			},
		})

		if code == 200 then
			return raw_response.match(raw_response, '"continuation"%s*:%s*"([^"]+)"')
		else
			return nil
		end
	end)
	if success and new_continuation then
		continuation = new_continuation
	else
		disconnect(true, false)
	end
end
function get_chat_messages(first)
	if not continuation then
		return
	end

	local success, data = pcall(function()
		local request_body = {
			context = {
				client = {
					clientName = "WEB",
					clientVersion = "2.20250516.01.00",
				},
			},
			continuation = continuation,
		}
		local body_data = json.encode(request_body)
		local chat_url = "https://www.youtube.com/youtubei/v1/live_chat/get_live_chat"
		local code, raw_response = https.request(chat_url, {
			method = "POST",
			data = body_data,
			headers = {
				["User-Agent"] = "Mozilla/5.0",
				["Content-Type"] = "application/json",
				["Content-Length"] = tostring(#body_data),
			},
		})

		if code ~= 200 then
			return nil
		end
		return json.decode(raw_response)
	end)

	if not success or not data then
		return nil, {}
	end

	local messages_success, new_messages = pcall(function()
		local messages = {}
		local actions = data.continuationContents
			and data.continuationContents.liveChatContinuation
			and data.continuationContents.liveChatContinuation.actions

		if actions and not first then
			for _, action in ipairs(actions) do
				if action.addChatItemAction then
					local msg = action.addChatItemAction.item.liveChatTextMessageRenderer
					if msg then
						local author = msg.authorName and msg.authorName.simpleText or nil
						if author then
							author = author:gsub("^%s*(.-)%s*$", "%1")
						end
						if author and author ~= "" then
							local text = ""
							for _, part in ipairs(msg.message.runs or {}) do
								text = text .. tostring(part.text or "")
							end
							text = text:gsub("^%s*(.-)%s*$", "%1")
							if text and text ~= "" then
								table.insert(messages, { username = author, message = text })
							end
						end
					end
				end
			end
		end
		return messages
	end)

	local continuation_success, next_continuation = pcall(function()
		local next_continuation_cont = data.continuationContents.liveChatContinuation.continuations
			and data.continuationContents.liveChatContinuation.continuations[1]

		if next_continuation_cont then
			return (
				next_continuation_cont.invalidationContinuationData
				and next_continuation_cont.invalidationContinuationData.continuation
			)
				or (
					next_continuation_cont.timedContinuationData
					and next_continuation_cont.timedContinuationData.continuation
				)
		end
		return nil
	end)

	continuation = continuation_success and next_continuation or nil
	local result_messages = messages_success and new_messages or {}
	for _, new_message in ipairs(result_messages) do
		send_new_message(new_message.username, new_message.message)
	end

	if continuation then
		if first then
			set_connection_status(CONNECTION_STATUS.CONNECTED)
		end
		polling_consumed = false
		polling_interval = 1
	else
		disconnect(true, false)
	end
end

--

function connect()
	if continuation then
		disconnect(false, true)
	end

	retry_consumed = true
	retry_interval = 0

	polling_consumed = true
	polling_interval = 0

	if not channel_name then
		set_connection_status(CONNECTION_STATUS.NO_CHANNEL_NAME)
		return
	end

	get_start_continuation()
	get_chat_messages(true)
end
function disconnect(by_socket, by_reconnect)
	polling_consumed = true
	polling_interval = 0

	if by_socket then
		retry_consumed = false
		retry_interval = 5
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
	if polling_interval > 0 then
		polling_interval = polling_interval - dt
	elseif not polling_consumed then
		polling_consumed = true
		get_chat_messages(false)
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
