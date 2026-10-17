class_name RunPreview
extends Control

@onready var screen_manager: Main = get_tree().current_scene 
@onready var run_manager: RunManager = $"../MainHud/RunManager"

@onready var scroll: ScrollContainer = %ScrollContainer
@onready var is_endless: CheckButton = %IsEndlessButton
@onready var sprite: StandardSprite = %StandardSprite

const SCROLL_STEP: float = 300.0

func _ready() -> void:
	run_manager.character_changed.connect(_on_character_changed)

	if run_manager.character_selected != null:
		_on_character_changed(run_manager.character_selected.id)
	
	for diff_node: Node in %HBoxContainer.get_children():
		var checkbox: CheckBox = diff_node.get_node("CheckBox")
		var diff_id: String = str(diff_node.get_meta("difficulty"))

		checkbox.toggled.connect(_on_difficulty_toggled.bind(diff_id))

func scroll_description(amount: float) -> void:
	var bar: VScrollBar = scroll.get_v_scroll_bar()
	scroll.scroll_vertical = clampi(
		scroll.scroll_vertical + int(amount),
		0,
		int(bar.max_value)
	)

func _on_difficulty_toggled(pressed: bool, diff_id: String) -> void:
	if !pressed:
		return

	screen_manager.change_difficulty(diff_id)

func _unhandled_input(event: InputEvent) -> void:
	if !visible: return
	
	if event.is_action_pressed("ui_cancel"):
		screen_manager.hide_run_preview()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if !visible: return
	
	if Input.is_action_pressed("scroll_down"):
		scroll_description(SCROLL_STEP * delta)

	if Input.is_action_pressed("scroll_up"):
		scroll_description(-SCROLL_STEP * delta)

func auto_button_select() -> void:
	if !is_visible_in_tree():
		return
	
	is_endless.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		call_deferred("auto_button_select")

func _on_start_run_pressed() -> void:
	screen_manager.start_run()

func _on_is_endless_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		screen_manager.set_endless(toggled_on)

func _on_texture_button_pressed() -> void:
	screen_manager.show_character_selection()

func _on_character_changed(id: String) -> void:
	sprite.set_character(id)
