local tw_blind = SMODS.Blind {
    key = register_twitch_blind('taxes', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Taxes',
            text = { "Current Jokers", "became Rental" }
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
    for k, v in ipairs(G.jokers.cards) do
        v:juice_up()
        card_eval_status_text(v, 'extra', nil, nil, nil, { message = G.localization.misc.labels.rental .. '!' })
        v:set_rental(true)
        delay(0.23)
    end
end
