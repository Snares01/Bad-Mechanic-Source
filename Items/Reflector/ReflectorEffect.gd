extends ItemEffect


const REFLECTOR_HITBOX := preload("res://Items/Reflector/ReflectorHitbox.tscn")

func effect():
	var player := get_player()
	var hitbox := REFLECTOR_HITBOX.instance()
	player.add_child(hitbox)
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	queue_free()


func kill():
	pass
