local tw_blind = SMODS.Blind {
    key = register_twitch_blind('test', false),
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 14 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('d9c200'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
end

function tw_blind:press_play()
    
end