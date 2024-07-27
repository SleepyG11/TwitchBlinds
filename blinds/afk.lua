local REPLACE_ODDS = 1000

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('afk', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The AFK',
            text = { "Does nothing?" }
        }
    },
    dollars = 0,
    mult = 0,
    boss = {
        min = 40,
        max = 40
    },
    config = { extra = { odds = REPLACE_ODDS } },
    vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1), REPLACE_ODDS },
    pos = { x = 0, y = 16 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('636c81'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    local cards_to_remove = {}
    local _first_dissolve = false
    for _, v in ipairs(G.jokers.cards) do
        if pseudorandom(pseudoseed('twbl_afk')) < G.GAME.probabilities.normal / self.config.extra.odds then
            table.insert(cards_to_remove, v)
        end
    end
    for _, v in ipairs(cards_to_remove) do
        G.GAME.blind:wiggle()
        v:start_dissolve(nil, _first_dissolve)
        -- TODO: make it sync with deletion animation
        -- card_eval_status_text(v, 'extra', nil, nil, nil,
        --     { message = G.localization.misc.dictionary.k_upgrade_ex })
        local card = create_card('Joker', G.jokers, false, nil, nil, nil, 'j_cavendish', nil)
        card:add_to_deck()
        G.jokers:emplace(card)
    end
end
