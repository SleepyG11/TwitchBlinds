local tw_blind = SMODS.Blind {
    key = register_twitch_blind('moon', false),
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    config = { tw_bl = { in_pool = true } },
    pos = { x = 0, y = 7 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('00d4d4'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
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
