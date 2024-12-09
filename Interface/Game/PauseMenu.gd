extends MarginContainer

const OPTIONS_MENU := preload("res://Interface/Menus/OptionPanel.tscn")

var paused := false # true if in pause menu
var pausing_disabled := false # disallow pausing during intro animation

onready var options_menu := OPTIONS_MENU.instance()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	hide()
	get_parent().call_deferred("add_child", options_menu)
	options_menu.escape_to_close = true


func _input(event):
	if Input.is_action_just_pressed("pause") and not pausing_disabled:
		if (not paused and get_tree().paused) or options_menu.visible: # Don't allow pause menu during intros and stuff
			return
		if paused:
			get_tree().paused = false
			paused = false
			hide()
		else:
			get_tree().paused = true
			paused = true
			show()


func _on_Continue_pressed():
	hide()
	get_tree().paused = false


func _on_MainMenu_pressed():
	get_tree().paused = false
	MusicController.fade_out()
	TransitionService.fade_out("res://Interface/Main Menu/MainMenu.tscn")


func _on_Options_pressed():
	options_menu.show()
