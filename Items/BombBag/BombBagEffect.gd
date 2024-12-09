extends ItemEffect

const BOMB := preload("res://Items/BombBag/Bomb.tscn")

func effect():
	var bomb : Sprite = BOMB.instance()
	get_game_objects().add_child(bomb)
	bomb.position = get_player().position
	
	sfx.stream = SFX_ACTIVATE
	sfx.play()
	queue_free()
