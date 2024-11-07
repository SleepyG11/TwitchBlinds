local nativefs = require("nativefs")

local stickers_to_load = {
	"chat_booster",
}

function twbl_init_stickers()
	local STICKERS = {
		loaded = {},

		storage = {},

		ATLAS = SMODS.Atlas({
			key = "twbl_stickers",
			px = 71,
			py = 95,
			path = "stickers.png",
			atlas_table = "ASSET_ATLAS",
		}),
	}

	TW_BL.STICKERS = STICKERS

	function STICKERS.get_raw_key(name)
		return "twbl_" .. name
	end
	function STICKERS.get_key(name)
		return "twbl_" .. name
	end
	function STICKERS.get(name)
		return STICKERS.storage[STICKERS.get_key(name)]
	end

	function STICKERS.register(sticker)
		table.insert(STICKERS.loaded, sticker.key)
		STICKERS.storage[sticker.key] = sticker
		return sticker
	end

	for _, sticker_name in ipairs(stickers_to_load) do
		assert(load(nativefs.read(TW_BL.current_mod.path .. "stickers/" .. sticker_name .. ".lua")))()
	end

	return STICKERS
end
