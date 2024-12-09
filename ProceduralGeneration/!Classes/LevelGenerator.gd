extends Node2D
# Generates levels based on MapData, updates levels & implements destruction of walls
const DESTROY_SOUND := preload("res://ProceduralGeneration/!Classes/DestructionSound.tscn")

onready var bottom_map := $BottomMap
onready var top_map := $TopMap
onready var rng : RandomNumberGenerator = SignalBus.rng

var data : MapData
var path_curve := Curve2D.new()
var path_points := []
var empty_rects := [] # Rect2s that cannot have floor tiles
var filled_rects := [] # Rect2s that will be filled with floor tiles
var furniture_list := []
var entrance_dir : Vector2

func _ready():
	SignalBus.connect("destroy_area", self, "destroy_walls")
	if SignalBus.current_level is LevelData and not SignalBus.game_level == SignalBus.LEVEL_PROGRESSION.size():
		get_parent().connect("level_end", self, "_save_map")

func import_mapdata(map_data : MapData) -> Curve2D:
	data = map_data
	generate_map()
	return path_curve

func import_mapsave(map_save : MapSave) -> Curve2D:
	data = map_save.map_data
	path_curve = map_save.path_curve
	empty_rects = map_save.empty_rects
	entrance_dir = map_save.entrance_dir
	remove_child($TopMap)
	remove_child($BottomMap)
	top_map = map_save.top_map.instance()
	bottom_map = map_save.bottom_map.instance()
	add_child(top_map)
	add_child(bottom_map)
	
	return path_curve

func _save_map():
	var map_save := MapSave.new()
	map_save.map_data = data
	map_save.path_curve = path_curve
	map_save.empty_rects = empty_rects
	map_save.entrance_dir = entrance_dir
	var furniture_positions := []
	var furniture_save := []
	var tower_positions := []
	var tower_save := []
	for object in get_parent().game_objects.get_children():
		if object is Furniture:
			furniture_positions.append(object.position)
			var scene := PackedScene.new()
			scene.pack(object)
			furniture_save.append(scene)
		elif object is Tower:
			tower_positions.append(object.position)
			var scene := PackedScene.new()
			scene.pack(object)
			tower_save.append(scene)
	map_save.furniture_positions = furniture_positions
	map_save.furniture = furniture_save
	map_save.tower_positions = tower_positions
	map_save.towers = tower_save
	
	var packman := PackedScene.new()
	packman.pack(top_map)
	map_save.top_map = packman
	var packman2 := PackedScene.new()
	packman2.pack(bottom_map)
	map_save.bottom_map = packman2
	SignalBus.previous_levels.push_front(map_save)

# TO DO: return an array of deleted tiles for particle effects & stuff
func destroy_walls(center_pos : Vector2, size : int) -> void:
	var did_things_blow_up := false
	var rect_pos: Vector2 = bottom_map.world_to_map(center_pos) - Vector2(floor(size/2), floor(size/2))
	var rect := Rect2(rect_pos, Vector2(size, size))
	# Remove cells
	var x : float = rect.position.x
	var y : float = rect.position.y
	
	for yi in rect.size.y:
		for xi in rect.size.x:
			if bottom_map.get_cell(x, y) != TileMap.INVALID_CELL:
				x += 1
				continue
			var valid_cell := true
			for empty_rect in empty_rects:
				if empty_rect.has_point(Vector2(x, y)):
					valid_cell = false
			if valid_cell:
				bottom_map.set_cell(x, y, data.floor_tile)
				did_things_blow_up = true
			x += 1
		y += 1
		x -= rect.size.x
	# Clean cells, play sound effect
	if did_things_blow_up:
		update_map(rect.grow(2))
		var instance : AudioStreamPlayer2D = DESTROY_SOUND.instance()
		add_child(instance)
		instance.global_position = center_pos
		instance.play()

# Called when the map is altered
func update_map(area : Rect2):
	var x : float = area.position.x
	var y : float = area.position.y
	for yi in area.size.y:
		for xi in area.size.x:
			if bottom_map.get_cell(x, y) == data.floor_tile:
				_clean_tile(Vector2(x, y))
			x += 1
		y += 1
		x -= area.size.x
	_generate_top_map()

