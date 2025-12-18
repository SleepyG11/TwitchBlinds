TW_BL.utils = {}
TW_BL.load_file("src/utils/table.lua")
TW_BL.load_file("src/utils/voting.lua")

function TW_BL.utils.resize_card(card, mod, no_save)
	if not no_save then
		if not card.ability then
			card.ability = {}
		end
		card.ability.twbl_resize = (card.ability.twbl_resize or 1) * mod
	end
	card:hard_set_T(card.VT.x, card.VT.y, card.T.w * mod, card.T.h * mod)
	remove_all(card.children)
	card.children = {}
	card.children.shadow = Moveable(0, 0, 0, 0)
	card:set_sprites(card.config.center, card.base.id and card.config.card)
	card.CT.w = card.T.w
	card.CT.h = card.T.h
end
