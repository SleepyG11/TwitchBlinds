local nativefs = require("nativefs")

local stickers_to_load = {
	"chat_booster",
}

function twbl_init_stickers()
	local STICKERS = {
		ATLAS = SMODS.Atlas({
			key = "twbl_stickers",
			px = 71,
			py = 95,
			path = "stickers.png",
			atlas_table = "ASSET_ATLAS",
		}),
	}

	TW_BL.STICKERS = STICKERS

	for _, sticker_name in ipairs(stickers_to_load) do
		assert(load(nativefs.read(TW_BL.current_mod.path .. "stickers/" .. sticker_name .. ".lua")))()
	end

	return STICKERS
end
