extends Hitbox

const LIFESPAN := 0.5
const COLOR := Color(0.5, 0.5, 1, 0.5)
const COLOR_FILL := Color(0.3, 0.3, 1.0, 0.2)
const COLOR_LINE := Color(0.15, 0.15, 0.6, 0.5)

func _ready():
	var timer := get_tree().create_timer(LIFESPAN)
	timer.connect("timeout", self, "_on_lifespan_timeout")
	update()


func _draw():
	draw_circle($CollisionShape2D.position, $CollisionShape2D.shape.radius, COLOR_FILL)
	draw_arc($CollisionShape2D.position, $CollisionShape2D.shape.radius, 0, 2*PI, 48, COLOR_LINE, 1.0)
	#draw_circle($CollisionShape2D.position, $CollisionShape2D.shape.radius, COLOR)


func _on_lifespan_timeout():
	queue_free()
