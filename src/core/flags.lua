function TW_BL.is_stop_use()
	return G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0) or false
end
function TW_BL.b_is_stop_use()
	return TW_BL.buffered("is_stop_use", TW_BL.is_stop_use)
end

function TW_BL.is_in_multiplayer()
	return not not (MP and MP.LOBBY and MP.LOBBY.code)
end
function TW_BL.b_is_in_multiplayer()
	return TW_BL.buffered("is_in_multiplayer", TW_BL.is_in_multiplayer)
end

function TW_BL.is_in_run()
	return G.STAGE == G.STAGES.RUN and not G.SETTINGS.paused and not G.OVERLAY_MENU
end
function TW_BL.b_is_in_run()
	return TW_BL.buffered("is_in_run", TW_BL.is_in_run)
end