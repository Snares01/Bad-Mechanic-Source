extends ItemEffect


func effect():
	var upgrade_panel = get_upgrade_panel()
	upgrade_panel.load_items(upgrade_panel.SHOP_PROGRESSION)
	sfx.stream = SFX_ACTIVATE
	sfx.play()
