local default_config = {
	version = 2,

	-- 1 = never
	-- 2 = once per 2 antes
	-- 3 = once per ante
	blind_voting_frequency = {
		value = 2,
	},

	-- 1 = only twitch blinds
	-- 2 = other blinds (vanilla + modded)
	-- 3 = all
	blind_voting_pool_type = {
		value = 3,
	},
	-- 1 = vanilla blind uniqueness mechanic
	-- 2 = blinds can repeat between votings
	blind_voting_allow_repeats = {
		value = 1,
	},

	twitch_channel_name = {
		value = "",
	},
	youtube_channel_name = {
		value = "",
	},

	mystic_variants = {
		enabled = false,
	},
	bypass_discovery_check = {
		enabled = false,
	},

	interactive_sticker = {
		value = 2,
	},
}

TW_BL.config.default = default_config
