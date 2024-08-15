local tw_blind = SMODS.Blind {
    key = register_twitch_blind('flashlight', false),
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 3 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('e9db00'),
}

function tw_blind:set_blind()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', true, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', true, true)
    TW_BL.UI.set_panel('blind_action_toggle', true, true, {
        "dictionary",
        "k_twbl_flip_ex",
        "twbl_position_singular",
        "Card",
        "dictionary",
        "k_twbl_panel_toggle_flashlight"
    })
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
    TW_BL.UI.remove_panel('blind_action_toggle', true)
end

TW_BL.EVENTS.add_listener('twitch_command', get_twitch_blind_key('flashlight'), function(command, username, index)
    if command ~= 'toggle' then return end
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= get_twitch_blind_key('flashlight') then return end
    if G.hand and G.hand.cards and G.hand.cards[index] then
        G.GAME.blind:wiggle()
        local card = G.hand.cards[index]
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
        card:flip()
    else
        TW_BL.CHAT_COMMANDS.decrement_command_use('toggle', username)
    end
end)

function tw_blind:stay_flipped()
    return true
end
