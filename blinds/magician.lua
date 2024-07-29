local tw_blind = SMODS.Blind {
    key = register_twitch_blind('magician', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Magician',
            text = { "Redeems Magic Trick", "and Illusion" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 6 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('be35b0'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
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
