extends Control

@onready var screen_manager: Main = get_tree().current_scene as Main

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

	if visible:
		call_deferred("focus_first_menu_button")

func _on_visibility_changed() -> void:
	if visible:
		call_deferred("focus_first_menu_button")

func focus_first_menu_button() -> void:
	if !is_visible_in_tree():
		return

	if !%ContinueRun.disabled:
		%ContinueRun.grab_focus()
	else:
		%NewRun.grab_focus()

func _on_options_pressed() -> void:
	screen_manager.toggle_settings()

func _on_quit_pressed() -> void:
	screen_manager.quit_game()

func _on_new_run_pressed() -> void:
	screen_manager.choose_difficulty()
