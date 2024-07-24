local tw_blind = SMODS.Blind {
    key = 'twbl_precision',
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

table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_precision');

-- Mechanic injection implemented via lovely
