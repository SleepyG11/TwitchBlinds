# Twitch Blinds: Balatro mod
*Let your Twitch chat decide which new boss will end your run ;)*

---

**Twitch Blinds** - a Balatro mod that adds new ways to interact with game via Twitch chat.

While streamer is playing, chat can vote for next boss blind he encounters.

![Balatro_9yMOBS5sQs](https://github.com/user-attachments/assets/984c2ea7-8810-4c75-b920-59d08cc27c84)

New bosses are added, and some of them has mechanics that also relies on chat actions.

![Balatro_cz3bHDchpE](https://github.com/user-attachments/assets/164a7145-d59a-4c84-addf-96ae4286d701)

Frequency and blinds to vote can be configured. Boss blinds from other mods works as well!

![Balatro_n6xHriLIwR](https://github.com/user-attachments/assets/6006146e-bc06-4291-a1da-8e019e37ad11)


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

    boss = {
        -- If you want to disable appearing this blind in vanilla game
        -- min = 999,
        -- max = 999,
    },

    config = {
        tw_bl = {
            -- [optional]
            -- Is this blind treated as "Twitch Blind"
            -- This means it can appear if `Blinds pool to vote` setting set to `Twitch Blinds` or `All`
            -- Adds this blind to pool where it can be picked for voting process separately from vanilla game
            in_pool = true, 

            -- [optional]
            -- Minimal ante for picking this boss for voting process
            -- Works only if `is_pool = true`
            min = 2,

            -- [optional]
            -- Maximal ante for picking this boss for voting process
            -- Works only if `is_pool = true`
            max = 8,

            -- [optional]
            -- Prevent this blind to be picked for voting process
            -- Useful if it has complicated spawn mechanics
            ignore = true,
        }
    }
}
```