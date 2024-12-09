extends "res://Mobs/Little Business/LittleMan.gd"

const CATCH_UP_SPEED := 36.0
const FOLLOW_SPEED := 6.0

var catching_up := true
var distance_to_reach := 100.0 # path_progress, set by TEO
var boss : Boss

func _ready():
	base_speed = CATCH_UP_SPEED
	$Animator.play("Run1", -1, 2.0)


func _process(delta):
	if catching_up:
		distance_to_reach = boss.path_progress - 12.5
		if path_progress >= distance_to_reach:
			catching_up = false
			base_speed = FOLLOW_SPEED
			$Animator.play("Run1")

func take_damage(damage : float, direction : Vector2, effect := Bullet.effect.NONE):
	if not catching_up:
		.take_damage(damage, direction, effect)
