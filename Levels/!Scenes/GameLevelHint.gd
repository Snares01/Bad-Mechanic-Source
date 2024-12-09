extends PanelContainer

signal closed()

var click_resist := 0.33 # initial time the hint cant be closed

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func _process(delta):
	click_resist -= delta
	if click_resist < 0.0:
		mouse_filter = Control.MOUSE_FILTER_PASS
		if Input.is_action_just_pressed("ui_select"):
			get_tree().paused = false
			emit_signal("closed")
			queue_free()
