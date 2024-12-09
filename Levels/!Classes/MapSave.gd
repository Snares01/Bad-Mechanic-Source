extends Resource
class_name MapSave

var map_data : MapData
var path_curve := Curve2D.new()
var empty_rects := [] # Needs to be saved for 'splosions
var entrance_dir : Vector2

var top_map : PackedScene
var bottom_map : PackedScene

var furniture := [] # [PackedScene]
var furniture_positions := [] # [Vector2]
var towers := []
var tower_positions := []
