local tw_blind = SMODS.Blind {
    key = register_twitch_blind('trash_can', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Trash Can',
            text = { "All scored cards is", "removed from the deck" }
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

-- Mechanic injection implemented via lovely
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
            return true
        end
    }))
    delay(0.3)
    for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:calculate_joker({ remove_playing_cards = true, removed = scoring_hand })
    end
    -- Basically every hand triggers boss, but isn't that too op?
    -- G.GAME.blind.triggered = true
end
