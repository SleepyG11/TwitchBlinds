local tw_blind = SMODS.Blind {
    key = 'twbl_astronomer',
    loc_txt = {
        ['en-us'] = {
            name = 'The Astronomer',
            text = { "Redeems Planet Merchant", "and Planet Tycoon" }
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
table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_astronomer');

function tw_blind:set_blind()
    G.GAME.blind:wiggle()
    play_sound('card1')
    if not G.GAME.used_vouchers['v_planet_merchant'] then
        G.GAME.used_vouchers['v_planet_merchant'] = true
        Card:apply_to_run(G.P_CENTERS['v_planet_merchant']);
    end
    if not G.GAME.used_vouchers['v_planet_tycoon'] then
        G.GAME.used_vouchers['v_planet_tycoon'] = true
        Card:apply_to_run(G.P_CENTERS['v_planet_tycoon']);
    end
end
