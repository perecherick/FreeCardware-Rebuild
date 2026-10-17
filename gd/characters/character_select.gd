extends Control

signal hide_character_selection

@export var character_scene: PackedScene
@export var card_scene: PackedScene

@onready var container: HBoxContainer = %CharContainer
@onready var run_manager: RunManager = $"../MainHud/RunManager"
@onready var sprite: Node2D = $"PlayerHud/PlayerSprite/VisualRoot/StandartSprite"
@onready var hud: Control = $"PlayerHud"
@onready var grid: GridContainer = %GridContainer

const CHAR_PATH: String = "res://tres/character/"

var characters: Array[CharacterData]
var preview_char: CharacterData

func _ready() -> void:
	_load_characters()
	var generated_count: int = 0

	for character: CharacterData in characters:
		var btn: Control = character_scene.instantiate()

		container.add_child(btn)
		btn.call("setup", character)
		btn.connect("selected", character_preview)
		generated_count += 1

	DebugLogger.info(
		"Character selection ready: %d/%d buttons"
		% [generated_count, characters.size()]
	)
	
	var saved_character: CharacterData = get_character(SettingsPreload.character)

	if saved_character != null:
		character_preview(saved_character)
		_prepare_starting_deck(saved_character.starting_deck)
		run_manager.select_character(saved_character)

func _load_characters() -> void:
	characters.clear()
	
	for file_name: String in ResourceLoader.list_directory(CHAR_PATH):
		var resource: Resource = load(CHAR_PATH + file_name)
		
		characters.append(resource)
	
	characters.sort_custom(
		func(a: CharacterData, b: CharacterData) -> bool:
			return a.order < b.order
	)

func character_preview(character: CharacterData) -> void:
	if character == null:
		DebugLogger.warning("Character selection emitted null data")
		return
	
	hud.setup_preview(character)
	sprite.set_character(character.id)
	_prepare_starting_deck(character.starting_deck)
	preview_char = character

func _select_character() -> void:
	if preview_char == null:
		return

	run_manager.select_character(preview_char)
	SettingsPreload.character = preview_char.id
	SettingsPreload.save_character()
	hide_character_selection.emit()

func get_character(id: String) -> CharacterData:
	for character: CharacterData in characters:
		if character != null and character.id == id:
			return character

	DebugLogger.warning("Character not found: %s" % id)
	return characters[0] if !characters.is_empty() else null

func _prepare_starting_deck(cards: Array[CardData]) -> void:
	clear_grid()
	for card: CardData in cards:
		var card_data: CardView = card_scene.instantiate()
		grid.add_child(card_data)
		card_data.setup(card, 1.25)

func clear_grid() -> void:
	for child: Node in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()
