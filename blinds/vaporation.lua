local tw_blind = SMODS.Blind {
    key = register_twitch_blind('vaporation', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Vaporation',
            text = { "Current Jokers", "became Perishable" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 5 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('a7d2ce'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    G.GAME.blind:wiggle()
    for k, v in ipairs(G.jokers.cards) do
        G.GAME.blind:wiggle()
        G.E_MANAGER:add_event(Event({
            func = function()
                v:juice_up(0.3, 0.4)
                v:set_perishable(true)
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
        card_eval_status_text(v, 'extra', nil, nil, nil, { message = G.localization.misc.labels.perishable .. '!' })
    end
end
