local tw_blind = SMODS.Blind {
    key = register_twitch_blind('jimbo', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Jimbo',
            text = { "Hey, look!", "It's a Jimbo!" }
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

function tw_blind:set_blind()
    G.GAME.blind:wiggle()
    local card = create_card('Joker', G.jokers, false, nil, nil, nil, 'j_joker', nil)
    card:set_eternal(true)
    card:add_to_deck()
    G.jokers:emplace(card)
end
