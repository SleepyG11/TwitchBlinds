local tw_blind = SMODS.Blind {
    key = register_twitch_blind('end', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The End',
            text = { "ALL cards are debuffed" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 1 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('8e15ad'),
}

function tw_blind:debuff_card()
    if card.area ~= G.jokers then
        return true
    end
end
