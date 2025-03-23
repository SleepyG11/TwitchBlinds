to_big = to_big or function(x)
	return x
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
