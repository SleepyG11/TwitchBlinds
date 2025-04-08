local nativefs = require("nativefs")

local stickers_to_load = {
	"chat_booster",
}

function twbl_init_stickers()
	local STICKERS = {
		loaded = {},

		storage = {},
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

	function STICKERS.create(sticker_definition, atlas_definition, no_register)
		local key = sticker_definition.key
		SMODS.Atlas(atlas_definition or {
			key = "twbl_sticker_atlas_" .. key,
			px = 71,
			py = 95,
			path = "stickers/" .. key .. ".png",
		})
		sticker_definition.key = TW_BL.STICKERS.get_raw_key(key)
		sticker_definition.atlas = "twbl_sticker_atlas_" .. key
		sticker_definition.pos = { x = 0, y = 0 }
		local sticker = SMODS.Sticker(sticker_definition)
		if not no_register then
			return STICKERS.register(sticker)
		else
			return sticker
		end
	end

	function STICKERS.register(sticker)
		table.insert(STICKERS.loaded, sticker.key)
		STICKERS.storage[sticker.key] = sticker
		return sticker
	end

	for _, sticker_name in ipairs(stickers_to_load) do
		assert(load(nativefs.read(TW_BL.current_mod.path .. "additions/stickers/" .. sticker_name .. ".lua")))()
	end

	return STICKERS
end
