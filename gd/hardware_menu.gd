class_name HardwareMenu
extends Control

@onready var hardware_root: VBoxContainer = %VBoxContainer

var player: PlayerState
var buttons: Dictionary[HardwareData, Button]

func setup() -> void:
	var hardware_list: Array[HardwareData] = HardwareLibrary.hardware_list.duplicate()
	hardware_list.sort_custom(
		func(a: HardwareData, b: HardwareData) -> bool:
			return String(a.id).nocasecmp_to(String(b.id)) < 0
	)
	
	for hardware: HardwareData in hardware_list:
		var button: Button = Button.new()
		
		buttons[hardware] = button
		button.text = hardware.id.capitalize()
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_font_override("font", preload("res://fonts/ark-pixel-12px-proportional-latin.ttf"))
		button.focus_mode = Control.FOCUS_ALL
		if hardware.stackable:
			button.tooltip_text = tr("TID_HARDWARE_HOVER_TOOLTIP")
			button.button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT
			button.gui_input.connect(_on_hardware_input.bind(hardware))
		else:
			button.pressed.connect(_on_hardware_pressed.bind(hardware))
		
		hardware_root.add_child(button)

func setup_player(player_state: PlayerState) -> void:
	player = player_state
	
	for hardware: HardwareData in buttons:
		buttons[hardware].text = _update_button_text(hardware)

func _on_hardware_pressed(hardware: HardwareData) -> void:
	if hardware.stackable:
		if MouseButton.MOUSE_BUTTON_LEFT:
			player.add_hardware(hardware)
		elif MouseButton.MOUSE_BUTTON_RIGHT:
			player.remove_all_hardware(hardware.id)
	else:
		if player.has_hardware(hardware.id):
			player.remove_hardware(hardware.id)
		else:
			player.add_hardware(hardware)
	buttons[hardware].text = _update_button_text(hardware)

func _on_hardware_input(event: InputEvent, hardware: HardwareData) -> void:
	if !event.is_pressed(): return
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				player.add_hardware(hardware)
			MOUSE_BUTTON_MIDDLE:
				player.remove_all_hardware(hardware.id)
			MOUSE_BUTTON_RIGHT:
				player.remove_hardware(hardware.id)
			_:
				return
	elif event is InputEventKey:
		match event.keycode:
			KEY_ENTER:
				player.add_hardware(hardware)
			KEY_DELETE:
				player.remove_all_hardware(hardware.id)
			KEY_BACKSPACE:
				player.remove_hardware(hardware.id)
			_:
				return
	
	buttons[hardware].text = _update_button_text(hardware)

func _update_button_text(hardware: HardwareData) -> String:
	var hardware_name: String = hardware.id.capitalize()
	var hardware_status: String = "Obtained" if player.has_hardware(hardware.id) else "Not obtained"
	var hardware_count: String = ""
	
	if hardware.stackable:
		hardware_count = " | Count: %d" % player.get_hardware_count(hardware.id)
	
	return hardware_name + " | " + hardware_status + hardware_count
