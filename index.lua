--- STEAMODDED HEADER
--- MOD_NAME: Twitch Blinds
--- MOD_ID: TwitchBlinds
--- MOD_AUTHOR: [SleepyG11, Djynasty]
--- MOD_DESCRIPTION: Let your Twitch chat decide which new boss will end your run ;)

--- PRIORITY: -1
--- BADGE_COLOR: 8E15AD
--- DISPLAY_NAME: Twitch Blinds
--- PREFIX: twbl
--- VERSION: 1.1.0-pre
----------------------------------------------
------------MOD CODE -------------------------

if not to_big then function to_big(x) return x end end

local nativefs = require("nativefs")
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/utilities.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/websocket.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/collector.lua")))()

assert(load(nativefs.read(SMODS.current_mod.path .. "core/main.lua")))()

function SMODS.INIT.TwitchBlinds()
    TW_BL:init()
end

----------------------------------------------
------------MOD CODE END----------------------
