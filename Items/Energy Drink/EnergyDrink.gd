extends ItemEffect

const SPEED := 28.0
const ZOOM_AMOUNT := 0.1

var effect := false # Flag
var life_span := 4.0

func effect():
	effect = true
	get_player().speed += SPEED
	var cam := get_game_camera() 
	if cam != null:
		cam.change_zoom(cam.target_zoom + ZOOM_AMOUNT)
	sfx.stream = SFX_ACTIVATE
	sfx.play()


func _process(delta):
	if effect:
		life_span -= delta
		if life_span < 0:
			get_player().speed -= SPEED
			sfx.stream = SFX_DEACTIVATE
			sfx.play()
			var cam := get_game_camera() 
			if cam != null:
				cam.change_zoom(cam.target_zoom - ZOOM_AMOUNT)
			queue_free()
