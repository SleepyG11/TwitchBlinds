local FOOL_JOKERS = {
    ["j_gros_michel"] = true,
    ["j_egg"] = true,
    ["j_ice_cream"] = true,
    ["j_cavendish"] = true,
    ["j_turtle_bean"] = true,
    ["j_diet_cola"] = true,
    ["j_popcorn"] = true,
    ["j_ramen"] = true,
    ["j_selzer"] = true,
}

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('expiration', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Expiration',
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
        if FOOL_JOKERS[G.jokers.cards.ability.name] then
            G.GAME.blind:wiggle()
            card_eval_status_text(v, 'extra', nil, nil, nil,
                { message = G.localization.misc.dictionaly.k_extinct_ex })
            v:start_dissolve(nil, _first_dissolve)
            _first_dissolve = true
        end
    end
end
