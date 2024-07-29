local LOSE_ODDS = 6

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('dice', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Dice',
            text = { "Chat can roll to gain 1$", "#1# in #2# chance to lose 6$", "Single-Use: roll" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    config = { extra = { odds = LOSE_ODDS }, tw_bl = { in_pool = true, min = 2 } },
    vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1), LOSE_ODDS },
    pos = { x = 0, y = 18 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('00d400'),
}

function tw_blind:set_blind()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('roll', true, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('roll', true, true)
end

function tw_blind:defeat()
    TW_BL.CHAT_COMMANDS.toggle_can_collect('roll', false, true)
    TW_BL.CHAT_COMMANDS.toggle_single_use('roll', false, true)
end

function blind_dice_roll(username)
    if G.GAME.blind.name ~= get_twitch_blind_key('dice') then return end
    local color = G.C.MONEY
    if pseudorandom(pseudoseed('twbl_dice')) < G.GAME.probabilities.normal / G.GAME.blind.config.blind.config.extra.odds then
        G.GAME.blind:wiggle()
        ease_dollars(-6, false)
        color = G.C.MULT
    else
        ease_dollars(1, false)
    end
    local money_ui = G.HUD:get_UIE_by_ID("dollar_text_UI")
    if money_ui then
        attention_text({
            text = username,
            scale = 0.4,
            hold = 0.5,
            backdrop_colour = color,
            align = "tm",
            major = money_ui,
            offset = { x = 0, y = -0.15 }
        })
    end
end