func generate_map():
	empty_rects.clear()
	filled_rects.clear()
	path_curve.clear_points()
	path_points.clear()
	bottom_map.clear()
	top_map.clear()
	bottom_map.tile_set = data.tile_set
	top_map.tile_set = data.tile_set
	
	var path_check : bool = _generate_path()
	while (path_check == false):
		print("Path generation failed, retrying...")
		empty_rects.clear()
		# delete empty rects
		path_check = _generate_path()
	_generate_floor()
	_update_floor_generation()
	_generate_top_map()
	if data.portal != null:
		_generate_portal()
	_generate_furniture()
	filled_rects.clear()

# Fills in path_curve and path_points, returns true if successful
func _generate_path() -> bool: 
	var visited_points := [Vector2.ZERO]
	var path_length := 0
	var prev_dir := Vector2.ZERO 
	# Make path by walking in segments
	var loop_count := 0 
	while (path_length < data.path_length_target):
		loop_count += 1
		if loop_count > 100:
			return false # no infinite looping
		# Create the segment
		var segment_length := rng.randi_range(data.min_segment_length, data.max_segment_length)
		var segment_dir := _rand_cardinal(prev_dir)
		var segment := []
		while (segment_dir + prev_dir == Vector2.ZERO): # Don't walk backwards
			segment_dir = _rand_cardinal(prev_dir)
		prev_dir = segment_dir
		if path_length == 0: # Initial segment
			segment_length += 2
			entrance_dir = segment_dir
			# Create special entrance rules & tiles
			match segment_dir:
				Vector2.LEFT:
					empty_rects.append(Rect2(-1, -4, 3, 7))
					empty_rects.append(Rect2(-2, -4, 1, 2))
					empty_rects.append(Rect2(-2, 1, 1, 2))
					bottom_map.set_cell(-2, -2, data.wall_tile)
					top_map.set_cell(-2, -2, data.border_top)
					top_map.set_cell(-2, 0, data.border_bottom)
				Vector2.RIGHT:
					empty_rects.append(Rect2(-2, -4, 3, 7))
					empty_rects.append(Rect2(1, -4, 1, 2))
					empty_rects.append(Rect2(1, 1, 1, 2))
					bottom_map.set_cell(1, -2, data.wall_tile)
					top_map.set_cell(1, -2, data.border_top)
					top_map.set_cell(1, 0, data.border_bottom)
				Vector2.UP:
					empty_rects.append(Rect2(-3, -1, 6, 3))
					empty_rects.append(Rect2(-3, -2, 2, 1))
					empty_rects.append(Rect2(1, -2, 2, 1))
					top_map.set_cell(0, -2, data.border_side)
					top_map.set_cell(-1, -2, data.border_side, true)
				Vector2.DOWN:
					empty_rects.append(Rect2(-3, -2, 6, 3))
					empty_rects.append(Rect2(-3, 1, 2, 1))
					empty_rects.append(Rect2(1, 1, 2, 1))
					bottom_map.set_cell(-1, 2, data.path_partial_wall_tile)
					bottom_map.set_cell(0, 2, data.path_partial_wall_tile, true)
					top_map.set_cell(0, 1, data.border_side)
					top_map.set_cell(-1, 1, data.border_side, true)
		for i in segment_length:
			segment.append(visited_points.back() + (segment_dir * (i + 1)))
		# Check for intersections
		if visited_points.size() > 5:
			var intersection := false
			var is_first_segment := false
			if path_length == 0:
				is_first_segment = true
			var check_points := visited_points.duplicate()
			check_points.resize(visited_points.size() - 4)
			for seg_point in segment:
				for path_point in check_points:
					if (seg_point.distance_to(path_point) <= 3.0 or seg_point.distance_to(Vector2.ZERO) <= 4.5):
						intersection = true
						break 
				if not is_first_segment:
					for rect in empty_rects:
						if rect.has_point(seg_point):
							intersection = true
							break
				if intersection:
					break # break break break break break break
			if intersection:
				continue
		# Add segment to path
		visited_points.append_array(segment)
		path_length += segment_length
		
		if path_length >= data.path_length_target: # Create endcap
			var end_cap_pos : Vector2 = visited_points.back() + (segment_dir * 0.5)
			visited_points.append(end_cap_pos)
			if fmod(end_cap_pos.x, 1) == 0: # Horizontal endcap
				end_cap_pos.y = floor(end_cap_pos.y)
				bottom_map.set_cellv(end_cap_pos, data.path_endcap_tile)
				bottom_map.set_cellv(end_cap_pos + Vector2.LEFT, data.path_endcap_tile)
			else: # Vertical endcap
				end_cap_pos.x = floor(end_cap_pos.x)
				bottom_map.set_cellv(end_cap_pos, data.path_endcap_tile)
				bottom_map.set_cellv(end_cap_pos + Vector2.UP, data.path_endcap_tile)
	# Put results in path_curve & path_points
	for point in visited_points:
		path_curve.add_point(point * 16)
	path_points = visited_points
	#print(path_curve.get_baked_length())
	_generate_path_tiles()
	return true

