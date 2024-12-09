extends ItemInfo
class_name TowerInfo

export var id : int = 0
export var cost : int = 100 # Cost to build in-game
export var level_sell_bonus : int = 10 # How much cash each level adds to the tower's sell price
export var target : String # Who the tower targets (usually FIRST, STRONG, or CLOSE) for shop description
export var preview_instance : PackedScene # Scene for building preview
export var tower_instance : PackedScene 
export var max_level = 45
# UI sprites
export(StreamTexture) var img_normal

var level : int = 1
