extends Resource
class_name MapData

export var rarity := 1.0 # Higher = higher chance of being picked
# Path generation
export(float, 0.0, 1.0) var bendiness := 0.5 # Increases turn frequency in path
export var min_segment_length := 4 # length in tiles
export var max_segment_length := 10
export var path_length_target := 30 # Approximate length of path in tiles
# Floor generation
export(float, 0.0, 1.0) var space_around_path := 0.25
export var min_normal_space_rects := 1 
export var max_normal_space_rects := 3
export var min_normal_space_size := 4
export var max_normal_space_size := 8
export var normal_empty_rects := 0
export var min_normal_empty_size := 2
export var max_normal_empty_size := 4
# Decorations
export(Array, PackedScene) var furniture := []
export var min_furniture_num := 0
export var max_furniture_num := 0
# Tileset values
export var tile_set : TileSet
export var floor_tile : int
export var wall_tile : int
export var floor_partial_wall_tile : int
export var path_partial_wall_tile : int # IMPLEMENT THIS
export var path_tile : int # Path tiles
export var path_endcap_tile : int
export var path_outer_corner_tile : int
export var path_inner_corner_tile : int 
export var path_inner_connect_tile : int # Path tile diagonal to inner corner
export var path_inner_support_tile : int # Path tile next to inner corner
export var border_top : int # top map / border
export var border_bottom : int
export var border_side : int
export var border_outer_upper_corner : int
export var border_outer_lower_corner : int
export var border_inner_upper_corner : int
export var border_inner_lower_corner : int
# Optional tilesets; keep at -1 unless these tiles need unique tiles for x_flip
export var flip_floor_partial_wall_tile := -1 
export var flip_path_outer_corner_tile := -1
export var x_flip_path_inner_corner_tile := -1
export var y_flip_path_inner_corner_tile := -1
export var x_y_flip_path_inner_corner_tile := -1
# Misc
export var portal : PackedScene = null
