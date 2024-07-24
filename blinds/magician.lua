local tw_blind = SMODS.Blind {
    key = 'twbl_magician',
    loc_txt = {
        ['en-us'] = {
            name = 'The Magician',
            text = { "Redeems Magic Trick", "and Illusion" }
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

table.insert(TWITCH_BLINDS.BLINDS, 'bl_twbl_magician');

function tw_blind:set_blind()
    G.GAME.blind:wiggle()
    play_sound('card1')
    if not G.GAME.used_vouchers['v_magic_trick'] then
        G.GAME.used_vouchers['v_magic_trick'] = true
        Card:apply_to_run(G.P_CENTERS['v_magic_trick']);
    end
    if not G.GAME.used_vouchers['v_illusion'] then
        G.GAME.used_vouchers['v_illusion'] = true
        Card:apply_to_run(G.P_CENTERS['v_illusion']);
    end
end
