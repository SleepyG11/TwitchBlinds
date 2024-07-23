local tw_blind = SMODS.Blind {
    key = 'twbl_chaos',
    loc_txt = {
        ['en-us'] = {
            name = 'The Chaos',
            text = { 'Chat also can (de)select cards', 'Use: select <card position>' }
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

table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_chaos');

function blind_chaos_toggle_card(index)
    if G.STATE ~= G.STATES.SELECTING_HAND or G.GAME.blind.name ~= "bl_twbl_chaos" then return end
    if G.hand and G.hand.cards and G.hand.cards[index] then
        local card = G.hand.cards[index]
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
    end
end
