extends Tower

const CHICKEN := preload("res://Towers/ChickenCoopBombFactory/Scenes/Chicken.tscn")
const BASE_RANGE := 50.0
const BASE_SPAWN_RATE := 2.0 # Time between spawns
const SPAWN_OFFSET := Vector2(-5, 4)

var spawn_rate := BASE_SPAWN_RATE
var reloaded := true
var is_spawn_walled := false # Don't hop out of bounds

func update_stats():
	spawn_rate = max(0.1, BASE_SPAWN_RATE - (TowerDict.stats[id]["Spawn Rate"] * 0.12))
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 5.0)

func _ready():
	$Raycast.force_raycast_update()
	if $Raycast.is_colliding():
		is_spawn_walled = true

func _process(delta):
	if active and reloaded:
		spawn_chicken()

func spawn_chicken():
	var instance : Tower = CHICKEN.instance()
	get_parent().add_child(instance)
	if is_spawn_walled:
		instance.hop_dir = Vector2.ZERO
	instance.position = position + SPAWN_OFFSET
	
	reloaded = false
	var timer := get_tree().create_timer(spawn_rate)
	timer.connect("timeout", self, "reload")

func reload():
	reloaded = true
