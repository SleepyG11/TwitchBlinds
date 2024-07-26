local TIME_DELAY = 4 -- In seconds
local MULT_INCREMENT = 0.25
-- Total time to full grow: 4 * 4 * 6 = 92 seconds

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('clock', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Clock',
            text = { "Hurry up!" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 13 },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('896665'),
}

local timeout = TIME_DELAY

function blind_clock_increment_mult(mult)
    if mult >= 8 then return 8 end
    return mult + MULT_INCREMENT
end

function blind_clock_request_increment_mult(dt)
    timeout = timeout - dt
    if timeout <= 0 then
        timeout = timeout + TIME_DELAY
        if G.GAME and G.GAME.blind and G.GAME.blind.name == get_twitch_blind_key('clock') and G.GAME.round_resets.blind_states.Boss == 'Current' then
            G.GAME.blind:wiggle()
            G.GAME.blind.mult = blind_clock_increment_mult(G.GAME.blind.mult)
            G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante) * G.GAME.blind.mult *
                G.GAME.starting_params.ante_scaling
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            G.GAME.blind:set_text()
        end
    end
end

function tw_blind:set_blind()
    self.mult = 2
    timeout = TIME_DELAY * 2 -- reset + preparation time + animations time
end

function tw_blind:defeat()
    self.mult = 2
end
