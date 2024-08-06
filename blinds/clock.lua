local MAX_SIZE = 8
local TIME_DELAY = 1 -- In seconds
local MULT_INCREMENT = 0.06
-- Total time to full grow: 1 / 0.06 * (8 - 2) = 100 seconds

local tw_blind = SMODS.Blind {
    key = register_twitch_blind('clock', false),
    loc_txt = {
        ['en-us'] = {
            name = 'The Hourglass',
            text = { "Hurry up!" }
        }
    },
    dollars = 5,
    mult = 2,
    boss = {
        min = 999,
        max = 999
    },
    pos = { x = 0, y = 13 },
    config = { tw_bl = { in_pool = true, min = 2 } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('896665'),
}

local timeout = TIME_DELAY

local function increment_clock_chips(current_chips, base_chips)
    local mult = current_chips / base_chips
    if mult < MAX_SIZE then G.GAME.blind:wiggle() end
    return base_chips * math.min(MAX_SIZE, mult + MULT_INCREMENT)
end

TW_BL.EVENTS.add_listener('game_update', get_twitch_blind_key('clock'), function(dt)
    if not G.GAME or G.SETTINGS.paused then return end
    timeout = timeout - dt
    if timeout <= 0 then
        timeout = timeout + TIME_DELAY
        if G.GAME and G.GAME.blind and G.GAME.blind.name == get_twitch_blind_key('clock') and G.GAME.round_resets.blind_states.Boss == 'Current' then
            if type(G.GAME.blind.chips) == "table" then
                -- TODO: Talisman support
            else
                -- TODO: need to fix a problem with no chips saving
                G.GAME.blind.chips = increment_clock_chips(G.GAME.blind.chips,
                    get_blind_amount(G.GAME.round_resets.ante) * G.GAME.starting_params.ante_scaling)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                G.GAME.blind:set_text()
            end
        end
    end
end)

function tw_blind:set_blind(reset, silent)
    if reset then return end
    timeout = TIME_DELAY * 2 -- reset + preparation time + animations time
end

function tw_blind:defeat()

end
