# Twitch Blinds: Balatro mod
*Let your Twitch chat decide which new boss will end your run ;)*

---

**Twitch Blinds** - a Balatro mod that adds new ways to interact with game via Twitch chat.

While streamer is playing, chat can vote for next boss blind he encounters.

![Balatro_hnk2f1pNJh](https://github.com/user-attachments/assets/17ecb907-f723-4cfb-9337-81bbc4fbc462)

New bosses are added, and some of them has mechanics that also relies on chat actions.

![Balatro_tyltBeM7s8](https://github.com/user-attachments/assets/5765d2cd-bc99-4e05-9b72-819b4a75cd9f)

Frequency and blinds to vote can be configured. Boss blinds from other mods works as well!

![Balatro_Q3LI0PLk6U](https://github.com/user-attachments/assets/aa4a4b0b-7f88-406b-a886-ea8e637380d4)

## Installation and How to use
1. Install [Steamodded](https://github.com/Steamopollys/Steamodded) v1.0.0 (alpha)
2. Place mod in Mods folder
3. Start game, then in game options open Twitch Blinds settings, insert Twitch channel name OR paste url to Twitch channel (like `https://twitch.tv/your_channel_name`)
4. Run stream, start a new run and enjoy!

## Boss blinds from other mods
- By default, all blinds treated as "Other", which means they can appear if `Blinds pool to vote` setting set to `All other` or `All`.
    - If `blind:in_pool()` method is present, it will be used.
- To prevent this, to blind's `config` table can be added configuration to control they appearance.

```lua
SMODS.Blind {

    -- All default blind params

    -- If you want remove boss from vanilla pool
    boss = {
        min = -1,
        max = -1,
    },

    in_pool = function(self)
        return false
    end,

    config = {
        tw_bl = {
            -- [optional]
            -- Is this blind treated as "Twitch Blind"
            -- This means it can appear if `Blinds pool to vote` setting set to `Twitch Blinds` or `All`
            -- Adds this blind to pool where it can be picked for voting process separately from vanilla game
            twitch_blind = true,

            -- [optional]
            -- Minimal ante for picking this boss for voting process
            -- Works only if `twitch_blind = true`
            min = 2,

            -- [optional]
            -- Maximal ante for picking this boss for voting process
            -- Works only if `twitch_blind = true`
            max = 8,

            -- [optional]
            -- Similar to `blind.ignore_showdown_check`
            ignore_showdown_check = false,

            -- [optional]
            -- Similar to `blind:in_pool()`, determine can this boss be picked for voting process
            -- Ignores `min` and `max` intervals
            in_pool = function(self)
                return true
            end,

            -- [optional]
            -- Prevent this blind to be picked for voting process
            -- Useful if it has complicated spawn mechanics
            ignore = true,
        }
    }
}
```
