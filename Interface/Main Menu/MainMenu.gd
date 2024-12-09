extends Node2D

const HAT_SELECT := preload("res://Interface/Menus/HatSelect/HatSelect.tscn")
const MIN_SPAWN_SPEED := 8.0
const MAX_SPAWN_SPEED := 16.0

export var chicken : Resource
export var chicken_path : Curve2D
export var bg_music : AudioStream

onready var options_menu: PanelContainer = get_node("%OptionsPanel")
onready var darken: ColorRect = get_node("%Darken")

func _ready():
	MusicController.fade_in(bg_music)
	MusicController.jump_to(8.627) #8.6
	options_menu.hide()
	darken.hide()
	$UILayer.show()
	options_menu.connect("exited", self, "_on_options_closed")
	
	# Release the chickens
	for i in SignalBus.rng.randi_range(2, 7):
		var instance : Mob = chicken.instance()
		instance.path = chicken_path
		$GameObjects.add_child(instance)
		instance.sprite.flip_h = SignalBus.rng.randi_range(0, 1)
		instance.menu_mode = true
		var path_progress := rand_range(40.0, chicken_path.get_baked_length() - 40.0)
		instance.path_progress = path_progress
		instance.global_position = chicken_path.interpolate_baked(path_progress)
	spawn_chicken()


func spawn_chicken():
	var instance : Mob = chicken.instance()
	instance.path = chicken_path
	$GameObjects.add_child(instance)
	instance.menu_mode = true
	
	var timer := get_tree().create_timer(rand_range(MIN_SPAWN_SPEED, MAX_SPAWN_SPEED))
	timer.connect("timeout", self, "spawn_chicken")


func _on_Play_pressed():
	get_node("%Play").disabled = true
	SignalBus.reset_progress()
	if Modifiers.skip_intro:
		TransitionService.fade_out("res://Interface/Shop/Shop.tscn")
	else:
		TransitionService.fade_out("res://Interface/IntroCutscene/IntroCutscene.tscn")


func _on_Options_pressed():
	options_menu.show()
	darken.show()

func _on_options_closed():
	darken.hide()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Hats_pressed():
	var instance := HAT_SELECT.instance()
	instance.start_game_on_select = false
	instance.connect("selected", self, "on_hat_selected")
	$UILayer.add_child(instance)
	$UILayer/Menu.hide()
	darken.show()


func on_hat_selected():
	$UILayer/Menu.show()
	darken.hide()
