local tw_blind = SMODS.Blind {
    key = register_twitch_blind('isaac', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Voice of God',
            text = { "To prove your love and devotion", "I require a sacrifice!" }
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
    boss_colour = HEX('d82727'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    G.GAME.blind:wiggle()
    local card = create_card('Joker', G.jokers, false, nil, nil, nil, 'j_ceremonial', nil)
    card.pinned = true
    card:set_eternal(true)
    card:add_to_deck()
    G.jokers:emplace(card)
end
