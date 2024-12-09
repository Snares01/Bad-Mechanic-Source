extends Tower

const BOMB := preload("res://Towers/BombHatch/Scenes/Bomb.tscn")
const CLOSE_BOMB_SPEED := 32.0
const FAR_BOMB_SPEED := 46.0
const FAR_SPEED_CUTOFF := 60.0
const BASE_RANGE := 35.0
const BASE_INACCURACY := 11.0 # In pixels off target
const BASE_RELOAD := 3.0 # In seconds

var reload_speed := BASE_RELOAD
var is_reloading := false
var accuracy := BASE_INACCURACY

onready var animator := $Animator

func update_stats():
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 3.6)
	reload_speed = max(0.1, BASE_RELOAD - (TowerDict.stats[id]["Reload"] * 0.2))
	accuracy = max(1.0, BASE_INACCURACY - (TowerDict.stats[id]["Accuracy"] * 1.5))

func activate():
	if animator.is_playing() or is_reloading:
		return
	animator.play("Shoot")

func shoot():
	var target_pos := select_target_position(FAR_BOMB_SPEED, Vector2.ZERO, "first")
	if target_pos == Vector2.ZERO:
		return
	target_pos += Vector2(rand_range(-accuracy, accuracy), rand_range(-accuracy, accuracy))
	
	var instance := BOMB.instance()
	if global_position.distance_to(target_pos) > FAR_SPEED_CUTOFF:
		instance.init_bomb(FAR_BOMB_SPEED, global_position, target_pos)
	else:
		instance.init_bomb(CLOSE_BOMB_SPEED, global_position, target_pos)
	
	get_parent().add_child(instance)

func _on_animation_finished(anim_name):
	if active:
		is_reloading = true
		var timer := get_tree().create_timer(reload_speed)
		timer.connect("timeout", self, "_on_reload_timeout")

func _on_reload_timeout():
	is_reloading = false
	if active:
		animator.play("Shoot")
