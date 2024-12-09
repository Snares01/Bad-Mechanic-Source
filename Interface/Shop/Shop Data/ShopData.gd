extends Resource
class_name ShopData

export(Array, Resource) var towers # TowerInfo
export(Array, Resource) var items # ItemInfo
export(Vector2) var num_towers # Min, max
export(Vector2) var num_items
export(float, 0, 1) var shtupidness := 0.0 # 0.5 = item prices can randomly be 50% cheaper / expensiver


func generate_shop_list(rng : RandomNumberGenerator) -> Array:
	rng.randomize()
	var output := []
	# Prepare for random tower selection
	var tower_rand_max := 0.0
	var valid_towers := []
	for tower in towers:
		if SignalBus.owned_towers.has(tower):
			print("Removed previously owned tower")
			continue
		tower_rand_max += tower.rarity
		valid_towers.append(tower)
	# Randomly select towers
	for i in rng.randi_range(min(num_towers.x, valid_towers.size()), min(num_towers.y, valid_towers.size())):
		var rand := rng.randf_range(0, tower_rand_max)
		var counter := 0.0
		for tower in valid_towers:
			if rand < (counter + tower.rarity):
				output.append(tower)
				tower_rand_max -= tower.rarity
				valid_towers.erase(tower)
				break
			counter += tower.rarity
	# Prepare for random item selection
	var item_rand_max := 0.0
	var valid_items := []
	for item in items:
		if SignalBus.owned_items.has(item):
			continue
		item_rand_max += item.rarity
		valid_items.append(item)
	# Randomly select items
	var item_rand := rand_range(0, item_rand_max)
	var item_counter := 0.0
	for i in rng.randi_range(min(num_items.x, valid_items.size()), min(num_items.y, valid_items.size())):
		for item in valid_items:
			if item_rand < (item_counter + item.rarity):
				output.append(item)
				valid_items.erase(item)
				break
			item_counter += item.rarity
	
	if shtupidness > 0.0:
		for item in output:
			var shtupid_price := rng.randf_range(item.shop_price - (shtupidness*item.shop_price), 
				item.shop_price + ((shtupidness*item.shop_price) / 2))
			item.shop_price = shtupid_price
	return output
