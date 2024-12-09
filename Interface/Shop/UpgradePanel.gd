extends MarginContainer

const SHOP_PROGRESSION = [
	"res://Interface/Shop/Shop Data/lvl1_shopdata.tres",
	"res://Interface/Shop/Shop Data/lvl2_shopdata.tres",
	"res://Interface/Shop/Shop Data/lvl3_shopdata.tres",
	"res://Interface/Shop/Shop Data/lvl4_shopdata.tres",
	"res://Interface/Shop/Shop Data/lvl5_shopdata.tres",
]

signal item_selected(item)
signal clear_preview()

var rng = RandomNumberGenerator.new()
var buy_items := []
var sell_items := []
var tier := 0 # Tier of items shown in shop, determined by level
var num_items := 0
var buying := true # buying/selling modes
var tower_sell_bonus := 0
var item_sell_bonus := 0
var bonus_eligible_sell_items := []

# GUI nodes
onready var item_list : ItemList = get_node("%ItemList")
onready var main_text := get_node("%MainText")
onready var shop_text := get_node("%ShopText")
onready var bonus_text := get_node("%BonusText")
onready var shop_menu := get_node("%ShopMenu")
onready var buy_menu := get_node("%BuyMenu")
onready var description := get_node("%Description")
onready var stats := get_node("%Stats")
onready var buy_button := get_node("%BuyButton")
onready var sell_button := get_node("%SellButton")

func _ready():
	Achievements.shop_cash_spent = 0
	Achievements.shop_sold_value = 0
	rng.randomize()
	load_items()
	bonus_eligible_sell_items = SignalBus.owned_items.duplicate()
	bonus_eligible_sell_items.append_array(SignalBus.owned_towers)
	var level_data : LevelData = load(SignalBus.LEVEL_PROGRESSION[SignalBus.game_level])
	bonus_text.text = "LEVEL START BONUS: $" + str(level_data.starting_cash)
	
	# Random events
	if SignalBus.game_level == 0:
		return
	var event_rand := randf()
	
	if event_rand < 0.1:
		tower_sell_bonus = stepify(rng.randi_range(20, 64), 5) * SignalBus.game_level
		shop_text.text = "SPECIAL DEAL: Bonus $" + str(tower_sell_bonus) + " for selling towers"
	elif event_rand < 0.2:
		item_sell_bonus = stepify(rng.randi_range(20, 49), 5) * SignalBus.game_level
		shop_text.text = "SPECIAL DEAL: Bonus $" + str(item_sell_bonus) + " for selling items"

func load_items(levels := SHOP_PROGRESSION):
	item_list.clear()
	buy_items.clear()
	var shop_data : ShopData = load(levels[SignalBus.game_level])
	if SignalBus.current_hat != null:
		SignalBus.current_hat.shop_effect(shop_data)
	buy_items = shop_data.generate_shop_list(rng)

func highlight_buy_hint(highlight: bool):
	if highlight:
		get_node("%BuyMenuButton").self_modulate = Color(2, 2, 2, 1)
	else:
		get_node("%BuyMenuButton").self_modulate = Color(1, 1, 1, 1)

func highlight_sell_hint(highlight: bool):
	if highlight:
		get_node("%SellMenuButton").self_modulate = Color(2, 2, 2, 1)
	else:
		get_node("%SellMenuButton").self_modulate = Color(1, 1, 1, 1)

# Adds items to ItemList
func print_items(buy := true):
	item_list.clear()
	if buy:
		buying = true
		for item in buy_items:
			var coolstring = "$" + String(item.shop_price) + " - " + item.name
			item_list.add_item(coolstring)
		# Disable items that can't be bought
		for i in item_list.get_item_count():
			var item : ItemInfo = buy_items[i]
			if item.shop_price > SignalBus.cash:
				item_list.set_item_disabled(i, true)
	else:
		buying = false
		sell_items.clear()
		sell_items = SignalBus.owned_items.duplicate()
		sell_items.append_array(SignalBus.owned_towers)
		for item in sell_items:
			var coolstring : String
			if item is TowerInfo:
				if tower_sell_bonus > 0 and item in bonus_eligible_sell_items:
					coolstring = "$" + str(item.sell_price + ((item.level - 1) * item.level_sell_bonus) + tower_sell_bonus) + " - " + item.name
					coolstring = coolstring + " (+" + str(tower_sell_bonus) + ")"
				else:
					coolstring = "$" + str(item.sell_price + ((item.level - 1) * item.level_sell_bonus)) + " - " + item.name
			else:
				if item_sell_bonus > 0 and item in bonus_eligible_sell_items:
					coolstring = "$" + str(item.sell_price + item_sell_bonus) + " - " + item.name
					if item is ConsumableInfo and not item.is_cooldown:
						coolstring = "$" + str(round(item.sell_price * (float(item.uses) / item.max_uses)) + item_sell_bonus) + " - " + item.name
					coolstring = coolstring + " (+" + str(item_sell_bonus) + ")"
				else:
					coolstring = "$" + str(item.sell_price) + " - " + item.name
					if item is ConsumableInfo and not item.is_cooldown:
						print(round(item.sell_price * (item.uses / float(item.max_uses))))
						coolstring = "$" + str(round(item.sell_price * (float(item.uses) / item.max_uses))) + " - " + item.name
			item_list.add_item(coolstring)
	
	for i in item_list.get_item_count():
		item_list.set_item_tooltip_enabled(i, false)


