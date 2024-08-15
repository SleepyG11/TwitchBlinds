local tw_blind = SMODS.Blind {
    key = register_twitch_blind('greed', false),
    dollars = 8,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 21 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('bcbcbc'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    G.GAME.pool_flags.twitch_no_shop = true
end
