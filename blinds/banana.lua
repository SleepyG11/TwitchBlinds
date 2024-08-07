local REPLACE_ODDS = 6

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('banana', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Banana',
            text = { "#1# in #2# chance to replace", "Joker with Gros Michel" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    config = { extra = { odds = REPLACE_ODDS }, tw_bl = { in_pool = true, min = 2 } },
    vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1), REPLACE_ODDS },
    pos = { x = 0, y = 4 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('e2ce00'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    local cards_to_remove = {}
    for _, v in ipairs(G.jokers.cards) do
        if pseudorandom(pseudoseed('twbl_afk')) < G.GAME.probabilities.normal / self.config.extra.odds then
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
                        local card = create_card('Joker', G.jokers, false, nil, nil, nil, 'j_gros_michel', nil)
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        return true;
                    end
                }))
                return true
            end
        }))
        card_eval_status_text(v, 'extra', nil, nil, nil, { message = G.localization.misc.dictionary.k_upgrade_ex })
    end
end