func _generate_path_tiles():
	# Endcap tiles are made in _generate_path
	# Get dir of current point,
	var forward_dir : Vector2
	var back_dir : Vector2
	for i in (path_points.size() - 1): # Don't iterate over endpoint
		var point : Vector2 = path_points[i]
		var corner := false
		if i < path_points.size() - 2:
			forward_dir = path_points[i + 1] - point
		if i == 0:
			continue
		# Determine if this is a corner
		back_dir = path_points[i - 1] - point
		if back_dir + forward_dir != Vector2.ZERO:
			corner = true
		if corner: # Corner tile placement
			var inner_pos := forward_dir + back_dir # did i name inner_pos/outer_pos backwards? idk
			inner_pos.x = max(inner_pos.x, 0)
			inner_pos.y = max(inner_pos.y, 0)
			if data.flip_path_outer_corner_tile != -1 and not inner_pos.x:
				bottom_map.set_cellv(point + (inner_pos * -1), data.flip_path_outer_corner_tile, false, (not inner_pos.y)) # might need different vars for x-flip and y-flip
			else:
				bottom_map.set_cellv(point + (inner_pos * -1), data.path_outer_corner_tile, (not inner_pos.x), (not inner_pos.y), false)
			
			bottom_map.set_cellv(point + (inner_pos + Vector2(-1, -1)), data.path_inner_connect_tile, inner_pos.x, inner_pos.y, false)
			var outer_pos := (forward_dir * 2) + (back_dir * 2)
			outer_pos.x = min(outer_pos.x, 1)
			outer_pos.y = min(outer_pos.y, 1)
			if data.x_flip_path_inner_corner_tile != -1 and not inner_pos.x and inner_pos.y:
				bottom_map.set_cellv(point + outer_pos, data.x_flip_path_inner_corner_tile)
			elif data.y_flip_path_inner_corner_tile != -1 and inner_pos.x and not inner_pos.y:
				bottom_map.set_cellv(point + outer_pos, data.y_flip_path_inner_corner_tile)
			elif data.x_y_flip_path_inner_corner_tile != -1 and not inner_pos.x and not inner_pos.y:
				bottom_map.set_cellv(point + outer_pos, data.x_y_flip_path_inner_corner_tile)
			else:
				bottom_map.set_cellv(point + outer_pos, data.path_inner_corner_tile, (not inner_pos.x), (not inner_pos.y), false)
			if sign(back_dir.y): # back dir is vertical
				bottom_map.set_cellv(point + outer_pos + -forward_dir, data.path_inner_support_tile, (forward_dir.x == 1), (back_dir.y == -1), true)
				bottom_map.set_cellv(point + outer_pos + -back_dir, data.path_inner_support_tile, (forward_dir.x == -1), (back_dir.y == 1), false)
			else: 
				bottom_map.set_cellv(point + outer_pos + -forward_dir, data.path_inner_support_tile, (back_dir.x == -1), (forward_dir.y == 1), false)
				bottom_map.set_cellv(point + outer_pos + -back_dir, data.path_inner_support_tile, (back_dir.x == 1), (forward_dir.y == -1), true)
		else: # Straight tiles
			var vertical := false
			if forward_dir.y != 0:
				vertical = true
			_fill_cell_bottom(point, data.path_tile, vertical, (not vertical), vertical) # Bottom right
			_fill_cell_bottom(point + Vector2.LEFT, data.path_tile, false, (not vertical), vertical) # Bottom left
			_fill_cell_bottom(point + Vector2.UP, data.path_tile, vertical, false, vertical) # Up right
			_fill_cell_bottom(point + Vector2(-1, -1), data.path_tile, false, false, vertical) # Up left

