extends Tower

signal orb_added()

const ORB := preload("res://Towers/Orbiter/Scenes/Orb.tscn")
const BASE_ORBS := 1
const BASE_RANGE := 50.0 # this doesnt really have a range
const ORB_DISTANCE := 45.0
const OFFSET := Vector2(0, -8)
const SPIN_SPEED := 0.3 # speed of animation
const UPGRADE_TIMEOUT := 0.75 # disable orbs temporarily on upgrade

var orbs := []
var num_orbs := BASE_ORBS
var reflect_timeout := false
onready var animator : AnimationPlayer = $Animator

func update_stats():
	num_orbs = BASE_ORBS + (TowerDict.stats[id]["Orbs"])
	sight_range = BASE_RANGE

func _ready():
	animator.play("spin", -1, SPIN_SPEED)

func _process(delta):
	if num_orbs > orbs.size():
		while num_orbs > orbs.size():
			orbs.append(create_orb())
		emit_signal("orb_added")
		var timer := get_tree().create_timer(UPGRADE_TIMEOUT)
		timer.connect("timeout", self, "show_orbs")
	update_orbs()

func reflect_orbs() -> void:
	if reflect_timeout == true:
		return
		
	var anim_pos := animator.current_animation_position
	animator.play("spin", -1, -animator.get_playing_speed())
	animator.seek(anim_pos, true)
	
	reflect_timeout = true
	var timer := get_tree().create_timer(0.5)
	timer.connect("timeout", self, "reset_reflect_timeout")

func reset_reflect_timeout():
	reflect_timeout = false

func show_orbs() -> void:
	for orb in orbs:
		orb.show_orb()

func update_orbs() -> void:
	for i in orbs.size():
		var orb_pos := global_position + OFFSET
		var angle : float = deg2rad(i * (360.0 / orbs.size()))
		angle += deg2rad(360 * (animator.current_animation_position / animator.current_animation_length))
		orb_pos += Vector2(cos(angle), sin(angle)) * ORB_DISTANCE
		orbs[i].global_position = orb_pos
		# TODO: rotate orbs with animation

func create_orb() -> AreaOfEffect:
	var instance : AreaOfEffect = ORB.instance()
	instance.tower = self
	get_parent().add_child(instance)
	instance.create_aoe(global_position, Vector2.ZERO, 0.0, 0.1, -1)
	instance.connect("reflected", self, "reflect_orbs")
	return instance
