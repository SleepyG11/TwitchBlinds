local tw_blind = SMODS.Blind {
    key = register_twitch_blind('lock', false),
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 8 },
    config = { tw_bl = { in_pool = true, min = 4 } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('c0c0c0'),
}

function tw_blind:set_blind(reset, silent)
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', true, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', true, true)
    TW_BL.UI.set_panel('blind_action_toggle', true, true, {
        "dictionary",
        "k_twbl_lock_ex",
        "twbl_position_singular",
        "Joker",
        "dictionary",
        "k_twbl_panel_toggle_lock"
    })
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
end

TW_BL.EVENTS.add_listener('twitch_command', get_twitch_blind_key('lock'), function(command, username, index)
    if command ~= 'toggle' then return end
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= get_twitch_blind_key('lock') then return end
    if G.jokers and G.jokers.cards and G.jokers.cards[index] then
        local card = G.jokers.cards[index]
        local initial_value = card.ability.eternal;
        card:set_eternal(not initial_value)
        if card.ability.eternal ~= initial_value then
            G.GAME.blind:wiggle()
            card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
            card:juice_up()
        else
            TW_BL.CHAT_COMMANDS.decrement_command_use('toggle', username)
        end
    else
        TW_BL.CHAT_COMMANDS.decrement_command_use('toggle', username)
    end
end)