func _generate_floor():
	# Create normally distributed fill_rects
	for i in rng.randi_range(data.min_normal_space_rects, data.max_normal_space_rects):
		var rand_distance : float = rng.randf()
		var used_rect : Rect2 = bottom_map.get_used_rect()
		var rand_dir := Vector2(rng.randf() - 0.5, rng.randf() - 0.5).normalized()
		var max_dist := min(used_rect.size.x / 4.0, used_rect.size.y / 4.0)
		var dist_from_center := rand_dir * (rand_distance * max_dist)
		# Create the rect
		var rect_width := rng.randi_range(data.min_normal_space_size, data.max_normal_space_size)
		var rect_height := rng.randi_range(data.min_normal_space_size, data.max_normal_space_size)
		var rect_center := (used_rect.get_center() + (rand_dir * dist_from_center)).round()
		var fill_rect := Rect2(rect_center.x - round(rect_width/2),
			rect_center.y - round(rect_height/2), rect_width, rect_height)
		# Check that the rect isn't floating in space
		var overlapping_tiles := 0
		var x : float = fill_rect.position.x
		var y : float = fill_rect.position.y
		for yi in fill_rect.size.y:
			for xi in fill_rect.size.x:
				if bottom_map.get_cell(x, y) != TileMap.INVALID_CELL:
					overlapping_tiles += 1
				x += 1
			if overlapping_tiles > 2:
				break
			y += 1
			x -= fill_rect.size.x
		# Place rect
		if overlapping_tiles > 2:
			filled_rects.append(fill_rect)
	# Create fill_rects around path (space_around_path)
	var tiles_without_fill := 0
	for i in (path_points.size() - 1):
		if i < 4:
			continue
		var point : Vector2 = path_points[i]
		var rand := rng.randf()
		var rect_size := 2 # min rect size is 4x4
		if rand < data.space_around_path or tiles_without_fill > 13:
			rect_size += 2
			tiles_without_fill = 0
		else:
			tiles_without_fill += 1
		var rect_pos := point - Vector2(rect_size, rect_size)
		filled_rects.append(Rect2(rect_pos, Vector2(rect_size*2, rect_size*2)))
		if rect_size == 2 and (path_points[i + 1].y >= rect_pos.y or i == path_points.size() - 2):
			filled_rects.append(Rect2(rect_pos + Vector2.UP, Vector2(4, 1))) # so walls cant touch path
	# Place tiles in fill rects
	for rect in filled_rects:
		var x : float = rect.position.x
		var y : float = rect.position.y
		
		for i in rect.size.y:
			for j in rect.size.x:
				_fill_cell_bottom(Vector2(x, y), data.floor_tile)
				x += 1
			y += 1
			x -= rect.size.x
	# Create normally distributed empty rects
	for i in data.normal_empty_rects:
		var rand_distance : float = rng.randf()
		var used_rect : Rect2 = bottom_map.get_used_rect()
		var rand_dir := Vector2(rng.randf() - 0.5, rng.randf() - 0.5).normalized()
		var max_dist := max(used_rect.size.x / 1.5, used_rect.size.y / 1.5)
		var dist_from_center := rand_dir * (rand_distance * max_dist)
		# Create the rect
		var rect_width := rng.randi_range(data.min_normal_empty_size, data.max_normal_empty_size)
		var rect_height := rng.randi_range(data.min_normal_empty_size, data.max_normal_empty_size)
		var rect_center := (used_rect.get_center() + (rand_dir * dist_from_center)).round()
		var empty_rect := Rect2(rect_center.x - round(rect_width/2),
			rect_center.y - round(rect_height/2), rect_width, rect_height)
		# Check if the rect is entirely on floor tiles
		var is_rect_valid := true
		var x : float = empty_rect.position.x
		var y : float = empty_rect.position.y
		for yi in empty_rect.size.y + 1:
			for xi in empty_rect.size.x:
				if bottom_map.get_cell(x, y) != data.floor_tile:
					is_rect_valid = false
					break
				x+= 1
			if not is_rect_valid:
				break
			y += 1
			x -= empty_rect.size.x
		# Check for incompatible tiles next to empty rect
		x = empty_rect.position.x - 1
		y = empty_rect.position.y
		for yi in empty_rect.size.y + 1:
			if not (bottom_map.get_cell(x, y) in [data.path_tile, data.floor_tile]):
				is_rect_valid = false
				break
			y += 1
		x = empty_rect.position.x + empty_rect.size.x
		y = empty_rect.position.y
		for yi in empty_rect.size.y + 1:
			if not (bottom_map.get_cell(x, y) in [data.path_tile, data.floor_tile]):
				is_rect_valid = false
				break
			y += 1
		# Check if too close to entrance
		if Rect2(-4, -4, 8, 8).intersects(empty_rect, true):
			is_rect_valid = false
		# Place rect
		if is_rect_valid:
			empty_rects.append(empty_rect)
	# Remove tiles from empty rects
	for rect in empty_rects:
		var x : float = rect.position.x
		var y : float = rect.position.y
		
		for i in rect.size.y:
			for j in rect.size.x:
				bottom_map.set_cell(x, y, -1)
				x += 1
			y += 1
			x -= rect.size.x

