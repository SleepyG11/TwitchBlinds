-- Test

local tw_blind = TW_BL.BLINDS.register(SMODS.Blind({
	key = TW_BL.BLINDS.get_raw_key("test"),
	dollars = 5,
	mult = 2,
	boss = { min = -1, max = -1 },
	pos = { x = 0, y = 14 },
	config = {
		tw_bl = {
			twitch_blind = true,
			in_pool = function()
				if not G then
					return false
				end
				return false
			end,
		},
	},
	atlas = "twbl_blind_chips",
	boss_colour = HEX("d9c200"),
}))

function tw_blind:in_pool()
	-- Debug
	return false
end

function tw_blind:set_blind(reset, silent)
	if reset then
		return
	end
end

function tw_blind:press_play() end
