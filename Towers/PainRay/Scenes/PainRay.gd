extends "res://Towers/FreezeRay/Scenes/FreezeRay.gd"

const BASE_DAMAGE := 150.0

func update_stats():
	damage = BASE_DAMAGE + (TowerDict.stats[id]["Damage"] * 14.0)
	sight_range = BASE_RANGE + (TowerDict.stats[id]["Range"] * 4.0)
