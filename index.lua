to_big = to_big or function(x)
	return x
end
to_number = to_number or function(x)
	return x
end

TW_BL = setmetatable({
	current_mod = SMODS.current_mod,

	FLAGS = {},
	TEMP = {},

	refs = {},
}, {
	__index = function(table, index)
		if index == "G" then
			if G.GAME and not G.GAME.twbl then
				G.GAME.twbl = {}
			end
			return G.GAME and G.GAME.twbl or {}
		else
			return rawget(table, index)
		end
	end,
	__newindex = function(table, index, value)
		if index == "G" then
			if G.GAME then
				G.GAME.twbl = (G.GAME.twbl or value or {})
			end
		else
			rawset(table, index, value)
		end
	end,
})

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 34,
	py = 34,
})

function TW_BL.load_file(file)
	return assert(SMODS.load_file(file))()
end
function TW_BL.load_files(files, prefix)
	for _, file in pairs(files) do
		TW_BL.load_file(prefix .. file)
	end
end

TW_BL.load_file("src/index.lua")

-- TODO:
-- 1. how imeplement sticker for buffoon and celestial?
-- 2. pause for chatters to vote
-- 3. description for reroll vouchers
-- 4. Implement displaying optional votes count on cards