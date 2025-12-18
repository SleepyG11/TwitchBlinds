TW_BL.load_file("src/utils/index.lua")
TW_BL.load_file("src/config/index.lua")
TW_BL.load_file("src/core/index.lua")
TW_BL.load_file("src/additions/index.lua")
TW_BL.load_file("src/ui/index.lua")

--

local game_start_up_ref = Game.start_up
function Game:start_up(...)
	local result = game_start_up_ref(self, ...)
	TW_BL.e_mitter.emit("game_start")
	return result
end

local game_start_run_ref = Game.start_run
function Game:start_run(args, ...)
	TW_BL.UI.cleanup()
	local result = game_start_run_ref(self, args, ...)
	local saveTable = args.savetext or nil
	TW_BL.e_mitter.emit("run_start", not not saveTable)
	return result
end

local game_delete_run_ref = Game.delete_run
function Game:delete_run(...)
	TW_BL.UI.cleanup()
	local result = game_delete_run_ref(self, ...)
	TW_BL.e_mitter.emit("run_delete")
	return result
end

local love_update_ref = love.update
function love.update(dt, ...)
	TW_BL.e_mitter.emit("update", dt)
	return love_update_ref(dt, ...)
end

local init_localization_ref = init_localization
function init_localization(...)
	local result = init_localization_ref(...)
	TW_BL.e_mitter.emit("localization_load")
	return result
end

--

TW_BL.e_mitter.emit("load")

TW_BL.e_mitter.on("run_start", function()
	for _, card in pairs(G.I.CARD) do
		if card.ability and card.ability.twbl_resize then
			TW_BL.utils.resize_card(card, card.ability.twbl_resize, true)
		end
	end
end)
