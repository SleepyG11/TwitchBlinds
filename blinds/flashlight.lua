local tw_blind = SMODS.Blind {
    key = 'twbl_flashlight',
    loc_txt = {
        ['en-us'] = {
            name = 'The Flashlight',
            text = { "All cards face down. Chat can flip them.", "Use: toggle <card position>" }
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

table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_flashlight');

function blind_flashlight_toggle_card_flip(username, index)
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= "bl_twbl_flashlight" then return end
    if G.hand and G.hand.cards and G.hand.cards[index] then
        G.GAME.blind:wiggle()
        local card = G.hand.cards[index]
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
        card:flip()
    end
end

function tw_blind:stay_flipped()
    return true
end
