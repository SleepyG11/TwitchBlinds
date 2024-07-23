local tw_blind = SMODS.Blind {
    key = 'twbl_taxes',
    loc_txt = {
        ['en-us'] = {
            name = 'The Taxes',
            text = { 'Current Jokers', 'became Rental' }
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

table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_taxes');

function tw_blind:set_blind()
    G.GAME.blind:wiggle()
    for k, v in ipairs(G.jokers.cards) do
        G.E_MANAGER:add_event(Event({
            func = function()
                v:juice_up(); return true
            end
        }))
        v:set_rental(true)
        delay(0.23)
    end
end
