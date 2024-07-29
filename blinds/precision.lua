local tw_blind = SMODS.Blind {
    key = register_twitch_blind('precision', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Precision',
            text = { "Must discard 5 cards" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 15 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('90c8c2'),
}

-- Mechanic injection implemented via lovely
