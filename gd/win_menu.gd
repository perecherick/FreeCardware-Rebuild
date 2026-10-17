extends Control

signal go_to_main_menu

func _on_button_pressed() -> void:
	hide()
	go_to_main_menu.emit()