# Places top map tiles, assumes bottom map is made
# To do: Add option to update a specific region instead of the entire map
func _generate_top_map():
	# Clear walls & border
	top_map.clear()
	match entrance_dir:
		Vector2.LEFT:
			top_map.set_cell(-2, -2, data.border_top)
			top_map.set_cell(-2, 0, data.border_bottom)
		Vector2.RIGHT:
			top_map.set_cell(1, -2, data.border_top)
			top_map.set_cell(1, 0, data.border_bottom)
		Vector2.UP:
			top_map.set_cell(0, -2, data.border_side)
			top_map.set_cell(-1, -2, data.border_side, true)
		Vector2.DOWN:
			top_map.set_cell(0, 1, data.border_side)
			top_map.set_cell(-1, 1, data.border_side, true)
	
	var wall_tiles : Array = bottom_map.get_used_cells_by_id(data.wall_tile)
	wall_tiles.append_array(bottom_map.get_used_cells_by_id(data.floor_partial_wall_tile))
	wall_tiles.append_array(bottom_map.get_used_cells_by_id(data.flip_floor_partial_wall_tile))
	for tile in wall_tiles:
		bottom_map.set_cellv(tile, data.floor_tile)
	for tile in bottom_map.get_used_cells_by_id(data.path_partial_wall_tile):
		if bottom_map.is_cell_x_flipped(tile.x, tile.y):
			bottom_map.set_cellv(tile, data.path_tile, true, false, true)
		else:
			bottom_map.set_cellv(tile, data.path_tile, false, false, true)
	
	# Place walls & border
	for cell in bottom_map.get_used_cells():
		_create_border_tile(cell)


func _generate_furniture():
	if data.furniture.empty():
		return
	var map_rect : Rect2 = bottom_map.get_used_rect()
	map_rect.size *= 16
	map_rect.position *= 16
	for i in rng.randi_range(data.min_furniture_num, data.max_furniture_num):
		var instance : Furniture = data.furniture[rng.randi_range(0, data.furniture.size() - 1)].instance()
		instance.map_rect = map_rect
		instance.bottom_map_ref = bottom_map
		furniture_list.append(instance)
		#get_node("../GameObjects").add_child(instance)


func _generate_portal():
	var instance : Furniture = data.portal.instance()
	var map_rect : Rect2 = bottom_map.get_used_rect()
	map_rect.size *= 16
	map_rect.position *= 16
	instance.map_rect = map_rect
	instance.bottom_map_ref = bottom_map
	furniture_list.append(instance)

