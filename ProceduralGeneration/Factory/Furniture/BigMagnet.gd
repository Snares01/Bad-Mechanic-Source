extends Furniture


func _ready():
	if randf() < 0.5:
		$Sprite.flip_h = true
		$CollisionPolygon2D.scale.x *= -1
