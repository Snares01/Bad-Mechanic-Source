extends Button
class_name HatButton

signal hat_selected(hat_button)

export var achievement : String # Steam achievement name
export var hat : PackedScene # HatInfo
export var hat_name : String
export var unlocked_icon : StreamTexture
export var locked_icon : StreamTexture
export(String, MULTILINE) var hat_description
export(String, MULTILINE) var unlock_requirement

var hat_enabled := false
var is_empty_button := false

func _ready():
	connect("pressed", self, "_on_HatButton_pressed")
	if Achievements.is_achieved(achievement):
		hat_enabled = true
		toggle_mode = true
		icon = unlocked_icon
	else:
		toggle_mode = false
		icon = locked_icon
	


func _on_HatButton_pressed():
	for btn in get_parent().get_children():
		btn.pressed = false
	set_pressed_no_signal(true)
	emit_signal("hat_selected", self)
