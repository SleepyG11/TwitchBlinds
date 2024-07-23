local nativefs = require("nativefs")
assert(load(nativefs.read(SMODS.current_mod.path .. "websocket.lua")))()

--

---@class _TwitchCollector
---@field score { [string]: number }
---@field variants string[]
---@field voters string[]
---@field channel_name string?
---@field socket wsclient?
local _TwitchCollector = {}
_TwitchCollector.__index = _TwitchCollector

---@return _TwitchCollector
function _TwitchCollector.new()
    local collector = {
        --- Collected score
        --- @type { [string]: number }
        score = {},

        --- All variant users can vote
        --- @type string[]
        variants = {},

        --- List of usernames who vote
        --- @type string[]
        voters = {},

        --- Twitch channel name connected to
        --- @type string?
        channel_name = nil,

        --- Web socket connected to twitch chat
        --- @type table?
        socket = nil,
    }

    setmetatable(collector, _TwitchCollector)
    return collector;
end

function _TwitchCollector:process_message(username, message)
    local vote_match = message:match('vote (.+)')
    if vote_match then
        -- if table_check(self.voters, username) then return end
        if not table_check(self.variants, vote_match) then return end
        -- table.insert(self.voters, username)
        self.score[vote_match] = (self.score[vote_match] or 0) + 1
        self:onvote(username, vote_match)
        return
    end
    local toggle_match = message:match('toggle (.+)')
    if toggle_match then
        local value = tonumber(toggle_match)
        if value then self:ontoggle(username, value) end
        return
    end
end

--- Called every time when vote for boss blind is collected
--- @param username string Twitch username
--- @param variant string Variant selected by user
function _TwitchCollector:onvote(username, variant)
end

--- Called every time when toggle index is collected
--- @param username string Twitch username
--- @param index number Variant selected by user
function _TwitchCollector:ontoggle(username, index)
end

--- Called when socket is closed
function _TwitchCollector:ondisconnect()
end

--- Connect to Twitch chat
--- @param channel_name string Channel name
function _TwitchCollector:connect(channel_name)
    if self.socket then self.socket:close() end
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
    end

    self.socket = socket
end

--- Disconnect
function _TwitchCollector:disconnect()
    if self.socket then self.socket:close() end
    self.channel_name = nil
end

--- Clear score and list of voters
function _TwitchCollector:reset()
    self.score = {}
    self.voters = {}
end

--- Update socket status. Should be called inside `love.update()`
function _TwitchCollector:update()
    if self.socket then self.socket:update() end
end

TwitchCollector = _TwitchCollector
