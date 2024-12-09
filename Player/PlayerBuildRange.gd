extends Node2D

const DEFAULT_BUILD_RANGE := 50.0

var build_radius := DEFAULT_BUILD_RANGE
var is_showing := false

func _ready():
	build_radius *= Modifiers.build_radius_multiplier

func show_range(show := true):
	is_showing = show
	update()


func _draw():
	if build_radius > 0.0 and is_showing:
		draw_circle(Vector2.ZERO, build_radius, Color(0.0, 0.0, 0.05, 0.08))
		draw_arc(Vector2.ZERO, build_radius, 0, 2*PI, 48, Color(1, 1, 1, 0.25), 1.0)
