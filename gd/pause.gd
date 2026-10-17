extends Control

@onready var screen_manager: Main = get_tree().current_scene as Main

@onready var continue_btn: Button = %Continue

func _on_continue_pressed() -> void:
	screen_manager.toggle_pause_menu_visible()

func _on_main_menu_pressed() -> void:
	screen_manager.show_main_menu()

func _on_options_pressed() -> void:
	screen_manager.toggle_settings()
	screen_manager.toggle_pause_menu_visible()

func _on_quit_pressed() -> void:
	screen_manager.quit_game()

func _on_visibility_changed() -> void:
	if visible:
		call_deferred("auto_button_select")

func auto_button_select() -> void:
	if !is_visible_in_tree():
		return
	
	continue_btn.grab_focus()
