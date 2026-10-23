#My ass is so fucking stupid i cant believe i accually put in
#_ready TranslationServer.set_locale("en") and fucking coundnt understand
#why the fuck language didnt changing from config
extends Node
class_name Main

@onready var main_menu: Control = $MainMenu
@onready var settings: Control = $Settings
@onready var credits: Control = $Credits
@onready var debug_menu: CheatMenu = $DebugMenu
@onready var debug_menu_buttons: Control = $DebugMenu/DebugMenu
@onready var new_game: Control = $NewGame
@onready var run_preview: Control = $RunPreview
@onready var run_preview_image: TextureRect = $RunPreview/HBoxContainer/DifficultyImage
@onready var run_preview_label: Label = $RunPreview/HBoxContainer/VBoxContainer/RunPreviewLabel
@onready var run_preview_description: Label = $RunPreview/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/RunPreviewDescription
@onready var run_preview_diff_description: Label = $RunPreview/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/RunPreviewDiffDecription
@onready var main_hud: Control = $MainHud
@onready var pause_menu: Control = $MainHud/Pause
@onready var run_manager: RunManager = $MainHud/RunManager
@onready var character_selection: Control = $CharacterSelect
@onready var loss_menu: Control = $MainHud/LossMenu
@onready var win_menu: Control = $MainHud/WinMenu
@onready var player_sprite: PlayerSprite = $MainHud/PlayerHud/PlayerSprite

func _ready() -> void:
	if OS.is_debug_build():
		debug_menu.show()
	
	loss_menu.go_to_main_menu.connect(show_main_menu)
	main_hud.pause.connect(toggle_pause_menu_visible)
	character_selection.hide_character_selection.connect(hide_character_selection)
	settings.show_credits.connect(show_credits)
	settings.show_debug_menu.connect(show_debug_menu)
	settings.hide_debug_menu.connect(hide_debug_menu)
	credits.show_settings.connect(toggle_settings)
	win_menu.go_to_main_menu.connect(show_main_menu)
	debug_menu.event_requested.connect(run_manager.open_debug_event)
	run_manager.run_started.connect(debug_menu.setup_player)
	debug_menu.setup()
	
	if SettingsPreload.discord_activity:
		DiscordActivity.start_activity()
		DiscordActivity.set_status("TID_MAIN_MENU")

# Buttons funcs
func toggle_settings() -> void:
	settings.visible = !settings.visible

func show_main_menu() -> void:
	settings.visible = false
	debug_menu_buttons.visible = false
	main_hud.visible = false
	pause_menu.visible = false
	main_menu.visible = true
	DiscordActivity.set_status("TID_MAIN_MENU")
	AudioManager.play_music(&"main_menu")

func show_credits() -> void:
	credits.visible = true

func show_debug_menu() -> void:
	debug_menu.visible = true

func hide_debug_menu() -> void:
	if !OS.is_debug_build():
		debug_menu.visible = false

func toggle_debug_menu_buttons() -> void:
	if main_menu.visible: return
	debug_menu_buttons.visible = !debug_menu_buttons.visible
	
func choose_difficulty() -> void:
	main_menu.visible = false
	new_game.visible = true

func hide_choose_difficulty() -> void:
	main_menu.visible = true
	new_game.visible = false

func show_run_preview(link: String) -> void:
	run_manager.mode = link
	DebugLogger.info("Run mode selected: %s" % link)

	var path: String = "res://img/game_modes/%s_run.png" % link
	var text: String = "%s_RUN" % link.to_upper()
	var description: String = "%s_RUN_DESCRIPTION" % link.to_upper()

	run_preview_image.texture = load(path)
	run_preview_label.text = tr(text)
	run_preview_description.text = tr(description)

	change_difficulty(run_manager.difficulty)
	run_preview.visible = true

func change_difficulty(diff_id: String) -> void:
	run_manager.difficulty = diff_id
	DebugLogger.info("Difficulty selected: %s" % diff_id)

	var diff_description: String = "%s_%s_RUN_DESCRIPTION" % [
		run_manager.mode.to_upper(),
		run_manager.difficulty.to_upper()
	]

	run_preview_diff_description.text = tr(diff_description)

func set_endless(toggle: bool) -> void:
	run_manager.is_infinite = toggle
	DebugLogger.info("Endless mode changed: %s" % toggle)

func hide_run_preview() -> void:
	run_preview.visible = false
	new_game.visible = true
	new_game.call_deferred("auto_button_select")

func start_run() -> void:
	if run_manager.character_selected == null:
		DebugLogger.warning("Starting run without selected character")

	run_preview.visible = false
	new_game.visible = false
	main_hud.visible = true
	
	run_manager.start_run()

func toggle_pause_menu_visible() -> void:
	pause_menu.visible = !pause_menu.visible

func show_character_selection() -> void:
	character_selection.visible = true
	run_preview.visible = false

func hide_character_selection() -> void:
	character_selection.visible = false
	run_preview.visible = true

func quit_game() -> void:
	DebugLogger.info("Game quit requested")
	get_tree().quit()
