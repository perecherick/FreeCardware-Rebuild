extends Control

@onready var screen_manager: Main = get_tree().current_scene as Main

@onready var normal_button: Button = %NormalBtn

# When all loaded gets a string meta from vbox and conntects it
# to image and normal button and also connects to them 
# _on_run_pressed function
func _ready() -> void:
	for group: VBoxContainer in %GameModes.get_children():
		var run_dif: String = str(group.get_meta("run_dif"))
		
		for child: BaseButton in group.get_children():
			if child is BaseButton:
				child.pressed.connect(_on_run_pressed.bind(run_dif))

func _on_run_pressed(run_dif: String) -> void:
	screen_manager.show_run_preview(run_dif)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		screen_manager.hide_choose_difficulty()
		get_viewport().set_input_as_handled()

func auto_button_select() -> void:
	if !is_visible_in_tree():
		return
	
	normal_button.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		call_deferred("auto_button_select")
