local tw_blind = SMODS.Blind {
    key = 'twbl_lock',
    loc_txt = {
        ['en-us'] = {
            name = 'The Lock',
            text = { "Chat can toggle eternal Jokers", "Use: toggle <joker position>" }
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

table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_lock');

function blind_lock_toggle_eternal_joker(username, index)
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= "bl_twbl_lock" then return end
    if G.jokers and G.jokers.cards and G.jokers.cards[index] then
        G.GAME.blind:wiggle()
        local card = G.jokers.cards[index]
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = username })
        card:set_eternal(not card.ability.eternal)
        card:juice_up()
    end
end
