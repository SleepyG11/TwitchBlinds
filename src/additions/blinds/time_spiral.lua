SMODS.Atlas({
	key = "twbl_blind_atlas_time_spiral",
	px = 34,
	py = 34,
	path = "blinds/time_spiral.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

local blind = SMODS.Blind({
	key = "time_spiral",
	dollars = 5,
	mult = 2,
	boss = { min = 4, max = 6 },
	boss_colour = HEX("9e7442"),

	atlas = "twbl_blind_atlas_time_spiral",

	in_pool = function(self)
		return false
	end,

	twbl_is_twitch_blind = true,
	twbl_in_pool = function(self)
		return TW_BL.blinds.is_in_range(self, true) and pseudorandom("twbl_time_spiral_encounter") < 0.10
	end,
})

TW_BL.blinds.bootstrap_interactive_blind(blind, {
	connected_status_text = function()
		return localize("k_twbl_vote_ex")
	end,
	weighted_voting = true,
	default_weight_score = 0.5,
	set_vote_variants = function()
		return { "left", "right" }
	end,
	command = "vote",
	command_max_uses = 1,
	progress_w = 8,
	get_items = function(_, args)
		return {
			left = {
				command = args.command .. " left",
			},
			right = {
				command = args.command .. " right",
			},
			progress = {
				{
					pos = 0.1,
					center = true,
					text = localize({
						type = "variable",
						key = "twbl_ante_diff_plural",
						vars = { "-2" },
					}),
				},
				{
					pos = 0.2,
					line = true,
				},
				{
					pos = 0.3,
					center = true,
					text = localize({
						type = "variable",
						key = "twbl_ante_diff_singular",
						vars = { "-1" },
					}),
				},
				{
					pos = 0.4,
					line = true,
				},
				{
					pos = 0.5,
					center = true,
					text = TW_BL.L.command_use_limits(args.command_max_uses, args.command_use_refresh_timeout),
					colour = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.8),
				},
				{
					pos = 0.6,
					line = true,
				},
				{
					pos = 0.7,
					center = true,
					text = localize({
						type = "variable",
						key = "twbl_ante_diff_singular",
						vars = { "+1" },
					}),
				},
				{
					pos = 0.8,
					line = true,
				},
				{
					pos = 0.9,
					center = true,
					text = localize({
						type = "variable",
						key = "twbl_ante_diff_plural",
						vars = { "+2" },
					}),
				},
			},
		}
	end,
	apply_effect = function(weight)
		if weight == 1 then
			weight = 0.999
		end
		local ante_diff = math.floor(weight / 0.2) - 2
		if ante_diff ~= 0 then
			ease_ante(ante_diff)
		end
	end,
})
