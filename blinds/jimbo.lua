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
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 12 },
    config = { extra = { twitch_blind = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('0077e8'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    G.GAME.blind:wiggle()
    local card = create_card('Joker', G.jokers, false, nil, nil, nil, 'j_joker', nil)
    card:set_eternal(true)
    card:add_to_deck()
    G.jokers:emplace(card)
end
