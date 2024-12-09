extends "res://Interface/Assets/ButtonSounds.gd"

export var action: String = "move_up"


func _ready():
	connect("toggled", self, "_on_button_toggled")
	display_key()


func display_key():
	text = InputMap.get_action_list(action)[0].as_text()


func bind_key(event: InputEventKey):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
	text = event.as_text()

func _on_button_toggled(pressed: bool):
	if pressed:
		text = "_"
	else:
		display_key()

func _unhandled_key_input(event: InputEventKey):
	if pressed:
		bind_key(event)
		pressed = false
