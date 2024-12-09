extends TextureButton

const CLICK_SOUND = preload("res://Interface/Assets/ButtonClick.tscn")
var hit_sfx : AudioStreamPlayer

func _ready():
	focus_mode = Control.FOCUS_NONE
	var instance = CLICK_SOUND.instance()
	add_child(instance)
	hit_sfx = instance
	connect("button_down", self, "_on_button_down")


func _on_button_down():
	hit_sfx.play()
