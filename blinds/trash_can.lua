local tw_blind = SMODS.Blind {
    key = register_twitch_blind('trash_can', false),
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 2 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('dc6a10'),
}

-- Implementation in lovely.toml

function blind_trash_can_remove_scored_cards(scoring_hand)
    G.GAME.blind:wiggle()
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            play_sound('tarot1')
            for i = #scoring_hand, 1, -1 do
                local card = scoring_hand[i]
                if card.ability.name == 'Glass Card' then
                    card:shatter()
                else
                    card:start_dissolve(nil, i == #scoring_hand)
                end
            end
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i]:calculate_joker({ remove_playing_cards = true, removed = scoring_hand })
            end
            return true
        end
    }))
end
