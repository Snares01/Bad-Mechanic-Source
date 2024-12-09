extends YSort # Used on GameObjects node

enum type {
	CASH = 0,
	HEALTH = 1,
	COIN = 2,
}
enum state {
	MOVE = 0, # Intial state
	IDLE = 1,
	COLLECT = 2,
}
const DROP_SPRITES := [
	preload("res://Drops/!Sprites/cash1.png"), # Cash
	preload("res://Drops/!Sprites/cash2.png"),
	preload("res://Drops/!Sprites/cash3.png"),
	preload("res://Drops/!Sprites/cash4.png"),
	preload("res://Drops/!Sprites/health_orb.png"),
	preload("res://Drops/!Sprites/coin.png")
]
const PLAYER_OFFSET := Vector2(0.0, -8.0)
const MOVE_SPEED := 3.0
const COLLECT_SPEED := 2.0
const MIN_RANGE := 5.0

const CASH_LIFESPAN := 9.0
const CASH_COLLECT_RADIUS := 700.0 # How far the player can pick up cash from (distanced is squared)
const CASH_XP_REWARD := 1.0
const HEALTH_LIFESPAN := 9.0
const HEALTH_COLLECT_RADIUS := 250.0
const HEALTH_XP_REWARD := 3.5
const COIN_LIFESPAN := 12.0
const COIN_COLLECT_RADIUS := 400.0
const COIN_XP_REWARD := 2.0

var drops := [] # Array of currently active drops
var rng := RandomNumberGenerator.new()
var player_ref # Set in GameController
var monocle_mode := false # moar money more monocle
var cape_mode := false
var hard_mode := false # hard hat
var drop_radius_multiplier := 1.0

onready var drop_flash_manager : Node2D = $DropFlashManager


func _ready():
	rng.randomize()
	drop_radius_multiplier *= Modifiers.collect_radius_multiplier


func _process(delta):
	var drops_to_delete := []
	# Process drops
	var player_pos : Vector2 = player_ref.position + PLAYER_OFFSET
	for i in drops.size():
		var drop : Drop = drops[i]
		if drop.current_state == state.MOVE:
			drop.lerp_weight += delta * ((1 - drop.lerp_weight) * MOVE_SPEED)
			drop.position = lerp(drop.spawn_position, drop.rest_position, drop.lerp_weight)
			if drop.position.distance_squared_to(drop.rest_position) < 2.0:
				drop.current_state = state.IDLE
		elif drop.current_state == state.IDLE:
			drop.lifespan -= delta
			if drop.lifespan < 0:
				Modifiers.drops_missed += 1
				drops_to_delete.append(drop)
				if monocle_mode:
					SignalBus.change_health(1.0, true)
			elif drop.lifespan < 4:
				if fmod(drop.lifespan, 0.8) < 0.4:
					drop.show = false
				else:
					drop.show = true
			if drop.position.distance_squared_to(player_pos) < drop.collect_radius:
				drop.current_state = state.COLLECT
				drop.show = true
				drop.lerp_weight = 0.0
		else: # COLLECT state
			drop.lerp_weight += delta * COLLECT_SPEED
			drop.position = lerp(drop.rest_position, player_pos, drop.lerp_weight)
			if drop.position.distance_squared_to(player_pos) < 5.0:
				if drop.type == type.CASH: # Collect events for each type
					SignalBus.change_cash(1)
					SignalBus.change_xp(CASH_XP_REWARD)
					if cape_mode:
						SignalBus.change_health(min(SignalBus.max_health / 150, 2.0) * -1)
				elif drop.type == type.HEALTH:
					SignalBus.change_health(min(-10.0, -SignalBus.max_health * 0.05))
					SignalBus.change_xp(HEALTH_XP_REWARD)
				elif drop.type == type.COIN:
					SignalBus.change_cash(5)
					SignalBus.change_xp(COIN_XP_REWARD)
				Modifiers.drops_collected += 1
				drops_to_delete.append(drop)
	# Delete drops
	for drop in drops_to_delete:
		drops.erase(drop)
	update()


func _draw():
	var flash_drops := [] # To be drawn by DropFlashManager
	for drop in drops:
		if drop.show:
			var drop_spr : StreamTexture = DROP_SPRITES[drop.sprite_index]
			draw_texture(drop_spr, drop.position - 
			Vector2(drop_spr.get_width() / 2.0, drop_spr.get_height() / 2.0))
		else:
			flash_drops.append(drop)
			pass
	drop_flash_manager.draw_drops(flash_drops)


func create_cash(pos: Vector2, num: int, drop_range := 20.0, direction := Vector2.ZERO):
	var amount := num
	var drop_radius = drop_range
	if monocle_mode:
		var bonus := randf()
		amount = max(round(amount * (0.75 + bonus)), amount)
		drop_radius *= 1.15
	if hard_mode:
		drop_radius *= max(1.0, 0.8 + randf())
	
	for i in amount:
		var offset := _create_offset(pos, drop_radius, direction)
		var rand := randf()
		if rand < 0.01 or (rand < 0.035 and SignalBus.health < 25.0):
			drops.append(Drop.new(type.HEALTH, pos, offset, HEALTH_LIFESPAN, 
			  HEALTH_COLLECT_RADIUS, 4))
		elif rand < 0.08 and Modifiers.coins_activated:
			drops.append(Drop.new(type.COIN, pos, offset, COIN_LIFESPAN, 
			  COIN_COLLECT_RADIUS * drop_radius_multiplier, 5))
		else:
			drops.append(Drop.new(type.CASH, pos, offset, CASH_LIFESPAN, 
			  CASH_COLLECT_RADIUS * drop_radius_multiplier, rng.randi_range(0, 3)))


func _create_offset(pos: Vector2, drop_range: float, direction : Vector2) -> Vector2:
	var offset := Vector2(randf()-.5, randf()-.5).normalized() * rand_range(1.0, drop_range)
	if direction == Vector2.DOWN:
		offset = Vector2(rng.randf_range(-0.3, 0.3), 1).normalized() * rand_range(4.0, drop_range)
	var result = get_world_2d().direct_space_state.intersect_ray(
		pos, pos + offset, [], 1)
	if result:
		offset = result.position - (offset.normalized() * 3.0)
	else:
		offset = pos + offset
	return offset
