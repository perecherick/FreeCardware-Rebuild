extends Node

const ENEMIES_FOLDER: String = "res://tres/enemies"

var all_enemies: Array[EnemyData] = []

func _ready() -> void:
	reload_enemies()

func reload_enemies() -> void:
	all_enemies.clear()
	_scan_folder(ENEMIES_FOLDER)

	DebugLogger.info(
		"Enemy library loaded: %d enemies"
		% all_enemies.size()
	)

func get_pool(
	pool: EnemyData.EnemyType
) -> Array[EnemyData]:
	var result: Array[EnemyData] = []

	for enemy: EnemyData in all_enemies:
		if enemy.type == pool:
			result.append(enemy)

	return result

func _scan_folder(folder_path: String) -> void:
	var directory: DirAccess = DirAccess.open(folder_path)
	
	directory.list_dir_begin()

	var file_name: String = directory.get_next()

	while !file_name.is_empty():
		var path: String = folder_path.path_join(file_name)

		if directory.current_is_dir():
			if !file_name.begins_with("."):
				_scan_folder(path)

		elif file_name.get_extension() in ["tres", "res"]:
			var resource: Resource = ResourceLoader.load(path)

			if resource is EnemyData:
				all_enemies.append(resource)

		file_name = directory.get_next()

	directory.list_dir_end()
