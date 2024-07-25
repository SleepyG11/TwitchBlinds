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
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 1 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('8e15ad'),
}

-- Mechanic injection implemented via lovely
