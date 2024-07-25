local tw_blind = SMODS.Blind {
    key = register_twitch_blind('lock', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Lock',
            text = { "Chat can toggle eternal Jokers", "Single-Use: toggle <joker position>" }
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
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', true, true)
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('toggle', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('toggle', false, true)
end

function blind_lock_toggle_eternal_joker(username, index)
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= get_twitch_blind_key('lock') then return end
    if G.jokers and G.jokers.cards and G.jokers.cards[index] then
        G.GAME.blind:wiggle()
        local card = G.jokers.cards[index]
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
        card:set_eternal(not card.ability.eternal)
        card:juice_up()
    end
end
