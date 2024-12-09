extends Area2D

const COLOR_BAR := Color("3d3d3d")
const COLOR_HEALTH := Color("ff0044")

var current_mob : Mob
var current_hover : Mob

func _process(delta):
	# Mob Selection
	global_position = get_global_mouse_position()
	
	if get_overlapping_areas().empty(): # Empty hover
		if is_instance_valid(current_hover) and current_hover != current_mob:
			current_hover.deselect()
		current_hover = null
	else: # Mob hover
		var new_mob := get_closest_mob()
		if new_mob != current_hover and new_mob != current_mob: 
			if is_instance_valid(current_hover):
				current_hover.deselect()
			current_hover = new_mob
			current_hover.hover()
		if current_hover != current_mob and new_mob == current_mob:
			if is_instance_valid(current_hover):
				current_hover.deselect()
			current_hover = null
	# Health bar
	update()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if is_instance_valid(current_mob):
			current_mob.deselect()
		if get_overlapping_areas().empty(): # Empty click
			current_mob = null
		else: # Mob click
			var new_mob := get_closest_mob()
			current_hover = null
			current_mob = new_mob
			current_mob.select()



func _draw():
	if not is_instance_valid(current_mob):
		return
	var bar_width : float = current_mob.healthbar_width
	var bar_rect := Rect2(to_local(current_mob.global_position) + Vector2(-bar_width / 2.0, 3.0),
					Vector2(bar_width, 2))
	draw_rect(bar_rect, COLOR_BAR)
	bar_width = bar_width * min(1.0, current_mob.health / current_mob.max_health)
	bar_width = max(bar_width, 0.0)
	bar_rect.size.x = bar_width
	draw_rect(bar_rect, COLOR_HEALTH)


func get_closest_mob() -> Mob:
	var best_distance := -1.0
	var closest_mob : Mob
	var mouse_pos = get_global_mouse_position()
	for mob in get_overlapping_areas():
		var distance : float = mouse_pos.distance_squared_to(mob.global_position + mob.aim_offset)
		if distance < best_distance or best_distance == -1:
			closest_mob = mob
			best_distance = distance
	
	return closest_mob
