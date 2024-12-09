extends Sprite

const DEMON := preload("res://Mobs/PortalDemon/BigDemon.tscn")
const DEMONS := [
	preload("res://Mobs/PortalDemon/BigDemon.tscn"),
	preload("res://Mobs/PortalDemon/DemonChicken/DemonChicken.tscn"),
]

var player_ref
var spawn_pos_list := [] # Vector2s


func _ready():
	position = (spawn_pos_list[SignalBus.rng.randi_range(0, spawn_pos_list.size() - 1)] * 16) + Vector2(8, 8)
	$Animator.play("portal_things")


func spawn_demon():
	var instance: Boss = DEMONS[SignalBus.rng.randi_range(0, DEMONS.size() - 1)].instance()
	instance.player_ref = player_ref
	instance.position = position
	get_parent().add_child(instance)



func _on_animation_finished(anim_name):
	queue_free()
