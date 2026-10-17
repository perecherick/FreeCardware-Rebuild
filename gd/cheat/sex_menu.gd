class_name SexMenu
extends Control

@onready var sex_vbox: VBoxContainer = %VBoxContainer
@onready var timer: Timer = $Timer

var player: PlayerState
var current_sex: SexData

func setup() -> void:
	var stop_button: Button = Button.new()
	stop_button.text = "STOP"
	stop_button.add_theme_font_size_override("font_size", 24)
	stop_button.add_theme_font_override("font", preload("res://fonts/ark-pixel-12px-proportional-latin.ttf"))
	stop_button.pressed.connect(_stop_sex_timer)
	sex_vbox.add_child(stop_button)
	
	var sex_list: Array[SexData] = SexLibrary.sex_list.duplicate()
	sex_list.sort_custom(
		func (a: SexData, b: SexData) -> bool:
			return String(a.id).nocasecmp_to(String(b.id)) < 0
	)
	
	for sex: SexData in sex_list:
		var button: Button = Button.new()
		button.text = sex.id.capitalize()
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_font_override("font", preload("res://fonts/ark-pixel-12px-proportional-latin.ttf"))
		button.pressed.connect(_on_button_pressed.bind(sex))
		sex_vbox.add_child(button)

func setup_player(player_state: PlayerState) -> void:
	player = player_state

func _on_button_pressed(sex: SexData) -> void:
	current_sex = sex
	player.apply_sex(sex, 1)
	timer.start()

func _stop_sex_timer() -> void:
	timer.stop()
	current_sex = null
	player.exit_sex()

func _on_timer_timeout() -> void:
	if !player.in_sex:
		timer.stop()
		return
	player.change_sex_state(1)
