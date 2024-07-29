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
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 14 },
    config = { extra = { twitch_blind = true, twitch_blind_min = 2 } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('d9c200'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    for k, v in ipairs(G.jokers.cards) do
        G.GAME.blind:wiggle()
        G.E_MANAGER:add_event(Event({
            func = function()
                v:juice_up(0.3, 0.4)
                v:set_rental(true)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    blockable = false,
                    func = function()
                        return true;
                    end
                }))
                return true
            end
        }))
        card_eval_status_text(v, 'extra', nil, nil, nil, { message = G.localization.misc.labels.rental .. '!' })
    end
end
