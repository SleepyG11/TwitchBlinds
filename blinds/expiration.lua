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
    pos = { x = 0, y = 9 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('b35216'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    local cards_to_remove = {}
    local _first_dissolve = false
    for _, v in ipairs(G.jokers.cards) do
        if FOOL_JOKERS[v.ability.name] then
            table.insert(cards_to_remove, v)
        end
    end
    for _, v in ipairs(cards_to_remove) do
        G.GAME.blind:wiggle()
        v:start_dissolve(nil, _first_dissolve)
        -- TODO: delay
        -- card_eval_status_text(v, 'extra', nil, nil, nil,
        --     { message = G.localization.misc.dictionary.k_extinct_ex })
    end
end
