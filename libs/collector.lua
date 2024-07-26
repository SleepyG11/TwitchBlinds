---@class TwitchCollector
---@field vote_score { [string]: number }
---@field vote_variants string[]
---@field users { [string]: { [string]: number } }
---@field single_use { [string]: boolean }
---@field can_collect { [string]: boolean }
---@field channel_name string?
---@field socket wsclient?
TwitchCollector = {}
TwitchCollector.__index = TwitchCollector

---@return TwitchCollector
function TwitchCollector.new()
    local collector = {
        --- Collected score
        --- @type { [string]: number }
        vote_score = {},

        --- All variant users can vote
        --- @type string[]
        vote_variants = {},

        --- List of usernames who use commands
        --- @type { [string]: { [string]: number } }
        users = {
            vote = {},
            toggle = {},
        },

        --- Can user use commands more than one time
        --- @type { [string]: boolean }
        single_use = {
            vote = true,
            toggle = true,
        },

        --- Can collector process commands
        --- @type { [string]: boolean }
        can_collect = {
            vote = false,
            toggle = false,
        },

        --- Twitch channel name connected to
        --- @type string?
        channel_name = nil,

        --- Web socket connected to twitch chat
        --- @type table?
        socket = nil,
    }

    setmetatable(collector, TwitchCollector)
    return collector;
end

function TwitchCollector:process_message(username, message)
    local vote_match = message:match('vote (.+)')
    if vote_match then
        if not self.can_collect.vote then return end
        if self.single_use.vote and self.users.vote[username] then return end
        if not table_check(self.vote_variants, vote_match) then return end
        self.users.vote[username] = (self.users.vote[username] or 0) + 1
        self.vote_score[vote_match] = (self.vote_score[vote_match] or 0) + 1
        self:onvote(username, vote_match)
        return
    end
    local toggle_match = message:match('toggle (.+)')
    if toggle_match then
        if not self.can_collect.toggle then return end
        if self.single_use.toggle and self.users.toggle[username] then return end
        local value = tonumber(toggle_match)
        if not value then return end
        self.users.toggle[username] = (self.users.toggle[username] or 0) + 1
        self:ontoggle(username, value)
        return
    end
end

--- Called every time when vote for boss blind is collected
--- @param username string Twitch username
--- @param variant string Variant selected by user
function TwitchCollector:onvote(username, variant)
end

--- Called every time when toggle index is collected
--- @param username string Twitch username
--- @param index number Variant selected by user
function TwitchCollector:ontoggle(username, index)
end

--- Called when socket is closed
function TwitchCollector:ondisconnect()
end

--- Connect to Twitch chat
--- @param channel_name string Channel name
--- @param silent boolean? Supress onclose event
function TwitchCollector:connect(channel_name, silent)
    if self.socket then
        -- Ignore this event
        if silent then
            function self.socket:onclose() end
        end

        self.socket:close()
    end
    self.channel_name = channel_name

    local selfRef = self

    local socket = WebSocket.new("irc-ws.chat.twitch.tv", 80, '/')

    function socket:onmessage(message)
        local display_name = message:match("display%-name=([^;]+)")
        local privmsg_content = message:match("PRIVMSG #" .. channel_name .. " :(.+)")
        if display_name and privmsg_content then
            selfRef:process_message(display_name, privmsg_content:sub(1, -3))
        end
    end

    function socket:onopen()
        self:send("CAP REQ :twitch.tv/tags twitch.tv/commands")
        self:send("PASS SCHMOOPIIE")
        self:send("NICK justinfan13847")
        self:send("USER justinfan13847 8 * :justinfan13847")
        self:send("JOIN #" .. channel_name)
    end

    function socket:onclose(code, reason)
        selfRef:ondisconnect()
        self.socket = nil
    end

    self.socket = socket
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
end

--- Reconnect
function TwitchCollector:reconnect()
    if self.channel_name then self:connect(self.channel_name) end
end

--- Clear score and list of voters
function TwitchCollector:reset()
    self.vote_score = {}
    for k, v in pairs(self.users) do
        self.users[k] = {}
    end
end

--- Update socket status. Should be called inside `love.update()`
function TwitchCollector:update()
    if self.socket then self.socket:update() end
end
