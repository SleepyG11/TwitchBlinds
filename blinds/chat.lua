local tw_blind = SMODS.Blind {
    key = 'twbl_twitch_chat',
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 0 },
    config = { tw_bl = { ignore = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('8e15ad'),
    discovered = true,
    ignore_showdown_check = true,
}

function tw_blind:in_pool()
    return false
end