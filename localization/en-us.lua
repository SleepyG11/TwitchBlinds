return {
	descriptions = {
		Other = {
			twbl_interactive = {
				name = "Interactive",
				text = { "Chat has interaction", "inside this booster pack" },
			},
		},
		Blind = {
			bl_twbl_chat = {
				name = "The Chat",
				text = { "Select to end voting and", "begin a challenge from Chat" },
			},
			bl_twbl_banana = {
				name = "The Banana",
				text = { "Each Joker has a", "#1# in #2# chance to be", "replaced with Gros Michel" },
				interaction_text = "Gamble for Cavendish!",
			},
			bl_twbl_taxes = {
				name = "The Taxes",
				text = { "Each Joker has a", "#1# in #2# chance to", "become Rental" },
			},
			bl_twbl_lucky_wheel = {
				name = "The Lucky Wheel",
				text = { "#1# in #2# chance to change", "edition on all Jokers" },
			},
			bl_twbl_blank = {
				name = "The Blank",
				text = { "Does nothing?" },
			},
			bl_twbl_chaos = {
				name = "The Chaos",
				text = { "Chat can select", "and deselect cards" },
				interaction_text = "Select/deselect card in hand",
			},
			bl_twbl_chisel = {
				name = "The Chisel",
				text = { "The first #1#", "does not score" },
			},
			bl_twbl_circus = {
				name = "The Circus",
				text = { "The show is", "about to begin!" },
			},
			bl_twbl_clock = {
				name = "The Hourglass",
				text = { "Hurry up!" },
			},
			-- bl_twbl_dice = {
			-- 	name = "The Dice",
			-- 	text = { "The Chat can roll to gain 1$", "#1# in #2# chance to lose 6$", "Single-Use: roll" },
			-- },
			bl_twbl_expiration = {
				name = "The Expiration Date",
				text = { "All food Jokers are", "out-of-date" },
			},
			bl_twbl_flashlight = {
				name = "The Flashlight",
				text = { "Cards drawn face down", "Chat can flip them" },
				interaction_text = "Flip card in hand",
			},
			bl_twbl_greed = {
				name = "The Greed",
				text = { "Chat can affect shop" },
			},
			bl_twbl_isaac = {
				name = "The Voice of God",
				text = { "To prove your love and devotion", "I require a sacrifice!" },
			},
			bl_twbl_jimbo = {
				name = "The Jimbo",
				text = { "Hey, look!", "It's a Jimbo!" },
			},
			bl_twbl_lock = {
				name = "The Lock",
				text = { "Chat can add or remove", "Eternal sticker on Jokers" },
				interaction_text = "Add/remove Eternal sticker on Joker",
			},
			bl_twbl_moon = {
				name = "The Moon",
				text = { "Chat has bestowed", "the Planet vouchers unto you" },
			},
			bl_twbl_sparkle = {
				name = "The Sparkle",
				text = { "Chat has bestowed", "the Magic Trick and Illusion", "vouchers unto you" },
			},
			bl_twbl_pin = {
				name = "The Pin",
				text = { "Chat can pin", "and unpin Jokers" },
				interaction_text = "Pin/unpin a Joker",
			},
			bl_twbl_precision = {
				name = "The Precision",
				text = { "Discards must", "contain 5 cards" },
			},
			bl_twbl_trash_can = {
				name = "The Trash Can",
				text = { 'Chat can "cleanup" a deck' },
			},
			bl_twbl_vaporation = {
				name = "The Vaporation",
				text = { "Current Jokers will", "become Perishable" },
			},
			bl_twbl_eraser = {
				name = "The Eraser",
				text = { "Joker chosen by Chat", "will be destroyed" },
				interaction_text = "Choose a Joker to destroy",
			},
			bl_twbl_stock_market = {
				name = "The Stock Market",
				text = { "Chat can reinvest money", "into Jokers" },
				interaction_text = "Choose a Joker to invest in",
			},
			bl_twbl_sketch = {
				name = "The Sketch",
				text = { "Joker chosen by Chat", "will be copied" },
				interaction_text = "Choose a Joker to copy",
			},
			bl_twbl_nope = {
				name = "Nope!",
				text = { "Nope!" },
				interaction_text = "Nope!",
			},
			bl_twbl_misstock = {
				name = "The Misstock",
				text = { "Chat can select which", "single card type will", "appear in next shops" },
			},
			bl_twbl_incrementor = {
				name = "The Incrementor",
				text = { "Chat can start counting", "to increase the blind's size" },
			},
			bl_twbl_spiral = {
				name = "The Time Spiral",
				text = { "Chat can move in time..." },
			},
			-- bl_twbl_fee = {
			-- 	name = "The Fee",
			-- 	text = { "[DEV]" },
			-- },
			bl_twbl_garden = {
				name = "The Garden",
				text = { "Free flowers for you!" },
			},
			-- bl_twbl_rocket = {
			-- 	name = "The Rocket",
			-- 	text = { "My beloved!" },
			-- },
			bl_twbl_university = {
				name = "The University",
				text = { "Time to learn how to", "play less bad!" },
			},
			bl_twbl_vacation = {
				name = "The Vacation",
				text = { "Finally, a vacation!", "Chat, what we gonna", "do today?" },
			},
			bl_twbl_acceptance = {
				name = "The Acceptance",
				text = { "Chat has bestowed a", "Spectral card unto you" },
			},

			-- bl_twbl_washer = {
			-- 	name = "The Washer",
			-- 	text = { "Chat can select how to", "clean up a deck" },
			-- },

			-- Showdown
			bl_twbl_plum_hammer = {
				name = "Plum Hammer",
				text = { "Chat can add or remove", "up to #1# debuffs on Jokers" },
				interaction_text = "Add/remove debuff on Joker",
			},
		},
	},
	misc = {
		labels = {
			twbl_interactive = "Interactive",
		},
		v_dictionary = {
			twbl_for_shops = "for #1# shops",
			twbl_for_antes = "for #1# antes",

			twbl_votes_amount_singular = "#1# vote/user",
			twbl_votes_amount_plural = "#1# votes/user",
			twbl_votes_cooldown_singular = "#1# second cooldown/user",
			twbl_votes_cooldown_plural = "#1# seconds cooldown/user",
			twbl_votes_amount_unlimited = "unlimited votes/user",

			twbl_greed_effect_no_shop = "No shop",
			twbl_greed_effect_no_reroll = "No rerolls",
			twbl_greed_effect_change_shop_slots = "#1# shop slots",
			twbl_greed_effect_change_booster_slots = "#1# booster packs",
			twbl_greed_effect_change_voucher_slots = "#1# vouchers",
			twbl_greed_effect_multiply_price = "#1#% to all prices",
			twbl_greed_effect_increase_price = "#1#$ to all prices",

			twbl_trash_can_filter_all_discarded = "all discarded cards",
			twbl_trash_can_filter_all_played = "all played cards",
			twbl_trash_can_filter_random = "#2# random cards",
			twbl_trash_can_filter_most_common_type = "most common #1#",
			twbl_trash_can_filter_least_common_type = "least common #1#",
			twbl_trash_can_filter_random_type = "random #1#",
			twbl_trash_can_filter_all = "all cards in deck",

			twbl_jimbo_grow_up = "Make Jimbo bigger",
			twbl_jimbo_grow_down = "Make Jimbo smaller",

			twbl_trash_can_effect_remove = "Remove cards",
			twbl_trash_can_effect_duplicate = "Duplicate cards",
			twbl_trash_can_effect_randomize = "Randomize #1#",
			twbl_trash_can_effect_remove_field = "Remove #1#",
			twbl_trash_can_effect_make_a_stone = "Convert to Stone",

			twbl_interactive_Standard_single = "Choose a card to add to deck",
			twbl_interactive_ArcanaSpectral_multiple = "Choose a consumable to use",

			twbl_settings_channel_name = "#1# channel",
		},
		dictionary = {
			b_twbl_apply_and_connect = "Save & Connect",

			twbl_settings_channel_name_description_twitch = {
				"https://twitch.tv/{C:attention}channel_name{}",
			},
			twbl_settings_channel_name_description_youtube = {
				"https://youtube.com/{C:attention}@channel_name{} {s:0.8,C:inactive}keep @{}",
				"https://youtube.com/channel/{C:attention}channel_id{} {s:0.8,C:inactive}without @{}",
			},

			twbl_settings_enter_channel_name = "Enter channel name",
			twbl_settings_paste_name_or_url = {
				"Paste name",
				"or url",
			},

			twbl_settings_blind_voting_frequency = "Blind voting frequency",
			twbl_settings_blind_voting_frequency_opt = {
				[1] = "Disabled",
				[2] = "Every 2 antes",
				[3] = "Every ante",
			},
			twbl_settings_blind_voting_frequency_desc = {
				"Determines how often chat",
				"can vote for a new blind",
			},

			twbl_settings_blind_voting_pool_type = "Blinds available for voting",
			twbl_settings_blind_voting_pool_type_opt = {
				[1] = "Twitch Blinds",
				[2] = "Vanilla + other Mods",
				[3] = "All",
			},
			twbl_settings_blind_voting_pool_type_desc = {
				"Determines which blinds can",
				"appear for voting",
			},

			twbl_settings_blind_voting_allow_repeats = "Unique blinds",
			twbl_settings_blind_voting_allow_repeats_opt = {
				[1] = "No repeats",
				[2] = "Allow repeats",
			},
			twbl_settings_blind_voting_allow_repeats_desc = {
				"Determines can blinds",
				"repeat between antes",
			},

			twbl_settings_mystic_variants = "Mystic voting variants",
			twbl_settings_mystic_variants_desc = {
				"In voting, some variants will be hidden",
				"to make results more unpredictable",
			},

			twbl_settings_bypass_discovery_check = "Bypass discovery checks",
			twbl_settings_bypass_discovery_check_desc = {
				"In voting, show blind's description",
				"even if it hasn't been discovered yet",
			},

			twbl_settings_interactive_sticker = "Interactive Booster sticker",
			twbl_settings_interactive_sticker_opt = {
				[1] = "Disabled",
				[2] = "On some booster packs",
				[3] = "On all booster packs",
			},
			twbl_settings_interactive_sticker_desc = {
				"In booster packs, new sticker can appear",
				"which adds chat interactions in them",
			},

			twbl_arg_type_Number = "number",
			twbl_arg_type_edition = "edition",
			twbl_arg_type_rank = "rank",
			twbl_arg_type_suit = "suit",
			twbl_arg_type_seal = "seal",

			twbl_arg_pos_DEFAULT_singular = "item position",
			twbl_arg_pos_Card_singular = "card position",
			twbl_arg_pos_Joker_singular = "joker position",
			twbl_arg_pos_Consumeable_singular = "consumable position",
			twbl_arg_pos_Booster_singular = "booster pack position",

			twbl_arg_pos_DEFAULT_plural = "items position",
			twbl_arg_pos_Card_plural = "cards position",
			twbl_arg_pos_Joker_plural = "jokers position",
			twbl_arg_pos_Consumeable_plural = "consumables position",
			twbl_arg_pos_Booster_plural = "booster packs position",

			k_twbl_cant_use_ex = "Can't use!",
			k_twbl_tumors_ex = "Tumors!",
			k_twbl_banana_ex = "Banana!",
			k_twbl_banana_qu = "Banana?",
			k_twbl_taxes_ex = "Taxes!",
			k_twbl_erased_ex = "Erased!",
			k_twbl_nope_ex = "Nope!",
			k_twbl_replaced_ex = "Replaced!",
			k_twbl_unbanned_ex = "Unbanned!",
			k_twbl_vote_ex = "Vote!",
			k_twbl_toggle_ex = "Toggle!",
			k_twbl_interact_ex = "Interact!",
			k_twbl_flip_ex = "Flip!",
			k_twbl_lock_ex = "Lock!",
			k_twbl_pin_ex = "Pin!",
			k_twbl_select_ex = "Select!",
			k_twbl_erase_ex = "Erase!",
			k_twbl_sketch_ex = "Sketch!",
			k_twbl_count_ex = "Count!",
			k_twbl_reset_ex = "Reset!",
			k_twbl_trash_ex = "Trash!",
			k_twbl_chaos_ex = "CHAOS!",
			k_twbl_showdown_ex = "Showdown!",
			k_twbl_always_pray_ex = "Always pray!",
			k_twbl_be_greedy_ex = "Be greedy!",
			k_twbl_target_ex = "Target!",
			k_twbl_choose_ex = "Choose!",
			k_twbl_never_lucky_ex = "Never lucky!",
			k_twbl_jimbo_ex = "Jimbo!",
			k_twbl_invest_ex = "Invest!",

			twbl_no_edition = "No edition",

			-- k_twbl_panel_toggle_DEFAULT = "Trigger the boss blind's effect",
			-- k_twbl_panel_toggle_flashlight = "Flip a card in hand (3 times per chatter)",
			-- k_twbl_panel_toggle_pin = "(Un)pin Joker (once per chatter)",
			-- k_twbl_panel_toggle_lock = "Add/remove Eternal sticker on Joker (once per chatter)",
			-- k_twbl_panel_toggle_chaos = "(De)select card in hand (multiple use)",
			-- k_twbl_panel_toggle_eraser = "Select a Joker for deletion (once per chatter)",
			-- k_twbl_panel_toggle_sketch = "Select a Joker for copying (once per chatter)",
			-- k_twbl_panel_toggle_nope = "Nope! (multiple Nope!)",
			-- k_twbl_panel_toggle_incrementor = "Keep counting! (multiple use)",
			-- k_twbl_panel_toggle_plum_hammer = "Add/remove debuff on Joker (once per chatter)",

			-- k_twbl_panel_toggle_interactive_consumeable = "Select a target for consumable (once per chatter)",
			-- k_twbl_panel_toggle_interactive_celestial = "Select a poker hand to downgrade (once per chatter)",
			-- k_twbl_panel_toggle_interactive_standard = "Select a card to add to deck (once per chatter)",

			-- k_twbl_panel_toggle_interactive_consumeable_single = "Select a target for consumable (once per chatter)",
			-- k_twbl_panel_toggle_interactive_consumeable_multiple = "Select a consumable to use (once per chatter)",
			-- k_twbl_panel_toggle_interactive_celestial_single = "Select a poker hand to downgrade (once per chatter)",
			-- k_twbl_panel_toggle_interactive_standard_single = "Select a card to add to deck (once per chatter)",

			-- k_twbl_spiral_p_1 = "+1 Ante",
			-- k_twbl_spiral_p_2 = "+2 Antes",
			-- k_twbl_spiral_m_1 = "-1 Ante",
			-- k_twbl_spiral_m_2 = "-2 Antes",

			-- k_twbl_vacation_touch_grass = "Touch grass",
			-- k_twbl_vacation_touch_grass_description_1 = "First time ever we gonna do it!",
			-- k_twbl_vacation_buy_flowers = "Buy flowers",
			-- k_twbl_vacation_buy_flowers_description_1 = "They're so cute!",
			-- k_twbl_vacation_visit_circus = "Visit circus",
			-- k_twbl_vacation_visit_circus_description_1 = "I'm so excited! Let's show begins!",
			-- k_twbl_vacation_go_camping = "Go camping",
			-- k_twbl_vacation_go_camping_description_1 = "You see a mountain? You can climb it!",
			-- k_twbl_vacation_go_mining = "Go mining",
			-- k_twbl_vacation_go_mining_description_1 = "Gold! Gold! Gold!",
			-- k_twbl_vacation_worldwide_trip = "Worldwide trip",
			-- k_twbl_vacation_worldwide_trip_description_1 = "Is this a crazy trip? Absolutely!",
			-- k_twbl_vacation_be_creative = "Be creative",
			-- k_twbl_vacation_be_creative_description_1 = "Use all your imagination!",
			-- k_twbl_vacation_explore_space = "Explore space",
			-- k_twbl_vacation_explore_space_description_1 = "So much secrets in endless space!",
			-- k_twbl_vacation_predict_future = "Predict future",
			-- k_twbl_vacation_predict_future_description_1 = "Feels lucky?",
			-- k_twbl_vacation_be_successful = "Be successful",
			-- k_twbl_vacation_be_successful_description_1 = "It's so easy, just make more money!",
			-- k_twbl_vacation_play_balatro = "Play Balatro",
			-- k_twbl_vacation_play_balatro_description_1 = "Play now! Or else...",

			-- k_twbl_clock_count_up = "+0.5 seconds",
			-- k_twbl_clock_count_down = "-1 second",

			k_twbl_waiting_for_chat = "Waiting for chat...",

			twbl_connection_status = {
				[-1] = "No channel!",
				[0] = "Disconnected...",
				[1] = "Connecting...",
				[2] = "Connected",
			},
		},
		quips = {
			twbl_blinds_university_1 = { "Alright, folks,", "welcome back!" },
			twbl_blinds_university_2 = { "I have proposition." },
			twbl_blinds_university_3 = { "Now we're cooking!" },
			twbl_blinds_university_4 = { "Let's ship it!" },

			twbl_blinds_garden_1 = { "Disgusting!" },
			twbl_blinds_garden_2 = { "We can make it work!" },
			twbl_blinds_garden_3 = { "Bummer!" },
			twbl_blinds_garden_4 = { "Oh beans!" },

			twbl_blinds_sparkle_1 = { "Here's a trick!" },
			twbl_blinds_sparkle_2 = { "What about even more cards?" },
			twbl_blinds_sparkle_3 = { "I love shiny ones!" },
			twbl_blinds_sparkle_4 = { "Let's find your", "{C:attention}One-of-a-Kind{} card!" },

			twbl_blinds_moon_1 = { "It's too much." },
			-- twbl_blinds_moon_2 = { "It's too much." },
			-- twbl_blinds_moon_3 = { "It's too much." },
			-- twbl_blinds_moon_4 = { "It's too much." },

			twbl_blinds_jimbo_1 = {
				"I'm doing my best!",
			},
			twbl_blinds_jimbo_2 = {
				"Hey, look! It's Me!",
			},
			twbl_blinds_jimbo_3 = {
				"I'm literally",
				"a fool, what's",
				"your excuse?",
			},
			twbl_blinds_jimbo_4 = {
				"Hello there! My name is",
				"{C:attention}Jimbo{}, I'm here to help",
				"you learn how to play!",
			},
			twbl_blinds_jimbo_5 = {
				"Be picky, you can only",
				"carry {C:attention}5 Joker{} cards",
				"at a time!",
			},
			twbl_blinds_jimbo_6 = {
				"I'm one of the {C:attention}many",
				"{C:attention}Jokers{} you can add to",
				"your run. Every {C:attention}Joker",
				"does something different",
			},
			twbl_blinds_jimbo_7 = {
				"You wanna be {C:attention}my friend{}?",
				"I have {C:attention}a lot{} of ... friends!",
			},

			twbl_blinds_circus_1 = { "Hello there!" },
		},
	},
}
