extends Area2D
class_name Hitbox

export var damage := 10.0
export var hit_mobs := true # Includes boss
export var hit_player := true
export(Bullet.effect) var effect

var prev_hits := []
var disabled := false

func _ready():
	collision_layer = 0
	collision_mask = 16 # Hurtbox
	connect("area_entered", self, "_on_hurtbox_entered")
	connect("body_entered", self, "_on_hurtbox_entered")


func refresh():
	prev_hits.clear()


func _on_hurtbox_entered(body: Node):
	if disabled:
		return
	if body in prev_hits:
		return
	if hit_player:
		if body.is_in_group("Player") and body.has_method("take_damage"):
			body.take_damage(damage, global_position.direction_to(body.global_position), effect)
			prev_hits.append(body)
	if hit_mobs:
		if body.has_method("take_damage") and not body.is_in_group("Player"):
			body.take_damage(damage, global_position.direction_to(body.global_position), effect)
			prev_hits.append(body)
