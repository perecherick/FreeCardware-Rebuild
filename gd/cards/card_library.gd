extends Node

const CARDS_FOLDER: String = "res://tres/cards"

var all_cards: Array[CardData]

func _ready() -> void:
	_scan_folder(CARDS_FOLDER)

	DebugLogger.info(
		"Card library loaded: %d cards"
		% all_cards.size()
	)

func get_reward_pool(
	reward_pool: CardData.CardType
) -> Array[CardData]:
	var result: Array[CardData] = []

	for card: CardData in all_cards:
		if card.card_type == reward_pool:
			result.append(card)

	return result

func _scan_folder(folder_path: String) -> void:
	var directory: DirAccess = DirAccess.open(folder_path)

	directory.list_dir_begin()

	var file_name: String = directory.get_next()

	while !file_name.is_empty():
		var full_path: String = folder_path.path_join(file_name)

		if directory.current_is_dir():
			if !file_name.begins_with("."):
				_scan_folder(full_path)

		elif file_name.get_extension() in ["tres", "res"]:
			var resource: Resource = load(full_path)

			if resource is CardData:
				all_cards.append(resource)

		file_name = directory.get_next()

	directory.list_dir_end()
