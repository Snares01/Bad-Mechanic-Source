extends Sprite

const EXPLOSION := preload("res://Towers/!Resources/Explosion.tscn")

export var height := 0.0

var start_pos : Vector2 # global positions
var target_pos : Vector2 
var travel_time : float # seconds spent mid-air
var max_height : float

var lerp_weight := 0.0

func _process(delta):
	lerp_weight += delta / travel_time
	if lerp_weight >= 1.0:
		# SPAWN EXPLOSION
		var epic_explosion := EXPLOSION.instance()
		epic_explosion.position = position
		get_parent().add_child(epic_explosion)
		queue_free()
	
	position = lerp(start_pos, target_pos, lerp_weight)
	position.y += -height * max_height
	#(abs(lerp_weight - 0.5) * 2.0)


func init_bomb(speed: float, start: Vector2, target: Vector2):
	var distance := start.distance_to(target)
	travel_time = distance / speed 
	target_pos = target
	start_pos = start
	max_height = distance / 2.0
	position = start_pos
	$Animator.play("Toss", -1, 1.0 / travel_time)
