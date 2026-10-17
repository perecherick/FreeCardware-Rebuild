# i hate this shit its driving me fucking crazy
class_name MapLocation
extends Control

@onready var visuals: MapVisuals = %Visual

signal selected(point: Vector2i)

var location_type: String = "enemy"
var boss_type: String = ""
var is_valid: bool = false
var map_point: Vector2i

func setup(
	new_type: String,
	new_boss_type: String,
	new_is_valid: bool,
	new_point: Vector2i
) -> void:
	location_type = new_type
	boss_type = new_boss_type
	is_valid = new_is_valid
	map_point = new_point

	visuals.setup(location_type, boss_type, is_valid)
	set_valid(new_is_valid)

func _gui_input(event: InputEvent) -> void:
	if !is_valid:
		return

	var is_left_click: bool = (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	)

	var is_accept: bool = event.is_action_pressed("ui_accept")

	if !is_left_click and !is_accept:
		return

	visuals.set_selected(true)
	selected.emit(map_point)
	accept_event()

func set_valid(value: bool) -> void:
	is_valid = value
	focus_mode = Control.FOCUS_ALL if value else Control.FOCUS_NONE

	if !value and has_focus():
		release_focus()

	visuals.set_valid(value)

func _on_mouse_entered() -> void:
	if is_valid:
		grab_focus()
	else:
		visuals.set_hovered(true)

func _on_mouse_exited() -> void:
	visuals.set_hovered(false)

func _on_focus_entered() -> void:
	visuals.set_hovered(true)

func _on_focus_exited() -> void:
	visuals.set_hovered(false)
