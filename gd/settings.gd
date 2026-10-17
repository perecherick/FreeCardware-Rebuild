extends Control

signal show_credits
signal show_debug_menu
signal hide_debug_menu

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var SFX_slider: HSlider = %SFXSlider
@onready var sex_slider: HSlider = %SexSlider
@onready var screen_mode: OptionButton = %ScreenModeButton
@onready var screen_size: OptionButton = %ScreenSizeButton
@onready var language_button: OptionButton = %LanguageSelectButton
@onready var discord_button: CheckButton = %DiscordButton

func _ready() -> void:
	apply_settings_to_ui()

func apply_settings_to_ui() -> void:
	master_slider.set_value_no_signal(SettingsPreload.master_volume_value)
	music_slider.set_value_no_signal(SettingsPreload.music_volume_value)
	SFX_slider.set_value_no_signal(SettingsPreload.sfx_volume_value)
	sex_slider.set_value_no_signal(SettingsPreload.sex_volume_value)
	screen_mode.select(SettingsPreload.screen_mode)
	if SettingsPreload.screen_mode != 1:
		screen_size.disabled = false
		screen_size.select(SettingsPreload.screen_size)
	language_button.select(SettingsPreload.locale)
	discord_button.set_pressed_no_signal(SettingsPreload.discord_activity)

func _on_credits_button_pressed() -> void:
	show_credits.emit()
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_button_pressed()

func _on_master_slider_value_changed(value: float) -> void:
	SettingsPreload.master_volume_value = value
	SettingsPreload.apply_audio()

func _on_music_slider_value_changed(value: float) -> void:
	SettingsPreload.music_volume_value = value
	SettingsPreload.apply_audio()
	
func _on_sfx_slider_value_changed(value: float) -> void:
	SettingsPreload.sfx_volume_value = value
	SettingsPreload.apply_audio()

func _on_sex_slider_value_changed(value: float) -> void:
	SettingsPreload.sex_volume_value = value
	SettingsPreload.apply_audio()

func _on_screen_mode_button_item_selected(index: int) -> void:
	SettingsPreload.screen_mode = index
	SettingsPreload.apply_screen_mode()
	if index == 1:
		screen_size.disabled = true
	else:
		screen_size.disabled = false

func _on_screen_size_button_item_selected(index: int) -> void:
	SettingsPreload.screen_size = index
	SettingsPreload.apply_screen_size()

func _on_language_select_button_item_selected(index: int) -> void:
	SettingsPreload.locale = index
	SettingsPreload.apply_locale(SettingsPreload.locale)
	DiscordActivity.update_activity()

func _on_back_button_pressed() -> void:
	SettingsPreload.save_settings()
	hide()

func _on_cheats_line_edit_text_changed(new_text: String) -> void:
	match new_text:
		"jelly": show_debug_menu.emit()
		"gelbana": hide_debug_menu.emit()
		_: hide_debug_menu.emit()

func auto_button_select() -> void:
	if !is_visible_in_tree():
		return
	
	master_slider.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		call_deferred("auto_button_select")

func _on_check_button_toggled(toggled_on: bool) -> void:
	SettingsPreload.discord_activity = toggled_on
	if toggled_on:
		DiscordActivity.start_activity()
		DiscordActivity.set_status("TID_MAIN_MENU")
	else:
		DiscordActivity.kill_activity()
