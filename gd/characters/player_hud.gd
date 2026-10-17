# I hate everyone, i hate everything, i hate myself
# because of [censored] i don't have a future, and no one can
# protect my future, even myself
# i don't know my guy, the only thing is keeping me alive
# for now is only this game, if i don't have any future then
# why would i live? what's the fucking point? 
# i don't even can fucking believe in what time i live, no
# seriously, this is fucking horrible, i don't even know how 
# to properly and truthfully describe it, cause it's not my
# native language, and the fuck anyone would read ts
# just nwm this class is about rendering player's stats, sprite,
# hardware ect.
extends Control

@onready var hp_label: Label = %HP
@onready var lp_label: Label = %LP
@onready var gold_label: Label = %GOLD
@onready var hardware_list: RichTextLabel = %HardwareList
@onready var description_container: MarginContainer = %MarginContainer
@onready var description: Label = %Description
@onready var sprite: Node2D = $"PlayerSprite/VisualRoot/StandartSprite"

var player_state: PlayerState

func setup_preview(character: CharacterData) -> void:
	_on_hp_changed(character.max_hp, character.max_hp)
	_on_lp_changed(0, character.max_lp)
	_on_gold_changed(0)
	_update_hardware_list(character.starting_hardware)

func setup(player: PlayerState) -> void:
	player_state = player
	player_state.hp_changed.connect(_on_hp_changed)
	player_state.lp_changed.connect(_on_lp_changed)
	player_state.gold_changed.connect(_on_gold_changed)
	player_state.hardware_changed.connect(_on_hardware_changed)
	_on_hp_changed(player.hp, player.max_hp)
	_on_lp_changed(player.lp, player.max_lp)
	_on_gold_changed(player.gold)
	_update_hardware_list(player.hardware)
	# TODO: fucking remove this shit i hate godot
	Input.set_custom_mouse_cursor(
		preload("res://img/main/custom_cursor.png"),
		Input.CURSOR_POINTING_HAND
	)
	sprite.set_character(player.character.id)

@warning_ignore("shadowed_global_identifier")
func _on_hp_changed(current: int, max: int) -> void:
	hp_label.text = "%d/%dHP" % [current, max]
	DebugLogger.info(
		"HP changed: %d / %d"
		% [current, max]
	)

@warning_ignore("shadowed_global_identifier")
func _on_lp_changed(current: int, max: int) -> void:
	lp_label.text = "%d/%dLP" % [current, max]
	DebugLogger.info(
		"LP changed: %d / %d"
		% [current, max]
	)

func _on_gold_changed(amount: int) -> void:
	gold_label.text = "%dG" % amount
	DebugLogger.info(
		"Gold changed: %d" 
		% amount
	)

func _update_hardware_list(hardwares: Array[HardwareData]) -> void:
	hardware_list.clear()

	var counts: Dictionary = {}
	var unique_hardware: Array[HardwareData] = []

	for hardware: HardwareData in hardwares:
		if hardware == null:
			continue

		if hardware.id in counts:
			counts[hardware.id] += 1
		else:
			counts[hardware.id] = 1
			unique_hardware.append(hardware)

	for hardware: HardwareData in unique_hardware:
		_append_hardware(
			hardware,
			counts[hardware.id]
		)

func _append_hardware(
	hardware: HardwareData,
	count: int = 1
) -> void:
	hardware_list.push_meta(
		hardware,
		RichTextLabel.META_UNDERLINE_NEVER
	)
	hardware_list.push_color(Color(hardware.color))

	hardware_list.add_text(tr(hardware.name))

	if count > 1:
		hardware_list.add_text(" x%d" % count)

	hardware_list.pop()
	hardware_list.pop()
	hardware_list.add_text(" ")

@warning_ignore("unused_parameter")
func _on_hardware_list_meta_hover_ended(meta: Variant) -> void:
	description_container.visible = false
	description.text = ""

func _on_hardware_list_meta_hover_started(meta: Variant) -> void:
	var hardware: HardwareData = meta
	
	if hardware == null: return

	description_container.visible = true
	description.text = tr(hardware.description)

func _on_hardware_changed() -> void:
	_update_hardware_list(player_state.hardware)
