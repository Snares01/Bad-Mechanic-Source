extends Mob

const HEAL_VALUE := 10.0

var life := 35.0

func _ready():
	$Sprite.frame = SignalBus.rng.randi_range(0, $Sprite.hframes - 1)
	set_flash_sprite($Sprite)
	collision_layer = 50


func _process(delta):
	life -= delta
	if life < 0.0:
		queue_free()


func pick_up():
	SignalBus.change_health(-HEAL_VALUE)
	Achievements.handle_event(Achievements.EGG_ACQUIRED)
	queue_free()


func on_death(direction):
	queue_free()
