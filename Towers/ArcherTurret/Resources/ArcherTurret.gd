extends Tower

const BASE_RANGE := 45.0
const BASE_SPEED := 0.7 # Shoot anim speed
const BASE_ARROW_SPEED := 50.0
const BASE_DAMAGE := 32.0

var shoot_speed := BASE_SPEED
var arrow_speed := BASE_ARROW_SPEED
var damage := BASE_DAMAGE


func update_stats():
	damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 3.0)
	shoot_speed = BASE_SPEED + (TowerDict.stats[id]["Speed"] * 0.08)
	arrow_speed = BASE_ARROW_SPEED + (TowerDict.stats[id]["Speed"] * 4.0)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.0)
