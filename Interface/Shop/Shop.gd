extends Node2D

const ITEM_POS := Vector2(0, -52)
const PLAYER := preload("res://Player/Player.tscn")
const GAME_MODIFIER_PREVIEW := preload("res://Items/!Classes/GameModifierPreview.tscn")

export var bg_music : AudioStream
export var dummy : Resource
export var path_1 : Curve2D
export var path_2 : Curve2D
export var path_3 : Curve2D
export var path_4 : Curve2D

var rng = RandomNumberGenerator.new()
var player_ref # Used for highlighting player during hints

onready var objects = get_node("GameObjects")
onready var consumables = get_node("%Consumables")
onready var range_preview = get_node("%RangePreview")
onready var hint_dim := get_node("%HintDim")
onready var upgrade_panel := get_node("%UpgradePanel")
onready var pause_menu := get_node("UILayer/GUI/PauseMenu")

func _ready():
	range_preview.hide()
	hint_dim.hide()
	for child in hint_dim.get_children():
		child.hide()
	rng.randomize()
	upgrade_panel.connect("item_selected", self, "_on_item_selected")
	upgrade_panel.connect("clear_preview", self, "clear_preview")
	SignalBus.connect("effect_activated", self, "_on_effect_activated")
	_on_dummy_timeout()
	MusicController.fade_in(bg_music)
	if SignalBus.game_level == 0:
		if Modifiers.hints and Modifiers.hint_buy_menu:
			hint_dim.show()
			upgrade_panel.highlight_buy_hint(true)
			hint_dim.get_node("HintBuy").show()
	else:
		if SignalBus.game_level == 1 and Modifiers.hints and Modifiers.hint_sell_menu:
			hint_dim.show()
			upgrade_panel.highlight_sell_hint(true)
			hint_dim.get_node("HintSell").show()
		MusicController.jump_to(rand_range(10.0, 100.0))


func _on_item_selected(item : ItemInfo):
	clear_preview()
	
	if item is TowerInfo:
		var instance : Tower = item.tower_instance.instance()
		instance.update_stats()
		instance.update_sight_range()
		if instance.sight_range > 40.0:
			instance.position = ITEM_POS
			objects.add_child(instance)
			range_preview.show_preview(instance.sight_range, ITEM_POS + instance.range_offset)
		else: # smol
			instance.position = Vector2(-65, -52)
			objects.add_child(instance)
			var instance_2 : Tower = item.tower_instance.instance()
			instance_2.position = Vector2(65, -52)
			objects.add_child(instance_2)
			range_preview.show_preview(instance.sight_range, ITEM_POS + instance.range_offset, true)
			instance_2.preview = true
		instance.preview = true
	elif item is ConsumableInfo:
		var instance = PLAYER.instance()
		instance.position = ITEM_POS
		instance.is_intro = false
		instance.disabled = false
		instance.get_node("Hurtbox").collision_layer = 0
		objects.add_child(instance)
		if item.uses == -1 and not item.is_cooldown:
			item.uses = item.max_uses
		consumables.create_card(item, true)
		if Modifiers.hints and Modifiers.hint_modifier_preview:
			instance.highlighted = true
			player_ref = instance
			hint_dim.show()
			hint_dim.get_node("HintPreview").show()
			var move_text := "Move Joe around\n(%s, %s, %s, %s)"
			move_text = move_text % [
				str(InputMap.get_action_list("move_up")[0].as_text()),
				str(InputMap.get_action_list("move_left")[0].as_text()),
				str(InputMap.get_action_list("move_down")[0].as_text()),
				str(InputMap.get_action_list("move_right")[0].as_text())
			]
			hint_dim.get_node("HintPreview/Label").text = move_text
	elif item is GameModifierInfo:
		var instance = GAME_MODIFIER_PREVIEW.instance()
		instance.position = ITEM_POS
		instance.texture = item.preview_sprite
		objects.add_child(instance)


func _on_effect_activated(effect : ItemEffect):
	add_child(effect)
	effect.effect()

func _process(delta):
	if hint_dim.visible:
		pause_menu.pausing_disabled = true
		if Input.is_action_just_pressed("ui_select"):
			if hint_dim.get_node("HintBuy").visible:
				hint_dim.get_node("HintBuy").hide()
				upgrade_panel.highlight_buy_hint(false)
				Modifiers.hint_buy_menu = false
				hint_dim.hide()
			elif hint_dim.get_node("HintAbility").visible:
				hint_dim.get_node("HintAbility").hide()
				consumables.modulate = Color(1, 1, 1)
				Modifiers.hint_modifier_preview = false
				hint_dim.hide()
			elif hint_dim.get_node("HintSell").visible:
				hint_dim.get_node("HintSell").hide()
				upgrade_panel.highlight_sell_hint(false)
				Modifiers.hint_sell_menu = false
				if not (Modifiers.hint_modifier_preview or Modifiers.hint_buy_menu
				  or Modifiers.hint_tower_level):
					Modifiers.hints = false
					var config := ConfigFileHandler.config
					config.set_value("gameplay", "hints", false)
					config.save(ConfigFileHandler.SETTINGS_FILE_PATH)
				hint_dim.hide()
		elif hint_dim.get_node("HintPreview").visible and Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
			hint_dim.hide()
			hint_dim.get_node("HintPreview").hide()
			if is_instance_valid(player_ref):
				player_ref.highlighted = false
			# TODO: add timer to next hint (ability button)
			var timer := get_tree().create_timer(1.0, false)
			timer.connect("timeout", self, "show_ability_hint")
	else:
		pause_menu.pausing_disabled = false

func show_ability_hint():
	if not is_instance_valid(player_ref):
		return
	consumables.modulate = Color(2, 2, 2)
	hint_dim.show()
	hint_dim.get_node("HintAbility").show()

func clear_preview():
	range_preview.hide()
	# Delete consumable UI & effects
	consumables.clear()
	for child in get_children():
		if child is ItemEffect:
			child.kill() # Stop effects
			child.queue_free()
	# Delete towers / player
	for i in objects.get_children():
		if i.is_in_group("Mobs"):
			continue
		objects.remove_child(i)
		i.queue_free()


func _on_dummy_timeout():
	var instance : Mob = dummy.instance()
	
	var path_select : float = rng.randf()
	if path_select < 0.125:
		instance.path = path_1
		instance.fast = false
	elif path_select < 0.5:
		instance.path = path_2
	elif path_select < 0.875:
		instance.path = path_3
	else:
		instance.path = path_4
		instance.fast = false
	
	objects.add_child(instance)
