local tw_blind = SMODS.Blind {
    key = register_twitch_blind('chaos', false),
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 17 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('55314b'),
}

function tw_blind:set_blind()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', true, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
    TW_BL.UI.set_panel('blind_action_toggle', true, true, {
        "dictionary",
        "k_twbl_interact_ex",
        "twbl_position_singular",
        "Card",
        "dictionary",
        "k_twbl_panel_toggle_chaos"
    })
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
    TW_BL.UI.remove_panel('blind_action_toggle', true)
end

TW_BL.EVENTS.add_listener('twitch_command', get_twitch_blind_key('chaos'), function(command, username, index)
    if command ~= 'toggle' then return end
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= get_twitch_blind_key('chaos') then return end
    if G.hand and G.hand.cards and G.hand.cards[index] then
        G.GAME.blind:wiggle()
        local card = G.hand.cards[index]
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
        for i = #G.hand.highlighted, 1, -1 do
            if G.hand.highlighted[i] == card then
                table.remove(G.hand.highlighted, i)
                card:highlight(false)
                return
            end
        end
        G.hand.highlighted[#G.hand.highlighted + 1] = card
        card:highlight(true)
        G.hand:parse_highlighted()
    else
        TW_BL.CHAT_COMMANDS.decrement_command_use('toggle', username)
    end
end)
