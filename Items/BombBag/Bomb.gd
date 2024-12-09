extends Sprite

const EXPLOSION := preload("res://Towers/!Resources/Explosion.tscn")

var lifespan := 3.0

func _ready():
	material.set_shader_param("spritesheet_size", Vector2(1, 1))
	material.set_shader_param("line_width", 0)

func _process(delta):
	lifespan -= delta
	
	if lifespan < 1.0:
		if fmod(lifespan, 0.2) < 0.1:
			material.set_shader_param("flash", 0.0)
		else:
			material.set_shader_param("flash", 1.0)
	if lifespan < 0.0:
		explode()

func explode():
	var instance : Hitbox = EXPLOSION.instance()
	get_parent().add_child(instance)
	instance.position = position + Vector2(0, -4)
	queue_free()
