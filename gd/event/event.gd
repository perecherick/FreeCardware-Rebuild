class_name Event
extends Control

signal event_finished
signal start_event_combat(
	enemy: EnemyData,
	win_step: StringName,
	lose_step: StringName,
	condition_list: Array[EventCondition], 
	player_lose_move: EnemyMove
)

@export var event_data: EventData
@export var choice_button_scene: PackedScene

@onready var event_image: TextureRect = %EventImage
@onready var event_text: RichTextLabel = %RichTextLabel
@onready var choices_root: VBoxContainer = %Choices
@onready var custom_root: Control = %Custom

var player: PlayerState
var current_step: EventStep

var frame_timer: Timer
var current_frame: int = 0

var values: Dictionary[StringName, Variant]

func _ready() -> void:
	frame_timer = Timer.new()
	frame_timer.one_shot = false
	add_child(frame_timer)

	frame_timer.timeout.connect(_on_frame_timer_timeout)

	if event_data != null and player != null:
		_start_event()

func setup(player_state: PlayerState, data: EventData) -> void:
	player = player_state

	if data != null:
		event_data = data

	if is_node_ready():
		_start_event()

func _start_event() -> void:
	values.clear()
	
	current_step = null
	current_frame = 0
	frame_timer.stop()
	
	show_step(event_data.get_starting_step(player, self))

func show_step(step: EventStep) -> void:
	var previous_step: EventStep = current_step
	current_step = step

	_clear_custom()
	_clear_choices()

	step.apply_effects(player, self)
	event_text.text = _get_step_text(step)

	if step.custom_scene != null:
		frame_timer.stop()
		event_image.hide()

		var custom_view: Control = step.custom_scene.instantiate()
		custom_root.add_child(custom_view)

		if custom_view.has_method("setup"):
			custom_view.setup(player)
	else:
		event_image.show()

		if !_is_same_animation(previous_step, step):
			_show_step_animation(step)

	_show_step_choices(step)
	step.play_event_audio()

func _is_same_animation(
	first: EventStep,
	second: EventStep
) -> bool:
	if first == null or second == null:
		return false
	
	if first.frames.size() != second.frames.size():
		return false
	
	if first.fps != second.fps:
		return false
	
	if first.loop != second.loop:
		return false
	
	for i: int in first.frames.size():
		if first.frames[i] != second.frames[i]:
			return false
	
	return true

func _show_step_animation(step: EventStep) -> void:
	frame_timer.stop()
	current_frame = 0
	
	if step.frames.is_empty():
		event_image.texture = null
		return
	
	event_image.texture = step.frames[0]
	
	if step.frames.size() == 1:
		return
	
	if step.fps <= 0.0:
		DebugLogger.error(
			"Event step '%s' has invalid FPS: %s"
			% [step.id, step.fps]
		)
		return
	
	frame_timer.wait_time = 1.0 / step.fps
	frame_timer.start()

func _on_frame_timer_timeout() -> void:
	if current_step == null:
		DebugLogger.error("Frame timer running without current EventStep")
		frame_timer.stop()
		return
	
	if current_step.frames.is_empty():
		DebugLogger.error(
			"Frame timer running on EventStep '%s' without frames"
			% current_step.id
		)
		frame_timer.stop()
		return
	
	current_frame += 1
	
	if current_frame >= current_step.frames.size():
		if current_step.loop:
			current_frame = 0
		else:
			current_frame = current_step.frames.size() - 1
			frame_timer.stop()
			return
	
	event_image.texture = current_step.frames[current_frame]

func _show_step_choices(step: EventStep) -> void:
	_clear_choices()

	if choice_button_scene == null:
		DebugLogger.error("Choice button scene is null")
		return

	for choice: EventChoice in step.choices:
		if choice == null:
			DebugLogger.error(
				"Event step '%s' contains null choice"
				% step.id
			)
			continue

		var button: EventChoiceButton = choice_button_scene.instantiate()

		choices_root.add_child(button)

		button.setup(choice, player, self)
		button.choice_selected.connect(_on_choice_selected)

func _clear_choices() -> void:
	for child: Node in choices_root.get_children():
		child.queue_free()

func _clear_custom() -> void:
	for child: Node in custom_root.get_children():
		child.queue_free()

func _on_choice_selected(choice: EventChoice) -> void:
	choice.apply_effects(player, self)

	if choice.finish_event:
		_finish_event()
		return

	var next_step_id: StringName = choice.get_next_step(player, self)

	if !next_step_id.is_empty():
		var next_step: EventStep = event_data.get_step(next_step_id)

		if next_step == null:
			DebugLogger.error(
				"Step '%s' not found in event '%s'"
				% [next_step_id, event_data.id]
			)
			return

		show_step(next_step)
		return

	_show_step_choices(current_step)

func _finish_event() -> void:
	frame_timer.stop()
	event_finished.emit()

func _on_event_image_gui_input(event: InputEvent) -> void:
	if current_step == null:
		return

	if !current_step.choices.is_empty():
		return

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event

		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return

		if !mouse_event.pressed:
			return

		var next_step_id: StringName = current_step.get_next_step(player, self)

		if next_step_id.is_empty():
			_finish_event()
			return

		go_to_step(next_step_id)

func go_to_step(step_id: StringName) -> void:
	var next_step: EventStep = event_data.get_step(step_id)

	if next_step == null:
		DebugLogger.error(
			"Step '%s' not found in event '%s'"
			% [step_id, event_data.id]
		)
		return

	show_step(next_step)

func set_value(key: StringName, value: Variant) -> void:
	values[key] = value

func get_value(key: StringName, default: Variant = null) -> Variant:
	return values.get(key, default)

func _get_step_text(step: EventStep) -> String:
	var text: String = tr(step.text)
	
	var hardware: HardwareData = get_value(&"hardware")
	var result: String = get_value(&"result", "")
	
	if hardware != null:
		text = text.format({
			"hardware": tr(hardware.name),
			"hardware_desc": tr(hardware.description)
		})
	
	if !result.is_empty():
		text = text.format({
			"result": tr(result)
		})
	
	return text

func start_combat(
	enemy: EnemyData,
	win_step: StringName,
	lose_step: StringName,
	condition_list: Array[EventCondition],
	player_lose_move: EnemyMove
) -> void:
	start_event_combat.emit(
		enemy,
		win_step,
		lose_step,
		condition_list, 
		player_lose_move
	)
