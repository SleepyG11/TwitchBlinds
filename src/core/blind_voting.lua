TW_BL.blind_voting = {}

function TW_BL.blind_voting.connect_blind_voting(reset)
	TW_BL.chat_commands.set({
		vote_id = "blind_voting",
		command = "vote",
		command_max_uses = 1,
		set_vote_variants = reset and { "1", "2", "3" } or nil,
		reset_command_use = reset,
		reset_vote_score = reset,
	})

	TW_BL.UI.top_screen_panel.show(TW_BL.UI.blind_voting_UIBox)

	TW_BL.e_mitter.on("new_provider_command", function(event)
		if
			TW_BL.chat_commands.default_command_check(event, {
				command = "vote",
				can_use_command = true,
				increment_command_use = true,
				vote_id = "blind_voting",
				can_vote_for_variant = true,
				increment_vote_score = true,
			})
		then
			TW_BL.UI.notify({
				target = "panel",
				panel = "top_screen_panel",
				message = event.username,
				with_sound = true,
			})
		end
	end, {
		key = "blind_voting",
		tags = {
			on_run = true,
			blind_voting = true,
		},
	})
end

function TW_BL.blind_voting.start_blind_voting(target_ante, no_replace)
	local is_in_progress = TW_BL.G.blind_voting_ante
	local should_not_replace = is_in_progress and no_replace

	local repeats = {}
	local old_blinds = TW_BL.G.blind_voting_blinds or {}
	for _, blind in ipairs(old_blinds) do
		repeats[blind] = true
	end

	TW_BL.G.blind_voting_ante = should_not_replace and TW_BL.G.blind_voting_ante or target_ante
	TW_BL.G.blind_voting_blinds = should_not_replace and TW_BL.G.blind_voting_blinds
		or TW_BL.blinds.poll_blinds({
			amount = 3,
			increment_usage = true,
			target_ante = target_ante,
			allow_repeats = TW_BL.cc.blind_voting_allow_repeats.value == 2,
			blind_pool_type = TW_BL.cc.blind_voting_pool_type.value,
		}, repeats)

	TW_BL.blind_voting.connect_blind_voting(not should_not_replace)
end
function TW_BL.blind_voting.load_blind_voting()
	if not TW_BL.G.blind_voting_ante then
		return
	end
	TW_BL.blind_voting.connect_blind_voting(true)
end
function TW_BL.blind_voting.finish_blind_voting()
	local winner = TW_BL.chat_commands.get_vote_winner("blind_voting")
	local blind_to_set = (TW_BL.G.blind_voting_blinds or {})[winner and winner.index or 1]
	TW_BL.blind_voting.stop_blind_voting()
	return blind_to_set, winner
end
function TW_BL.blind_voting.stop_blind_voting(save)
	if not save then
		TW_BL.G.blind_voting_ante = nil
	end
	TW_BL.e_mitter.off_tag("new_provider_command", "blind_voting")
	TW_BL.UI.top_screen_panel.hide()
end

TW_BL.e_mitter.on("run_start", function(load)
	if load then
		TW_BL.blind_voting.load_blind_voting()
	end
end)
TW_BL.e_mitter.on("run_delete", function()
	TW_BL.e_mitter.off_tag("new_provider_command", "on_run")
end)
