extends MarginContainer

signal selected()

onready var hat_grid : GridContainer = get_node("%HatGrid")
onready var lbl_name : Label = get_node("%LblName")
onready var lbl_desc : Label = get_node("%LblDesc")
onready var btn_back : Button = get_node("%BtnBack")

var selected_hat : HatInfo
var start_game_on_select := true # Will start a game 

func _ready():
	for btn in hat_grid.get_children():
		btn.connect("hat_selected", self, "_on_hat_selected")
	hat_grid.get_child(0).is_empty_button = true
	hat_grid.get_child(0).set_pressed_no_signal(true)
	if Modifiers.hard_mode:
		get_node("%HardToggle").set_pressed_no_signal(true)
	
	# Pre-select currently worn hat
	if SignalBus.current_hat != null:
		for btn in hat_grid.get_children():
			if btn.hat_enabled:
				var btn_hat: HatInfo = btn.hat.instance()
				if SignalBus.current_hat.spr == btn_hat.spr:
					_on_hat_selected(btn)
					btn.set_pressed_no_signal(true)
		


func _on_hat_selected(hat_btn : HatButton):
	lbl_name.text = hat_btn.hat_name
	if hat_btn.hat_enabled or hat_btn.hat_name == "Empty":
		lbl_desc.modulate = Color(1, 1, 1)
		lbl_desc.text = hat_btn.hat_description
	else:
		lbl_desc.modulate = Color(1, 0.6, 0.7)
		lbl_desc.text = hat_btn.unlock_requirement
	
	if hat_btn.hat_enabled and not hat_btn.is_empty_button:
		selected_hat = hat_btn.hat.instance()
		hat_grid.get_child(0).set_pressed_no_signal(false)
	else:
		selected_hat = null
		hat_grid.get_child(0).set_pressed_no_signal(true)

# select button
func _on_BtnBack_pressed():
	SignalBus.current_hat = selected_hat
	if start_game_on_select:
		SignalBus.reset_progress()
		TransitionService.fade_out("res://Interface/Shop/Shop.tscn")
	else:
		emit_signal("selected")
		queue_free()


func _on_hard_mode_toggled(button_pressed : bool):
	if Achievements.is_achieved("GAME_COMPLETE"):
		Modifiers.hard_mode = button_pressed
	else:
		lbl_name.text = ""
		lbl_desc.modulate = Color(1, 0.6, 0.7)
		lbl_desc.text = "Beat the game to unlock HELL MODE"
		get_node("%HardToggle").set_pressed_no_signal(false)
