extends Area2D
class_name TowerPreview

const PLACE_SOUND := preload("res://Audio/Sound Effects/PlaceSFX.tscn")

export var tower_instance : Resource
var tower_range := 50.0
var range_offset := Vector2.ZERO
var cost := 50
var player_ref

var world_map : TileMap

func _ready():
	var instance : Tower = tower_instance.instance()
	instance.update_stats()
	instance.update_sight_range()
	global_position = get_global_mouse_position().round()
	tower_range = instance.sight_range
	range_offset = instance.range_offset
	world_map = get_parent()
	z_as_relative = false
	z_index = 20
	collision_mask = 5
	collision_layer = 0
	player_ref.show_range(true)
	


func _physics_process(delta):
	global_position = get_global_mouse_position().round()
	if Input.is_action_just_pressed("ui_cancel"):
		SignalBus.emit_signal("building_state_changed", false)
		player_ref.show_range(false)
		queue_free()
		return
	if (get_overlapping_areas().empty() and get_overlapping_bodies().empty() # Not colliding
	  and world_map.get_cellv(world_map.world_to_map(position)) != -1 # In bounds
	  and global_position.distance_to(player_ref.global_position + Vector2(0, -8)) < (player_ref.get_node("BuildRange").build_radius + 5)): # In build range
		modulate = Color(1, 1, 1, 1)
		if Input.is_action_just_pressed("ui_select") and SignalBus.cash >= cost:
			var instance = tower_instance.instance()
			instance.global_position = global_position
			var sound_effect := PLACE_SOUND.instance()
			sound_effect.global_position = global_position
			var game_objects := get_node("../../../GameObjects")
			game_objects.add_child(instance)
			game_objects.add_child(sound_effect)
			SignalBus.emit_signal("building_state_changed", false)
			SignalBus.change_cash(-cost)
			player_ref.show_range(false)
			Modifiers.towers_placed += 1
			queue_free()
			return
	else:
		modulate = Color(0.85, 0.65, 0.65, 1)

func _draw():
	draw_circle(range_offset, tower_range, Color(0.7, 0.7, 1.0, 0.5))
