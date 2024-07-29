local FOOL_JOKERS = {
    ["Gros Michel"] = true,
    ["Egg"] = true,
    ["Ice Cream"] = true,
    ["Cavendish"] = true,
    ["Turtle Bean"] = true,
    ["Diet Cola"] = true,
    ["Popcorn"] = true,
    ["Ramen"] = true,
    ["Seltzer"] = true,
}

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('expiration', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Expiration Date',
            text = { "All food Jokers are", "out of expiration date" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 9 },
    config = { tw_bl = { in_pool = true, max = 4 } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('b35216'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    local cards_to_remove = {}
    for _, v in ipairs(G.jokers.cards) do
        if FOOL_JOKERS[v.ability.name] then
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
                        return true;
                    end
                }))
                return true
            end
        }))
        -- TODO: localization
        card_eval_status_text(v, 'extra', nil, nil, nil, { message = "Tumors!" })
    end
end
