local tw_blind = SMODS.Blind {
    key = 'twbl_chisel',
    loc_txt = {
        ['en-us'] = {
            name = 'The Chisel',
            text = { "First #1#", "does not score" }
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

table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_chisel');

function tw_blind:loc_vars()
    local selected_hand = nil
    if G.GAME.blind and G.GAME.blind.hands and G.GAME.blind.hands.selected then
        -- If hand selected before, use it
        selected_hand = G.GAME.blind.hands.selected
    else
        -- Find true most played hand and display it
        local _handname, _played, _order = 'High Card', -1, 100
        for k, v in pairs(G.GAME.hands) do
            if v.played > _played or (v.played == _played and _order > v.order) then
                _played = v.played
                _handname = k
            end
        end
        selected_hand = _handname
    end

    return { vars = { localize(selected_hand, 'poker_hands') } }
end

function tw_blind:collection_loc_vars()
    return { vars = { localize('ph_most_played') } }
end

function tw_blind:set_blind()
    -- Find true most played hand and save it
    local _handname, _played, _order = 'High Card', -1, 100
    for k, v in pairs(G.GAME.hands) do
        if v.played > _played or (v.played == _played and _order > v.order) then
            _played = v.played
            _handname = k
        end
    end

    G.GAME.blind.hands = {
        ['debuffed'] = _handname,
        ['selected'] = _handname
    }
end

function tw_blind:debuff_hand(cards, hand, handname, check)
    if G.GAME.blind.hands and G.GAME.blind.hands.debuffed == handname then
        if not check then G.GAME.blind.hands.debuffed = nil end
        return true
    end
    return false
end