local tw_blind = SMODS.Blind {
    key = register_twitch_blind('chaos', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Chaos',
            text = { "Chat can (de)select cards", "Multi-Use: toggle <card position>" }
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
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', true, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
end

function blind_chaos_toggle_card(username, index)
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
        TW_BL.CHAT_COMMANDS.collector.users.toggle[username] = (TW_BL.CHAT_COMMANDS.collector.users.toggle[username] or 1) -
        1
    end
end
