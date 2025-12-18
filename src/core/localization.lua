TW_BL.L = {}

function TW_BL.L.parse_lines(lines, args)
	args = args or {}
	local result_nodes = {}
	if lines then
		for _, line in ipairs(lines) do
			local localized = SMODS.localize_box(loc_parse_string(line), args)
			table.insert(result_nodes, {
				n = G.UIT.R,
				config = { align = args.align, minh = args.minh },
				nodes = localized,
			})
		end
	end
	return result_nodes
end

function TW_BL.L.parsed(set, key, parsed_fields, args, config)
	args = args or {}
	local success, lines = pcall(function()
		return G.localization.descriptions[set][key][parsed_fields]
	end)
	local result_nodes = success and TW_BL.L.parse_lines(lines, args) or {}
	return {
		n = G.UIT.C,
		config = config,
		nodes = result_nodes,
	}
end

function TW_BL.L.blind_interaction_text(blind)
	local success, result = pcall(function()
		return G.localization.descriptions.Blind[blind.key].interaction_text
	end)
	return success and result or "ERROR"
end

function TW_BL.L.req_arg(arg)
	return "<" .. localize("twbl_arg_" .. arg) .. ">"
end

function TW_BL.L.command_with_arg(command, arg)
	return table.concat({ command, TW_BL.L.req_arg(arg) }, " ")
end

function TW_BL.L.command_use_limits(amount, cooldown)
	if not amount then
		-- if no amount to limit by cooldown, no point
		return localize({
			type = "variable",
			key = "twbl_votes_amount_unlimit",
			vars = {},
		})
	end
	local result = {}
	if not cooldown or amount ~= 1 then
		table.insert(
			result,
			localize({
				type = "variable",
				key = amount == 1 and "twbl_votes_amount_singular" or "twbl_votes_amount_plural",
				vars = { amount or 1 },
			})
		)
	end
	if cooldown then
		table.insert(
			result,
			localize({
				type = "variable",
				key = cooldown == 1 and "twbl_votes_cooldown_singular" or "twbl_votes_cooldown_plural",
				vars = { cooldown or 1 },
			})
		)
	end

	return table.concat(result, ", ")
end
