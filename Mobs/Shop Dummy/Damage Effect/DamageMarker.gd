extends Node2D

const DECAY_SPEED := 2.0
const GRAVITY := 50.0

var lifespan := 1.5
var velocity := Vector2.ZERO

onready var label := $Label

func _ready():
	lifespan = rand_range(1.5, 2.0)
	velocity = Vector2(rand_range(-30.0, 30.0), rand_range(-15.0, -30.0))
	z_index = 6
	hide()


func _process(delta):
	lifespan -= DECAY_SPEED * delta
	velocity.y += GRAVITY * delta
	position += velocity * delta
	if lifespan > 0.0:
		label.modulate.a = min(1.0, lifespan)
	else:
		queue_free()


func update_effect(damage : float):
	label.text = String(stepify(damage, 0.1))
	position += Vector2(0, -16)
	show()
