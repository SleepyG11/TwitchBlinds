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
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 1 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('8e15ad'),
}

function tw_blind:set_blind()
    local _first_dissolve = nil
    for k, v in ipairs(G.jokers.cards) do
        if FOOL_JOKERS[v.ability.name] then
            G.GAME.blind:wiggle()
            card_eval_status_text(v, 'extra', nil, nil, nil,
                { message = G.localization.misc.dictionaly.k_extinct_ex })
            v:start_dissolve(nil, _first_dissolve)
            _first_dissolve = true
        end
    end
end
