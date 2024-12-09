extends Tower

const BASE_RANGE := 70.0
const BASE_LIFESPAN := 5.75
const BASE_DAMAGE := 6.0
const BASE_RELOAD := 0.6 # Animation speed
const SPAWN_DOWN := Vector2.ZERO
const SPAWN_LEFT := Vector2(-12, -1)
const SPAWN_RIGHT := Vector2(12, -1)
const SPAWN_UP := Vector2(0, -9)

export var tower : Resource

var lifespan := BASE_LIFESPAN
var damage := BASE_DAMAGE
var reload_speed := BASE_RELOAD

onready var animator : AnimationPlayer = $Animator

func _ready():
	animator.play("Idle")

func update_stats():
	damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 0.4)
	lifespan = BASE_LIFESPAN + (TowerDict.stats[id]["Lifespan"] * 0.25)
	reload_speed = BASE_RELOAD + (TowerDict.stats[id]["Reload"] * 0.05)
	sight_range = BASE_RANGE

func _process(delta):
	if active and animator.current_animation == "Idle":
		if randf() < 0.25:
			animator.play("Shoot", -1, reload_speed)
		else:
			animator.play("Shoot1", -1, reload_speed)

func spawn_tower(down : bool):
	var instance : Tower = tower.instance()
	if down:
		instance.position = position + SPAWN_DOWN
		instance.move_dir = Vector2.DOWN
	else:
		var rand := randf()
		if rand < 0.33:
			instance.position = position + SPAWN_LEFT
			instance.move_dir = Vector2.LEFT
		elif rand < 0.66:
			instance.position = position + SPAWN_RIGHT
			instance.move_dir = Vector2.RIGHT
		else:
			instance.position = position + SPAWN_UP
			instance.move_dir = Vector2.UP
	instance.lifespan = lifespan
	instance.damage = damage
	get_parent().add_child(instance)


func check_mobs():
	if active:
		if randf() < 0.25:
			animator.play("Shoot", -1, reload_speed)
		else:
			animator.play("Shoot1", -1, reload_speed)
	else:
		animator.play("Idle")
