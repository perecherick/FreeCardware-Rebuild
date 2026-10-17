class_name MapGenerator
extends Node

const MAP_WIDTH: int = 7
const PATH_COUNT: int = 6
const BOSS_COLUMN: int = 3

const RUN_CONFIG: Dictionary = {
	"normal": {
		"normal": {
			"map_height": 18,
			"mini_boss_from": 3,
			"mini_boss_chance": 5,
			"enemy_hp_multiplier": 1.0,
			"enemy_pp_multiplier": 1.0,
			"reward_multiplier": 1.0,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": []
				},
				2: {
					"minimum": 1,
					"extra_chances": [25]
				},
				3: {
					"minimum": 1,
					"extra_chances": [40, 15]
				}
			}
		},
		"hard": {
			"map_height": 20,
			"mini_boss_from": 2,
			"mini_boss_chance": 8,
			"enemy_hp_multiplier": 1.0,
			"enemy_pp_multiplier": 1.0,
			"reward_multiplier": 1.0,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": []
				},
				2: {
					"minimum": 1,
					"extra_chances": [40]
				},
				3: {
					"minimum": 1,
					"extra_chances": [65, 30]
				}
			}
		},
		"insane": {
			"map_height": 22,
			"mini_boss_from": 2,
			"mini_boss_chance": 12,
			"enemy_hp_multiplier": 1.2,
			"enemy_pp_multiplier": 1.2,
			"reward_multiplier": 0.75,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": [25]
				},
				2: {
					"minimum": 1,
					"extra_chances": [65, 30]
				},
				3: {
					"minimum": 2,
					"extra_chances": [50]
				}
			}
		}
	},
	"pure": {
		"normal": {
			"map_height": 20,
			"mini_boss_from": 3,
			"mini_boss_chance": 5,
			"enemy_hp_multiplier": 1.0,
			"enemy_pp_multiplier": 1.0,
			"reward_multiplier": 1.0,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": []
				},
				2: {
					"minimum": 1,
					"extra_chances": [25]
				},
				3: {
					"minimum": 1,
					"extra_chances": [40, 15]
				}
			}
		},
		"hard": {
			"map_height": 22,
			"mini_boss_from": 2,
			"mini_boss_chance": 8,
			"enemy_hp_multiplier": 1.0,
			"enemy_pp_multiplier": 1.0,
			"reward_multiplier": 1.0,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": []
				},
				2: {
					"minimum": 1,
					"extra_chances": [40]
				},
				3: {
					"minimum": 1,
					"extra_chances": [65, 30]
				}
			}
		},
		"insane": {
			"map_height": 24,
			"mini_boss_from": 2,
			"mini_boss_chance": 12,
			"enemy_hp_multiplier": 1.15,
			"enemy_pp_multiplier": 1.15,
			"reward_multiplier": 0.75,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": [25]
				},
				2: {
					"minimum": 1,
					"extra_chances": [65, 30]
				},
				3: {
					"minimum": 2,
					"extra_chances": [50]
				}
			}
		}
	},
	"lewd": {
		"normal": {
			"map_height": 20,
			"mini_boss_from": 3,
			"mini_boss_chance": 5,
			"enemy_hp_multiplier": 1.0,
			"enemy_pp_multiplier": 1.0,
			"reward_multiplier": 1.0,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": []
				},
				2: {
					"minimum": 1,
					"extra_chances": [25]
				},
				3: {
					"minimum": 1,
					"extra_chances": [40, 15]
				}
			}
		},
		"hard": {
			"map_height": 22,
			"mini_boss_from": 2,
			"mini_boss_chance": 8,
			"enemy_hp_multiplier": 1.0,
			"enemy_pp_multiplier": 1.0,
			"reward_multiplier": 1.0,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": []
				},
				2: {
					"minimum": 1,
					"extra_chances": [40]
				},
				3: {
					"minimum": 1,
					"extra_chances": [65, 30]
				}
			}
		},
		"insane": {
			"map_height": 24,
			"mini_boss_from": 2,
			"mini_boss_chance": 12,
			"enemy_hp_multiplier": 1.15,
			"enemy_pp_multiplier": 1.15,
			"reward_multiplier": 0.75,
			
			"enemy_groups": {
				1: {
					"minimum": 1,
					"extra_chances": [25]
				},
				2: {
					"minimum": 1,
					"extra_chances": [65, 30]
				},
				3: {
					"minimum": 2,
					"extra_chances": [50]
				}
			}
		}
	}
}

