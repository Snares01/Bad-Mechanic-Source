extends Resource
class_name ItemInfo

export var name : String
export var shop_price := 200
export var sell_price := 50
export var rarity := 1.0 # Chance of appearing in shop (higher = more common)
export(String, MULTILINE) var description
