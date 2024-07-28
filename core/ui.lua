-- Several part of code taken from https://github.com/OceanRamen/Saturn

function twitch_blinds_init_ui()
    local UI = {
        PARTS = {},

        voting_process = nil,
    }

    --

    function UI.PARTS.create_toggle(args)
        args = args or {}
        args.active_colour = args.active_colour or G.C.RED
        args.inactive_colour = args.inactive_colour or G.C.BLACK
        args.w = args.w or 3
        args.h = args.h or 0.5
        args.scale = args.scale or 1
        args.label = args.label or nil
        args.label_scale = args.label_scale or 0.4
        args.ref_table = args.ref_table or {}
        args.ref_value = args.ref_value or "test"

        local check = Sprite(0, 0, 0.5 * args.scale, 0.5 * args.scale, G.ASSET_ATLAS["icons"], { x = 1, y = 0 })
        check.states.drag.can = false
        check.states.visible = false

        local info = nil
        if args.info then
            info = {}
            for k, v in ipairs(args.info) do
                table.insert(info, {
                    n = G.UIT.R,
                    config = { align = "cm", minh = 0.05 },
                    nodes = {
                        { n = G.UIT.T, config = { text = v, scale = 0.25, colour = G.C.UI.TEXT_LIGHT } },
                    },
                })
            end
            info = { n = G.UIT.R, config = { align = "cm", minh = 0.05 }, nodes = info }
        end

        local t = {
            n = args.col and G.UIT.C or G.UIT.R,
            config = { align = "cm", padding = 0.1, r = 0.1, colour = G.C.CLEAR, focus_args = { funnel_from = true } },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cl", minw = 0.3 * args.w },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "cm", r = 0.1, colour = G.C.BLACK },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = {
                                        align = "cm",
                                        r = 0.1,
                                        padding = 0.03,
                                        minw = 0.4 * args.scale,
                                        minh = 0.4 * args.scale,
                                        outline_colour = G.C.WHITE,
                                        outline = 1.2 * args.scale,
                                        line_emboss = 0.5 * args.scale,
                                        ref_table = args,
                                        colour = args.inactive_colour,
                                        button = "toggle_button",
                                        button_dist = 0.2,
                                        hover = true,
                                        toggle_callback = args.callback,
                                        func = "toggle",
                                        focus_args = { funnel_to = true },
                                    },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = check } },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        }
        if args.label then
            ins = {
                n = G.UIT.C,
                config = { align = "cr", minw = args.w },
                nodes = {
                    { n = G.UIT.T, config = { text = args.label, scale = args.label_scale, colour = G.C.UI.TEXT_LIGHT } },
                    { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
                },
            }
            table.insert(t.nodes, 1, ins)
        end
        if args.info then
            t = {
                n = args.col and G.UIT.C or G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    t,
                    info,
                }
            }
        end
        return t
    end

    function UI.PARTS.create_tabs(args)
        args = args or {}
        args.colour = args.colour or G.C.RED
        args.tab_alignment = args.tab_alignment or "cm"
        args.opt_callback = args.opt_callback or nil
        args.scale = args.scale or 1
        args.tab_w = args.tab_w or 0
        args.tab_h = args.tab_h or 0
        args.text_scale = (args.text_scale or 0.5)
        args.tabs = args.tabs
            or {
                {
                    label = "tab 1",
                    chosen = true,
                    func = nil,
                    tab_definition_function = function()
                        return {
                            n = G.UIT.ROOT,
                            config = { align = "cm" },
                            nodes = {
                                { n = G.UIT.T, config = { text = "A", scale = 1, colour = G.C.UI.TEXT_LIGHT } },
                            },
                        }
                    end,
                },
                {
                    label = "tab 2",
                    chosen = false,
                    tab_definition_function = function()
                        return {
                            n = G.UIT.ROOT,
                            config = { align = "cm" },
                            nodes = {
                                { n = G.UIT.T, config = { text = "B", scale = 1, colour = G.C.UI.TEXT_LIGHT } },
                            },
                        }
                    end,
                },
                {
                    label = "tab 3",
                    chosen = false,
                    tab_definition_function = function()
                        return {
                            n = G.UIT.ROOT,
                            config = { align = "cm" },
                            nodes = {
                                { n = G.UIT.T, config = { text = "C", scale = 1, colour = G.C.UI.TEXT_LIGHT } },
                            },
                        }
                    end,
                },
            }

        local tab_buttons = {}

        for k, v in ipairs(args.tabs) do
            if v.chosen then
                args.current = { k = k, v = v }
            end
            tab_buttons[#tab_buttons + 1] = UIBox_button({
                id = "tab_but_" .. (v.label or ""),
                ref_table = v,
                button = "change_tab",
                colour = args.colour,
                label = { v.label },
                minh = 0.8 * args.scale,
                minw = 2.5 * args.scale,
                col = true,
                choice = true,
                scale = args.text_scale,
                chosen = v.chosen,
                func = v.func,
                focus_args = { type = "none" },
            })
        end

        local t = {
            n = G.UIT.R,
            config = { padding = 0.0, align = "cm", colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = G.C.CLEAR },
                    nodes = {
                        (#args.tabs > 1 and not args.no_shoulders) and {
                            n = G.UIT.C,
                            config = {
                                minw = 0.7,
                                align = "cm",
                                colour = G.C.CLEAR,
                                func = "set_button_pip",
                                focus_args = {
                                    button = "leftshoulder",
                                    type = "none",
                                    orientation = "cm",
                                    scale = 0.7,
                                    offset = { x = -0.1, y = 0 },
                                },
                            },
                            nodes = {},
                        } or nil,
                        {
                            n = G.UIT.C,
                            config = {
                                id = args.no_shoulders and "no_shoulders" or "tab_shoulders",
                                ref_table = args,
                                align = "cm",
                                padding = 0.15,
                                group = 1,
                                collideable = true,
                                focus_args = #args.tabs > 1
                                    and { type = "tab", nav = "wide", snap_to = args.snap_to_nav, no_loop = args.no_loop }
                                    or nil,
                            },
                            nodes = tab_buttons,
                        },
                        (#args.tabs > 1 and not args.no_shoulders) and {
                            n = G.UIT.C,
                            config = {
                                minw = 0.7,
                                align = "cm",
                                colour = G.C.CLEAR,
                                func = "set_button_pip",
                                focus_args = {
                                    button = "rightshoulder",
                                    type = "none",
                                    orientation = "cm",
                                    scale = 0.7,
                                    offset = { x = 0.1, y = 0 },
                                },
                            },
                            nodes = {},
                        } or nil,
                    },
                },
                {
                    n = G.UIT.R,
                    config = {
                        align = args.tab_alignment,
                        padding = args.padding or 0.1,
                        no_fill = true,
                        minh = args.tab_h,
                        minw = args.tab_w,
                    },
                    nodes = {
                        {
                            n = G.UIT.O,
                            config = {
                                id = "tab_contents",
                                object = UIBox({
                                    definition = args.current.v.tab_definition_function(args.current.v
                                        .tab_definition_function_args),
                                    config = { offset = { x = 0, y = 0 } },
                                }),
                            },
                        },
                    },
                },
            },
        }

        return t
    end

    function UI.PARTS.create_generic_options(args)
        args = args or {}
        local apply_func = args.apply_func or "apply_settings"
        local back_func = args.back_func or "exit_overlay_menu"
        local contents = args.contents or { n = G.UIT.T, config = { text = "EMPTY", colour = G.C.UI.RED, scale = 0.4 } }
        if args.infotip then
            G.E_MANAGER:add_event(Event({
                blocking = false,
                blockable = false,
                timer = "REAL",
                func = function()
                    if G.OVERLAY_MENU then
                        local _infotip_object = G.OVERLAY_MENU:get_UIE_by_ID("overlay_menu_infotip")
                        if _infotip_object then
                            _infotip_object.config.object:remove()
                            _infotip_object.config.object = UIBox({
                                definition = overlay_infotip(args.infotip),
                                config = { offset = { x = 0, y = 0 }, align = "bm", parent = _infotip_object },
                            })
                        end
                    end
                    return true
                end,
            }))
        end

        return {
            n = G.UIT.ROOT,
            config = {
                align = "cm",
                minw = G.ROOM.T.w * 5,
                minh = G.ROOM.T.h * 5,
                padding = 0.1,
                r = 0.1,
                colour = args.bg_colour or { G.C.GREY[1], G.C.GREY[2], G.C.GREY[3], 0.7 },
            },
            nodes = {
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        minh = 1,
                        r = 0.3,
                        padding = 0.07,
                        minw = 1,
                        colour = args.outline_colour or G.C.JOKER_GREY,
                        emboss = 0.1,
                    },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "cm", minh = 1, r = 0.2, padding = 0.2, minw = 1, colour = args.colour or G.C.L_BLACK },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = args.padding or 0.2, minw = args.minw or 7 },
                                    nodes = contents,
                                },
                                not args.no_apply and {
                                    n = G.UIT.R,
                                    config = {
                                        id = args.apply_id or "overlay_menu_apply_button",
                                        align = "cm",
                                        minw = 2.5,
                                        button_delay = args.back_delay,
                                        padding = 0.1,
                                        r = 0.1,
                                        hover = true,
                                        colour = args.apply_colour or G.C.GREEN,
                                        button = apply_func,
                                        shadow = true,
                                        focus_args = { nav = "wide", button = "a", snap_to = args.snap_back },
                                    },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", padding = 0, no_fill = true },
                                            nodes = {
                                                {
                                                    n = G.UIT.T,
                                                    config = {
                                                        id = args.apply_id or nil,
                                                        text = args.apply_label or "Apply",
                                                        scale = 0.5,
                                                        colour = G.C.UI.TEXT_LIGHT,
                                                        shadow = true,
                                                        func = not args.no_pip and "set_button_pip" or nil,
                                                        focus_args = not args.no_pip and
                                                            { button = args.apply_button or "a" } or nil,
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                                not args.no_back and {
                                    n = G.UIT.R,
                                    config = {
                                        id = args.back_id or "overlay_menu_back_button",
                                        align = "cm",
                                        minw = 2.5,
                                        button_delay = args.back_delay,
                                        padding = 0.1,
                                        r = 0.1,
                                        hover = true,
                                        colour = args.back_colour or G.C.ORANGE,
                                        button = back_func,
                                        shadow = true,
                                        focus_args = { nav = "wide", button = "b", snap_to = args.snap_back },
                                    },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", padding = 0, no_fill = true },
                                            nodes = {
                                                {
                                                    n = G.UIT.T,
                                                    config = {
                                                        id = args.back_id or nil,
                                                        text = args.back_label or localize("b_back"),
                                                        scale = 0.5,
                                                        colour = G.C.UI.TEXT_LIGHT,
                                                        shadow = true,
                                                        func = not args.no_pip and "set_button_pip" or nil,
                                                        focus_args = not args.no_pip and
                                                            { button = args.back_button or "b" } or nil,
                                                    },
                                                },
                                            },
                                        },
                                    },
                                } or nil,
                            },
                        },
                    },
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.O, config = { id = "overlay_menu_infotip", object = Moveable() } },
                    },
                },
            },
        }
    end

    function UI.PARTS.create_option_toggle(args)
        local name = args.name or ""
        local box_colour = args.box_colour or G.C.L_BLACK
        local toggle_ref = args.toggle_ref
        local toggle_value = args.toggle_value or "enabled"
        local config_button = args.config_button or nil

        local t = {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.05,
                colour = box_colour,
                r = 0.3,
            },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cm", padding = 0.1 },
                    nodes = {
                        {
                            n = G.UIT.O,
                            config = {
                                object = DynaText({ string = name, colours = { G.C.WHITE }, shadow = false, scale = 0.5 }),
                            },
                        },
                    },
                },
                {
                    n = G.UIT.C,
                    config = { align = "cm", padding = 0.1 },
                    nodes = {
                        UI.PARTS.create_toggle({
                            ref_table = toggle_ref,
                            ref_value = toggle_value,
                            active_colour = G.C.BOOSTER,
                            callback = args.callback or function(x) end,
                            col = true,
                        }),
                    },
                },
                config_button and {
                    n = G.UIT.C,
                    config = { align = "cm", padding = 0.1 },
                    nodes = {
                        UIBox_button({
                            label = { "Config" },
                            button = config_button,
                            minw = 2,
                            minh = 0.75,
                            scale = 0.5,
                            colour = G.C.BOOSTER,
                            col = true,
                        }),
                    },
                },
            },
        }
        return t
    end

    function UI.PARTS.get_settings_tab(_tab)
        local forcing_labels = { 'None' }

        for i = 1, #TW_BL.BLINDS.regular do
            table.insert(forcing_labels, TW_BL.BLINDS.regular[i])
        end

        local result = {
            n = G.UIT.ROOT,
            config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, minh = 5, minw = 5 },
            nodes = {},
        }
        if _tab == "Settings" then
            result.nodes = {
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                    },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Twitch channel name", scale = 0.4, colour = G.C.UI.TEXT_LIGHT, shadow = false } },
                    }
                },
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                    },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "cm", minw = 0.1 },
                            nodes = {
                                create_text_input({
                                    w = 4,
                                    max_length = 32,
                                    prompt_text = 'Enter channel name',
                                    ref_table = TW_BL.SETTINGS.temp,
                                    ref_value = 'channel_name',
                                    extended_corpus = true,
                                    keyboard_offset = 1,
                                }),
                                { n = G.UIT.C, config = { align = "cm", minw = 0.1 }, nodes = {} },
                                UIBox_button({
                                    label = { "Paste name", "or url" },
                                    minw = 2,
                                    minh = 0.6,
                                    button = 'twbl_settings_paste_channel_name',
                                    colour = G.C.BLUE,
                                    scale = 0.3,
                                    col = true
                                })
                            }
                        },
                    }
                },
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                        minh = 0.2
                    },
                    nodes = {},
                },
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                    },
                    nodes = {
                        create_option_cycle({
                            w = 4,
                            label = "Twitch Blind frequency",
                            scale = 0.8,
                            options = { 'None', 'One after one', 'Every one' },
                            opt_callback = 'twbl_settings_change_blind_frequency',
                            current_option = TW_BL.SETTINGS.temp.blind_frequency
                        }),
                    }
                },
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                        minh = 0.2
                    },
                    nodes = {},
                },
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                    },
                    nodes = {
                        create_option_cycle({
                            w = 4,
                            label = "Blinds pool to vote",
                            scale = 0.8,
                            options = { 'Twitch Blinds', 'All other', 'All' },
                            opt_callback = 'twbl_settings_change_pool_type',
                            current_option = TW_BL.SETTINGS.temp.pool_type
                        }),
                    }
                },
                -- UI.PARTS.create_option_toggle({
                --     name = "Chat can highlights cards",
                --     toggle_ref = TW_BL.SETTINGS.temp,
                --     toggle_value = "allow_chat_to_highlight_cards"
                -- }),
            }
            if TW_BL.__DEV_MODE then
                table.insert(result.nodes, {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                        minh = 0.2
                    },
                    nodes = {},
                })
                table.insert(result.nodes, {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        padding = 0.05,
                        colour = box_colour,
                        r = 0.3,
                    },
                    nodes = {
                        create_option_cycle({
                            w = 6,
                            label = "[DEV] Forced blind",
                            scale = 0.8,
                            options = forcing_labels,
                            opt_callback = 'twbl_settings_change_forced_blind',
                            current_option = (TW_BL.SETTINGS.temp.forced_blind or 0) + 1
                        }),
                    }
                })
            end
        end

        return result
    end

    function UI.PARTS.create_UIBox_voting_process()
        return {
            n = G.UIT.ROOT,
            config = { padding = 0.04, r = 0.3, colour = G.C.BLACK },
            nodes = {
                {
                    n = G.UIT.R,
                    config = {
                        padding = 0.04,
                    },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { minw = 1.915, align = 'c' },
                            nodes = {
                                { n = G.UIT.O, config = { id = 'twbl_voting_status', object = DynaText({ string = { "" }, colours = { G.C.UI.TEXT_LIGHT }, shadow = false, rotate = false, float = true, bump = true, scale = 0.35, spacing = 1, pop_in = 1 }) } },
                            }
                        },
                        {
                            n = G.UIT.C,
                            config = { minw = 4.25, align = "cm" },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = "vote 1", scale = 0.25, colour = G.C.UI.TEXT_LIGHT, shadow = false } },
                                    }
                                },
                                { n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
                                { n = G.UIT.T, config = { text = "-", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = false, id = "twbl_vote_1_blind_name" } },
                                { n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
                                { n = G.UIT.T, config = { text = "0%", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = false, id = "twbl_vote_1_percent" } },
                            }
                        },
                        {
                            n = G.UIT.C,
                            config = { minw = 4.25, align = "cm" },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = "vote 2", scale = 0.25, colour = G.C.UI.TEXT_LIGHT, shadow = false } },
                                    }
                                },
                                { n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
                                { n = G.UIT.T, config = { text = "-", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = false, id = "twbl_vote_2_blind_name" } },
                                { n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
                                { n = G.UIT.T, config = { text = "0%", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = false, id = "twbl_vote_2_percent" } },
                            }
                        },
                        {
                            n = G.UIT.C,
                            config = { minw = 4.25, align = "cm" },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.08, r = 0.3, align = "cm", colour = G.C.CHIPS },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = "vote 3", scale = 0.25, colour = G.C.UI.TEXT_LIGHT, shadow = false } },
                                    }
                                },
                                { n = G.UIT.C, config = { align = "cm", w = 0.1, minw = 0.1 } },
                                { n = G.UIT.T, config = { text = "-", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = false, id = "twbl_vote_3_blind_name" } },
                                { n = G.UIT.C, config = { align = "cm", w = 0.15, minw = 0.15 } },
                                { n = G.UIT.T, config = { text = "0%", scale = 0.3, colour = G.C.UI.TEXT_LIGHT, shadow = false, id = "twbl_vote_3_percent" } },
                            }
                        },
                    }
                },
            },
        }
    end

    --

    function UI.open_settings()
        G.SETTINGS.paused = true

        local _tabs = {}
        _tabs[#_tabs + 1] = {
            label = "Settings",
            chosen = true,
            tab_definition_function = UI.PARTS.get_settings_tab,
            tab_definition_function_args = "Settings",
        }

        local t = UI.PARTS.create_generic_options({
            apply_func = "twbl_settings_apply",
            back_func = "options",
            contents = {
                UI.PARTS.create_tabs({
                    tabs = _tabs,
                    tab_h = 7.05,
                    tab_alignment = "tm",
                    snap_to_nav = true,
                    colour = G.C.BOOSTER,
                }),
            },
        })
        G.FUNCS.overlay_menu({
            definition = t,
        })
    end

    function UI.get_menu_settings_button()
        return UIBox_button({
            button = 'twbl_settings_open',
            label = { 'Twitch Blinds' },
            colour = HEX("982fb5"),
            minw = 5,
            focus_args = { snap_to = true }
        })
    end

    function UI.insert_main_menu_button(menu)
        local text_scale = 0.45
        local twitch_blinds_preferences_button = UIBox_button({
            id = "twbl_settings_open",
            minh = 1.35,
            minw = 1.85,
            col = true,
            button = "twbl_settings_open",
            colour = HEX("982fb5"),
            label = { "Twitch Blinds" },
            scale = text_scale * 1.2,
        })

        local spacer = G.F_QUIT_BUTTON and { n = G.UIT.C, config = { align = "cm", minw = 0.2 }, nodes = {} } or nil
        table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 2, spacer)
        table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 3, twitch_blinds_preferences_button)
        menu.nodes[1].nodes[1].config = { align = "cm", padding = 0.15, r = 0.1, emboss = 0.1, colour = G.C.L_BLACK, mid = true }
        return menu
    end

    --

    --- @param with_bosses boolean
    function UI.update_voting_process(with_bosses)
        if not UI.voting_process then return end

        local blinds_to_vote = TW_BL.BLINDS.get_twitch_blinds_from_game(TW_BL.SETTINGS.current.pool_type, false)
        if blinds_to_vote then
            local vote_status = TW_BL.CHAT_COMMANDS.get_vote_status()
            for i = 1, TW_BL.BLINDS.blinds_to_vote do
                if with_bosses then
                    local boss_element = UI.voting_process:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_blind_name");
                    if boss_element then
                        boss_element.config.text = blinds_to_vote[i] and
                            localize { type = 'name_text', key = blinds_to_vote[i], set = 'Blind' } or "-"
                    end
                end
                local percent_element = UI.voting_process:get_UIE_by_ID("twbl_vote_" .. tostring(i) .. "_percent");
                if percent_element then
                    local variant_status = vote_status[tostring(i)]
                    percent_element.config.text = math.floor(variant_status and variant_status.percent or 0) .. '%'
                end
            end
        end

        -- TODO: animate this
        UI.voting_process.config.offset.y = TW_BL.CHAT_COMMANDS.can_collect.vote and -6.1 or -8.1
        UI.voting_process:recalculate()
    end

    function UI.update_voting_status(status)
        if not UI.voting_process then return end

        local text = '...'
        if status == TW_BL.CHAT_COMMANDS.collector.STATUS.CONNECTED then
            text = "Vote!"
        elseif status == TW_BL.CHAT_COMMANDS.collector.STATUS.CONNECTING then
            text = "Connecting..."
        elseif status == TW_BL.CHAT_COMMANDS.collector.STATUS.DISCONNECTED then
            text = "Disconnected.."
        else
            text = "..."
        end

        local status_element = UI.voting_process:get_UIE_by_ID("twbl_voting_status");
        if status_element then
            status_element.config.object.config.string = { text }
            status_element.config.object:update_text(true)
            UI.voting_process:recalculate()
        end
    end

    function UI.draw_voting_process()
        UI.voting_process = UIBox({
            definition = UI.PARTS.create_UIBox_voting_process(),
            config = { align = "cmri", offset = { x = -0.2857, y = -6.1 }, major = G.ROOM_ATTACH, id = "twbl_voting_process" },
        })
        UI.update_voting_status(TW_BL.CHAT_COMMANDS.collector.connection_status)
    end

    --

    function G.FUNCS.twbl_settings_apply()
        TW_BL.SETTINGS.save()
        if TW_BL.CHAT_COMMANDS.collector.socket then
            TW_BL.CHAT_COMMANDS.collector:connect(TW_BL.SETTINGS.current.channel_name, true)
        end
    end

    function G.FUNCS.twbl_settings_open()
        TW_BL.SETTINGS.create_temp()
        return UI.open_settings()
    end

    function G.FUNCS.twbl_settings_change_blind_frequency(args)
        TW_BL.SETTINGS.temp.blind_frequency = args.to_key
    end

    function G.FUNCS.twbl_settings_change_pool_type(args)
        TW_BL.SETTINGS.temp.pool_type = args.to_key
    end

    function G.FUNCS.twbl_settings_change_forced_blind(args)
        TW_BL.SETTINGS.temp.forced_blind = args.to_key > 1 and args.to_key - 1 or nil
    end

    function G.FUNCS.twbl_settings_paste_channel_name(e)
        G.CONTROLLER.text_input_hook = e.UIBox:get_UIE_by_ID('text_input').children[1].children[1]
        for i = 1, 32 do
            G.FUNCS.text_input_key({ key = 'right' })
        end
        for i = 1, 32 do
            G.FUNCS.text_input_key({ key = 'backspace' })
        end

        local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ''
        local channel_name = clipboard:match("twitch%.tv/([%w_]+)") or clipboard

        for i = 1, #channel_name do
            local c = channel_name:sub(i, i)
            G.FUNCS.text_input_key({ key = c })
        end

        G.FUNCS.text_input_key({ key = 'return' })
    end

    return UI
end
