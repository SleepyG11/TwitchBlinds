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
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 1 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('8e15ad'),
}

function tw_blind:debuff_card()
    if card.area ~= G.jokers then
        return true
    end
end
