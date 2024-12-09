extends AreaOfEffect

signal reflected()

const DAMAGE := 25.0

var tower : Tower

func _ready():
	tower.connect("orb_added", self, "hide_orb")

func hide_orb():
	modulate.a = 0.5
	disabled = true

func show_orb():
	modulate.a = 1.0
	disabled = false

func aoe_effect(target):
	if target.has_method("take_damage"):
		target.take_damage(DAMAGE * time_between_hits, direction)
	elif target.has_method("reflect"):
		emit_signal("reflected")

# Override
func get_env_collision() -> Dictionary:
	return {}
