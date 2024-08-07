local tw_blind = SMODS.Blind {
    key = register_twitch_blind('pin', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Pin',
            text = { "Chat can (un)pin Jokers", "Single-Use: toggle <joker position>" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 19 },
    config = { tw_bl = { in_pool = true, min = 2 } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('af365a'),
}

function tw_blind:set_blind(reset, silent)
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', true, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', true, true)
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
end

function blind_lock_toggle_eternal_joker(username, index)
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= get_twitch_blind_key('pin') then return end
    if G.jokers and G.jokers.cards and G.jokers.cards[index] then
        G.GAME.blind:wiggle()
        local card = G.jokers.cards[index]
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
        card.pinned = not card.pinned
        card:juice_up()
    else
        TW_BL.CHAT_COMMANDS.decrement_command_use('toggle', username)
    end
end
