extends Resource
class_name LevelData

export var starting_cash := 200
export var spawn_num_deviation := 0.15
export var spawn_time_deviation := 0.1
export var level_multiplier := 1.1 # increases XP requirement after each level up

export(AudioStream) var bg_music
export(Array, Resource) var mobs # Mob objects
export(Array, Resource) var maps # MapData objects
export(Array, Array, Vector3) var wave_spawns
# x: Spawn chance y: Average number of mobs to spawn, z: Average time between spawns
export(Array, float) var wave_lengths

export var has_boss := false
export(Resource) var boss_scene
export(Vector3) var boss_wave_spawns
# x: index of mob to spawn y: Initial time between spawns z: Spawn rate decrease per mob
# Set x to -1 for no spawns

var wave_data : WaveData

func generate_wave_data(rng: RandomNumberGenerator) -> void:
	var output : WaveData = WaveData.new()
	output.mob_list = mobs
	
	for wave_index in wave_spawns.size():
		var wave = wave_spawns[wave_index]
		var rand_max := 0.0
		for segment in wave:
			rand_max += segment.x
		var wave_list := []
		# Create wave segments
		for i in wave_lengths[wave_index]:
			# Select mob at random
			var rand := rand_range(0, rand_max)
			var counter := 0.0
			var new_segment := Vector3.ZERO
			for mob in wave.size():
				if wave[mob].x == 0.0:
					continue
				if rand < (counter + wave[mob].x):
					new_segment.x = mob
					break
				counter += wave[mob].x
			# Set amount of spawns & time between spawns
			var mean_amount := float(wave[new_segment.x].y)
			var mean_time := float(wave[new_segment.x].z)
			new_segment.y = max(1, round(rng.randfn(mean_amount, mean_amount * spawn_num_deviation)))
			new_segment.z = rng.randfn(mean_time, mean_time * spawn_time_deviation)
			wave_list.append(new_segment)
		output.timeline.append(wave_list)
	
	wave_data = output
