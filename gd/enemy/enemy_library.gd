extends Node

var all_enemies: Array[EnemyData]

func _ready() -> void:
	reload_enemies()

func reload_enemies() -> void:
	all_enemies.clear()
	_scan_folder("res://tres/enemies/")
	
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
	var directory: PackedStringArray = ResourceLoader.list_directory(folder_path)
	
	for file: String in directory:
		var path: String = folder_path.path_join(file)
		
		if file.ends_with("/"):
			_scan_folder(path)
		elif file.get_extension() in ["tres", "res"]:
			var resoure: Resource = ResourceLoader.load(path)
			
			if resoure is EnemyData:
				all_enemies.append(resoure)
