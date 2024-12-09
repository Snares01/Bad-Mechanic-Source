extends Node2D

var range_radius := 10.0
var range_pos := Vector2.ZERO
var alt_pos := false


func show_preview(size: float, pos : Vector2, alt := false):
	range_radius = size
	range_pos = pos
	alt_pos = alt
	update()
	show()


func _draw():
	if alt_pos:
		var pos_left := range_pos - Vector2(65, 0)
		var pos_right := range_pos + Vector2(65, 0)
		draw_circle(pos_left, range_radius, Color(0.8, 0.8, 1.0, 0.25))
		draw_circle(pos_right, range_radius, Color(0.8, 0.8, 1.0, 0.25))
	else:
		draw_circle(range_pos, range_radius, Color(0.8, 0.8, 1.0, 0.25))
