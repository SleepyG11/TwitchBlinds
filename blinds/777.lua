local tw_blind = SMODS.Blind {
    key = register_twitch_blind('777', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The 777',
            text = { "Triples all", "listed probabilities" }
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
    for k, v in pairs(G.GAME.probabilities) do
        G.GAME.probabilities[k] = v * 3
    end
end
