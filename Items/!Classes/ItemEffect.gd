extends Node
class_name ItemEffect

const SFX_ACTIVATE := preload("res://Items/!Assets/effect_activate.wav")
const SFX_DEACTIVATE := preload("res://Items/!Assets/effect_deactivate.wav")
const SOUND_PLAYER := preload("res://Items/!Assets/ActivateEffect.tscn")

var sfx : AudioStreamPlayer

func _ready():
	var instance = SOUND_PLAYER.instance()
	get_parent().add_child(instance)
	connect("tree_exiting", self, "_on_exit")
	sfx = instance


func _on_exit():
	kill()

# Virtual functions
func effect() -> void:
	pass
# stop effect suddenly, used in shop preview and on scene change
func kill():
	pass

# Paths to nodes should be stored class-wide so they can be changed easily
func get_player() -> KinematicBody2D:
	var player = get_node_or_null("../GameObjects/Player")
	return player

func get_game_objects() -> YSort:
	var game_obj : YSort = get_node_or_null("../GameObjects")
	return game_obj

func get_game_camera() -> Camera2D:
	var cam = get_node_or_null("../Camera")
	return cam

func get_upgrade_panel() -> MarginContainer:
	var panel = get_node_or_null("../UILayer/GUI/UpgradePanel")
	return panel
