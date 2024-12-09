extends ItemEffect

const FREEZE_HITBOX := preload("res://Items/Freeze/FreezeHitbox.tscn")

func effect():
	var player := get_player()
	var hitbox : Hitbox = FREEZE_HITBOX.instance()
	player.add_child(hitbox)
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	queue_free()


func kill():
	pass