const LOCATIONS_CHANCES: Dictionary = {
	"enemy": 50,
	"event": 35,
	"rest": 10,
	"shop": 5
}

@warning_ignore("unused_parameter")
func generate_map_data(run_mode: String, difficulty: String, act: int) -> Dictionary:
	var paths: Array = generate_paths(run_mode, difficulty)

	return {
		"paths": paths,
		"height": get_map_height_from_paths(paths),
		"points": get_unique_points_from_paths(paths),
		"connections": build_connections(paths),
		"boss_type": get_random_boss_type(),
	}

func generate_paths(run_mode: String, difficulty: String) -> Array:
	var config: Dictionary = RUN_CONFIG[run_mode][difficulty]
	var map_height: int = config["map_height"] - 1

	var result: Array = []

	for i in range(PATH_COUNT):
		result.append(generate_single_path(map_height))

	return result

func generate_single_path(map_height: int) -> Array:
	var path: Array = []
	var column: int = randi_range(0, MAP_WIDTH - 1)

	path.append([0, column])

	@warning_ignore("shadowed_global_identifier")
	for floor in range(1, map_height + 1):
		column = get_next_column(column, floor, map_height)
		path.append([floor, column])

	path.append([map_height + 1, BOSS_COLUMN])

	return path

@warning_ignore("shadowed_global_identifier")
func get_next_column(column: int, floor: int, map_height: int) -> int:
	var step: int

	if floor >= map_height - 3:
		if column < BOSS_COLUMN:
			step = randi_range(0, 1)
		elif column > BOSS_COLUMN:
			step = randi_range(-1, 0)
		else:
			step = randi_range(-1, 1)
	else:
		step = randi_range(-1, 1)

	return clampi(column + step, 0, MAP_WIDTH - 1)

func get_map_height_from_paths(paths_to_check: Array) -> int:
	var max_floor: int = 0

	for path in paths_to_check:
		for point in path:
			max_floor = maxi(max_floor, int(point[0]))

	return max_floor

func get_unique_points_from_paths(paths_to_check: Array) -> Array:
	var result: Array = []

	for path in paths_to_check:
		for point in path:
			if !result.has(point):
				result.append(point)

	return result

@warning_ignore("shadowed_global_identifier")
func generate_location_type(
	floor: int,
	act_number: int,
	difficulty: String,
	mode: String,
	boss_floor: int
) -> String:
	var shop_floor: int = boss_floor - 2
	@warning_ignore("integer_division")
	var hardware_floor: int = boss_floor / 2
	var location_roll: int = randi_range(1, 100)
	var miniboss_roll: int = randi_range(1, 100)

	var config: Dictionary = RUN_CONFIG[mode][difficulty]
	var loc_chance: Dictionary = LOCATIONS_CHANCES

	var enemy_end: int = int(loc_chance["enemy"])
	var event_end: int = enemy_end + int(loc_chance["event"])
	var rest_end: int = event_end + int(loc_chance["rest"])

	match floor:
		0:
			return "enemy"
		boss_floor:
			return "boss"
		shop_floor:
			return "shop"
		hardware_floor:
			return "hardware"
		_:
			if act_number >= int(config["mini_boss_from"]):
				if miniboss_roll <= int(config["mini_boss_chance"]):
					return "mini_boss"
			if location_roll <= enemy_end:
				return "enemy"
			elif location_roll <= event_end:
				return "event"
			elif location_roll <= rest_end:
				return "rest"
			else:
				return "shop"

func get_random_boss_type() -> String:
	return "dragon" if randi_range(0, 1) == 0 else "cat"

func build_connections(generated_paths: Array) -> Dictionary:
	var result: Dictionary = {}

	for path in generated_paths:
		for index in range(path.size() - 1):
			var from: Vector2i = Vector2i(path[index][0], path[index][1])
			var to: Vector2i = Vector2i(path[index + 1][0], path[index + 1][1])

			if !result.has(from):
				result[from] = {}

			result[from][to] = true

	return result

func get_config(mode: String, difficulty: String) -> Dictionary:
	if !RUN_CONFIG.has(mode):
		DebugLogger.error("Unknown mode: %s" % mode)
		return {}

	var mode_config: Dictionary = RUN_CONFIG[mode]

	if !mode_config.has(difficulty):
		DebugLogger.error("Unknown difficulty: %s" % difficulty)
		return {}

	return mode_config[difficulty]
