local REPLACE_ODDS = 1000

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('blank', false),
    dollars = 0,
    mult = 0,
    boss = {
        min = 999,
        max = 999
    },
    config = { extra = { odds = REPLACE_ODDS }, tw_bl = { in_pool = true, max = 4 } },
    vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1), REPLACE_ODDS },
    pos = { x = 0, y = 16 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('636c81'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    local cards_to_remove = {}
    for _, v in ipairs(G.jokers.cards) do
        if pseudorandom(pseudoseed('twbl_blank')) < G.GAME.probabilities.normal / G.GAME.blind.config.extra.odds then
            table.insert(cards_to_remove, v)
        end
    end
    for _, v in ipairs(cards_to_remove) do
        G.GAME.blind:wiggle()
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                v.T.r = -0.2
                v:juice_up(0.3, 0.4)
                v.states.drag.is = true
                v.children.center.pinch.x = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    blockable = false,
                    func = function()
                        G.jokers:remove_card(v)
                        v:remove()
                        v = nil
                        local card = create_card('Joker', G.jokers, false, nil, nil, nil, 'j_cavendish', nil)
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        return true;
                    end
                }))
                return true
            end
        }))
        card_eval_status_text(v, 'extra', nil, nil, nil, { message = G.localization.misc.dictionary.k_twbl_banana_qu })
    end
end