func _on_item_selected(index):
	if item_list.is_item_disabled(index):
		item_list.unselect_all()
	if buying:
		description.text = buy_items[index].description
		stats.text = ""
		if buy_items[index] is TowerInfo:
			description.text = buy_items[index].description
			stats.text = ("BUILD COST: $" + String(buy_items[index].cost) + "\nTARGETS: "
			+ buy_items[index].target.capitalize())
		elif buy_items[index] is ConsumableInfo:
			if buy_items[index].is_cooldown:
				stats.text = "COOLDOWN: " + String(buy_items[index].cooldown_duration) + " s"
			else:
				stats.text = "USES: " + String(buy_items[index].max_uses)
		emit_signal("item_selected", buy_items[index])
	else:
		description.text = sell_items[index].description
		stats.text = ""
		if sell_items[index] is TowerInfo:
			description.text = sell_items[index].description
			stats.text = ("LEVEL: " + String(sell_items[index].level) + "\nBONUS: $"
			+ String((sell_items[index].level - 1) * sell_items[index].level_sell_bonus))
		elif sell_items[index] is ConsumableInfo and not sell_items[index].is_cooldown:
			stats.text = "USES LEFT: " + String(sell_items[index].uses) + "/" + String(sell_items[index].max_uses)
		emit_signal("item_selected", sell_items[index])


func _on_buy_pressed():
	if not item_list.is_anything_selected():
		return
	var selected_index = item_list.get_selected_items()[0]
	var item_info : ItemInfo = buy_items[selected_index]
	if item_info.shop_price > SignalBus.cash:
		return
	
	emit_signal("clear_preview")
	description.text = "Thanks for the money dork"
	stats.text = ""
	SignalBus.change_cash(-item_info.shop_price)
	buy_items.remove(selected_index)
	if item_info is TowerInfo:
		SignalBus.owned_towers.append(item_info)
	elif item_info is ConsumableInfo:
		item_info.uses = item_info.max_uses
		SignalBus.owned_items.append(item_info)
	elif item_info is GameModifierInfo:
		item_info.activate_effect()
	print_items(true)
	Achievements.shop_cash_spent += item_info.shop_price
	Achievements.handle_event(Achievements.SHOP_PURCHASE)
	if item_info is TowerInfo:
		Modifiers.towers_unlocked += 1
	else:
		Modifiers.items_unlocked += 1


func _on_sell_pressed():
	if not item_list.is_anything_selected():
		return
	
	emit_signal("clear_preview")
	var selected_index : int = item_list.get_selected_items()[0]
	var item_info : ItemInfo = sell_items[selected_index]
	description.text = "Thanks for the " + item_info.name + " dork"
	stats.text = ""
	
	var cash_change: int
	sell_items.remove(selected_index)
	if item_info is TowerInfo:
		if item_info in bonus_eligible_sell_items:
			cash_change = item_info.sell_price + tower_sell_bonus + ((item_info.level - 1) * item_info.level_sell_bonus)
		else:
			cash_change = item_info.sell_price + ((item_info.level - 1) * item_info.level_sell_bonus)
		SignalBus.change_cash(cash_change)
		SignalBus.owned_towers.erase(item_info)
	else: # Item
		if item_info in bonus_eligible_sell_items:
			if item_info is ConsumableInfo and not item_info.is_cooldown:
				cash_change = round(item_info.sell_price * (float(item_info.uses) / item_info.max_uses)) + item_sell_bonus
			else:
				cash_change = item_info.sell_price + item_sell_bonus
		else:
			if item_info is ConsumableInfo and not item_info.is_cooldown:
				cash_change = round(item_info.sell_price * (float(item_info.uses) / item_info.max_uses))
			else:
				cash_change = item_info.sell_price
		SignalBus.change_cash(cash_change)
		SignalBus.owned_items.erase(item_info)
	
	Achievements.shop_sold_value += cash_change
	Achievements.handle_event(Achievements.SHOP_ITEM_SOLD)
	print_items(false)


func _on_exit_pressed():
	$VBox/Panels/Options/ShopMenu/ExitButton.disabled = true
	if SignalBus.owned_towers.size() > SignalBus.max_tower_slots:
		TransitionService.fade_out("res://Interface/Tower Select/TowerSelect.tscn")
	else:
		SignalBus.selected_towers = SignalBus.owned_towers
		SignalBus.switch_levels()


func _on_BuyMenuButton_pressed():
	description.text = "Select an item"
	stats.text = ""
	shop_menu.hide()
	buy_menu.show()
	main_text.hide()
	item_list.show()
	buy_button.show()
	sell_button.hide()
	print_items(true)


func _on_BackButton_pressed():
	item_list.unselect_all() 
	shop_menu.show()
	buy_menu.hide()
	main_text.show()
	item_list.hide()
	emit_signal("clear_preview")


func _on_SellMenuButton_pressed():
	description.text = "Select an item"
	stats.text = ""
	shop_menu.hide()
	buy_menu.show()
	main_text.hide()
	item_list.show()
	buy_button.hide()
	sell_button.show()
	print_items(false)


