local tw_blind = SMODS.Blind {
    key = 'twitch_chat',
    loc_txt = {
        ['en-us'] = {
            name = 'The Chat',
            text = { 'Select to end voting and', 'begin a challenge from chat' }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 0 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('8e15ad'),
    discovered = true,
}
