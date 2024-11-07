--- STEAMODDED HEADER
--- MOD_NAME: Twitch Blinds
--- MOD_ID: TwitchBlinds
--- MOD_AUTHOR: [SleepyG11, slushiegoose]
--- MOD_DESCRIPTION: Let your Twitch chat decide which new boss will end your run ;)

--- PRIORITY: -1
--- BADGE_COLOUR: 8E15AD
--- DISPLAY_NAME: Twitch Blinds
--- PREFIX: twbl
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- VERSION: 1.2.9
----------------------------------------------
------------MOD CODE -------------------------

if not to_big then
	function to_big(x)
		return x
	end
end

local nativefs = require("nativefs")
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/utilities.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/websocket.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/collector.lua")))()

assert(load(nativefs.read(SMODS.current_mod.path .. "core/main.lua")))()

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 34,
	py = 34,
})

TW_BL:init()

----------------------------------------------
------------MOD CODE END----------------------