func _create_border_tile(cell : Vector2):
	var border_path_check := [data.path_tile, data.path_partial_wall_tile,
	data.path_outer_corner_tile, data.flip_path_outer_corner_tile]
	var left_empty : bool = (bottom_map.get_cellv(cell + Vector2.LEFT) == -1)
	var right_empty : bool = (bottom_map.get_cellv(cell + Vector2.RIGHT) == -1)
	var up_empty : bool = (bottom_map.get_cellv(cell + Vector2.UP) == -1)
	var down_empty : bool = (bottom_map.get_cellv(cell + Vector2.DOWN) == -1)
	if not (left_empty or right_empty or up_empty or down_empty):
		# Test diagonals for inner corner tiles
		if (bottom_map.get_cellv(cell + Vector2(-1, 1)) == -1):
			_fill_cell_top(cell, data.border_inner_lower_corner, true)
		elif (bottom_map.get_cellv(cell + Vector2(1, 1)) == -1):
			_fill_cell_top(cell, data.border_inner_lower_corner)
		elif (bottom_map.get_cellv(cell + Vector2(-1, -1)) == -1):
			_fill_cell_top(cell, data.border_inner_upper_corner, true)
			if bottom_map.get_cellv(cell) in border_path_check:
				bottom_map.set_cellv(cell, data.path_partial_wall_tile)
			else:
				bottom_map.set_cellv(cell, data.floor_partial_wall_tile)
		elif (bottom_map.get_cellv(cell + Vector2(1, -1)) == -1):
			_fill_cell_top(cell, data.border_inner_upper_corner)
			if bottom_map.get_cellv(cell) in border_path_check:
				bottom_map.set_cellv(cell, data.path_partial_wall_tile, true)
			else:
				if data.flip_floor_partial_wall_tile != -1:
					bottom_map.set_cellv(cell, data.flip_floor_partial_wall_tile)
				else:
					bottom_map.set_cellv(cell, data.floor_partial_wall_tile, true)
		return
	if not left_empty and not right_empty:
		if up_empty:
			if bottom_map.get_cellv(cell + Vector2(-1, 1)) == -1:
				_fill_cell_top(cell, data.border_outer_upper_corner)
			elif bottom_map.get_cellv(cell + Vector2(1, 1)) == -1:
				_fill_cell_top(cell, data.border_outer_upper_corner, true)
			else:
				_fill_cell_top(cell, data.border_top)
			if bottom_map.get_cellv(cell) == data.floor_tile:
				bottom_map.set_cellv(cell, data.wall_tile)
		elif down_empty:
			if bottom_map.get_cellv(cell + Vector2(1, -1)) == -1:
				_fill_cell_top(cell, data.border_outer_lower_corner)
			elif bottom_map.get_cellv(cell + Vector2(-1, -1)) == -1:
				_fill_cell_top(cell, data.border_outer_lower_corner, true)
			_fill_cell_top(cell, data.border_bottom)
	elif not up_empty and not down_empty:
		if right_empty:
			_fill_cell_top(cell, data.border_side)
		else:
			_fill_cell_top(cell, data.border_side, true)
	elif down_empty:
		if right_empty:
			_fill_cell_top(cell, data.border_outer_lower_corner)
		else:
			_fill_cell_top(cell, data.border_outer_lower_corner, true)
	else:
		if left_empty:
			_fill_cell_top(cell, data.border_outer_upper_corner)
			if bottom_map.get_cellv(cell) == data.floor_tile:
				bottom_map.set_cellv(cell, data.wall_tile, true)
		else:
			_fill_cell_top(cell, data.border_outer_upper_corner, true)
			if bottom_map.get_cellv(cell) == data.floor_tile:
				bottom_map.set_cellv(cell, data.wall_tile)

# Fix invalid gaps & floors
# This function used to be more important now I dont really know what it does
# BUT ITS STILL IMPORTANT
func _update_floor_generation():
	var used_rect : Rect2 = bottom_map.get_used_rect()
	var x : float = used_rect.position.x
	var y : float = used_rect.position.y
	
	for i in used_rect.size.y:
		for j in used_rect.size.x:
			var cell := Vector2(x, y)
			x += 1
			var cell_id : int = bottom_map.get_cellv(cell)
			# Remove bugged floor tiles
			if cell_id == data.floor_tile:
				if (bottom_map.get_cellv(cell + Vector2(-1, -1)) == -1 and bottom_map.get_cellv(cell + Vector2(1, 1)) == -1
				and bottom_map.get_cellv(cell + Vector2(-1, 1)) != -1 and bottom_map.get_cellv(cell + Vector2(1, -1)) != -1):
					bottom_map.set_cellv(cell, -1)
				elif (bottom_map.get_cellv(cell + Vector2(-1, 1)) == -1 and bottom_map.get_cellv(cell + Vector2(1, -1)) == -1
				and bottom_map.get_cellv(cell + Vector2(-1, -1)) != -1 and bottom_map.get_cellv(cell + Vector2(1, 1)) != -1):
					bottom_map.set_cellv(cell, -1)
			if cell_id != -1 and cell_id != data.floor_tile:
				continue
			var left_empty : bool = (bottom_map.get_cellv(cell + Vector2.LEFT) == -1)
			var right_empty : bool = (bottom_map.get_cellv(cell + Vector2.RIGHT) == -1)
			var up_empty : bool = (bottom_map.get_cellv(cell + Vector2.UP) == -1)
			var down_empty : bool = (bottom_map.get_cellv(cell + Vector2.DOWN) == -1)
			for rect in empty_rects:
				if not left_empty and rect.has_point(cell + Vector2.LEFT):
					left_empty = true
				if not right_empty and rect.has_point(cell + Vector2.RIGHT):
					right_empty = true
				if not up_empty and rect.has_point(cell + Vector2.UP):
					up_empty = true
				if not down_empty and rect.has_point(cell + Vector2.DOWN):
					down_empty = true
			if cell_id == data.floor_tile: # Floor tile conditions
				if (left_empty and right_empty) or (up_empty and down_empty):
					bottom_map.set_cellv(cell, -1)
			else: # Empty tile conditions
				if (not left_empty and not right_empty) or (not up_empty and not down_empty):
						bottom_map.set_cellv(cell, data.floor_tile)
		y += 1
		x -= used_rect.size.x
	
	empty_rects.resize(3) # Only keep entrance empty_rects
	for cell in bottom_map.get_used_cells_by_id(data.floor_tile):
		_clean_tile(cell)

