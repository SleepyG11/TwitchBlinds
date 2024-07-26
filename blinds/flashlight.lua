local tw_blind = SMODS.Blind {
    key = register_twitch_blind('flashlight', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Flashlight',
            text = { "All cards face down, chat can flip them", "Single-Use: toggle <card position>" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 3 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('e9db00'),
}

function tw_blind:set_blind()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', true, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', true, true)
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
end

function blind_flashlight_toggle_card_flip(username, index)
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= get_twitch_blind_key('flashlight') then return end
    if G.hand and G.hand.cards and G.hand.cards[index] then
        G.GAME.blind:wiggle()
        local card = G.hand.cards[index]
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
        card:flip()
    else
        TW_BL.CHAT_COMMANDS.collector.users.toggle[username] = (TW_BL.CHAT_COMMANDS.collector.users.toggle[username] or 1) -
            1
    end
end

function tw_blind:stay_flipped()
    return true
end