# set_cellv but only if the cell is empty
func _fill_cell_bottom(cell_pos : Vector2, tile_index : int, flip_x := false, flip_y := false, transpose := false):
	if bottom_map.get_cellv(cell_pos) == TileMap.INVALID_CELL:
		for rect in empty_rects:
			if rect.has_point(cell_pos):
				return
		bottom_map.set_cellv(cell_pos, tile_index, flip_x, flip_y, transpose)

func _fill_cell_top(cell_pos : Vector2, tile_index : int, flip_x := false, flip_y := false, transpose := false):
	if (top_map.get_cellv(cell_pos) == TileMap.INVALID_CELL
	and not Rect2(-2, -2, 4, 4).has_point(cell_pos)): # Don't build walls over entrance areas
		top_map.set_cellv(cell_pos, tile_index, flip_x, flip_y, transpose)

# Gets rid of cringe tiles I dont have art for
# Assumes "cell" is a valid bottom_map tile
func _clean_tile(cell : Vector2):
	var left_empty : bool = (bottom_map.get_cellv(cell + Vector2.LEFT) == -1)
	var right_empty : bool = (bottom_map.get_cellv(cell + Vector2.RIGHT) == -1)
	var up_empty : bool = (bottom_map.get_cellv(cell + Vector2.UP) == -1)
	var down_empty : bool = (bottom_map.get_cellv(cell + Vector2.DOWN) == -1)
	var upleft_empty : bool = (bottom_map.get_cellv(cell + Vector2(-1, -1)) == -1)
	var upright_empty : bool = (bottom_map.get_cellv(cell + Vector2(1, -1)) == -1)
	var downleft_empty : bool = (bottom_map.get_cellv(cell + Vector2(-1, 1)) == -1)
	var downright_empty : bool = (bottom_map.get_cellv(cell + Vector2(1, 1)) == -1)
	
	if (left_empty and right_empty) or (up_empty and down_empty):
		bottom_map.set_cellv(cell, -1)
	elif not (up_empty or down_empty) and (left_empty or right_empty):
		if ((left_empty and upright_empty)
		or (right_empty and upleft_empty)):
			bottom_map.set_cellv(cell, -1)
	elif (not (left_empty or right_empty or up_empty or down_empty)
	and ((upleft_empty and downright_empty) or (upright_empty and downleft_empty))):
		bottom_map.set_cellv(cell, -1)

func _rand_cardinal(prev_dir := Vector2.ZERO) -> Vector2:
	var rand := rng.randf()
	if prev_dir == Vector2.ZERO:
		if rand < 0.25:
			return Vector2.UP
		elif rand < 0.5:
			return Vector2.RIGHT
		elif rand < 0.75:
			return Vector2.DOWN
		return Vector2.LEFT
	else:
		var straight_chance := 0.25 - (0.25 * data.bendiness)
		var normal_chance := (1 - straight_chance) / 3
		var directions := [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
		var rand_total := 0.0
		for direction in directions:
			if direction == prev_dir:
				rand_total += straight_chance
			else:
				rand_total += normal_chance
			if rand < rand_total:
				return direction
	return Vector2.LEFT
