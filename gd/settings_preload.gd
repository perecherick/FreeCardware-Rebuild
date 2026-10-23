extends Node

const SETTINGS_PATH: String = "user://settings.cfg"
const SCREEN_SIZES: Array[Vector2i] = [
	Vector2i(3840, 2160),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]

var config: ConfigFile = ConfigFile.new()

var locale: int = 0
var master_volume_value: float = 1.0
var music_volume_value: float = 0.3
var sfx_volume_value: float = 0.5
var sex_volume_value: float = 0.7

var screen_mode: int = 2
var screen_size: int = -1

var discord_activity: bool = false

var character: String = "lucy"

func _ready() -> void:
	load_settings()
	apply_locale(locale)
	apply_audio()
	load_character()
	apply_screen_mode()

func load_settings() -> void:
	var loaded: Error = config.load(SETTINGS_PATH)

	if loaded != OK:
		if loaded == ERR_FILE_NOT_FOUND:
			DebugLogger.info("Settings file not found; creating defaults")
		else:
			DebugLogger.warning("Failed to load settings: error=%d" % loaded)

		save_settings()
		return

	master_volume_value = config.get_value("audio", "master", 1.0)
	music_volume_value = config.get_value("audio", "music", 0.3)
	sfx_volume_value = config.get_value("audio", "sfx", 0.5)
	sex_volume_value = config.get_value("audio", "sex", 0.7)
	locale = config.get_value("language", "locale", 0)
	screen_mode = config.get_value("screen", "mode", 2)
	screen_size = config.get_value("screen", "size", -1)
	discord_activity = config.get_value("discord", "activity", false)
	
	DebugLogger.info(
		"Settings loaded: locale=%d, master=%.2f, music=%.2f, sfx=%.2f, sex=%.2f, discord=%s"
		% [locale, master_volume_value, music_volume_value, sfx_volume_value, sex_volume_value, discord_activity]
	)

func save_settings() -> void:
	config.set_value("audio", "master", master_volume_value)
	config.set_value("audio", "music", music_volume_value)
	config.set_value("audio", "sfx", sfx_volume_value)
	config.set_value("audio", "sex", sex_volume_value)
	config.set_value("language", "locale", locale)
	config.set_value("screen", "mode", screen_mode)
	config.set_value("screen", "size", screen_size)
	config.set_value("discord", "activity", discord_activity)

	var save_result: Error = config.save(SETTINGS_PATH)

	if save_result != OK:
		DebugLogger.warning("Failed to save settings: error=%d" % save_result)
	else:
		DebugLogger.info("Settings saved")

func apply_locale(index: int) -> void:
	match index:
		0: TranslationServer.set_locale("en")
		1: TranslationServer.set_locale("ja")
		2: TranslationServer.set_locale("zh")
		3: TranslationServer.set_locale("es")
		4: TranslationServer.set_locale("ko")
		5: TranslationServer.set_locale("ru")
		6: TranslationServer.set_locale("de")
		_:
			DebugLogger.warning("Unknown locale index: %d" % index)

func apply_audio() -> void:
	set_bus_volume("Master", master_volume_value)
	set_bus_volume("Music", music_volume_value)
	set_bus_volume("SFX", sfx_volume_value)
	set_bus_volume("Sex", sex_volume_value)

func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func load_character() -> void:
	var loaded: Error = config.load(SETTINGS_PATH)

	if loaded != OK:
		if loaded == ERR_FILE_NOT_FOUND:
			DebugLogger.info("Settings file not found; creating defaults")
		else:
			DebugLogger.warning("Failed to load settings: error=%d" % loaded)

		save_settings()
		return

	character = config.get_value("character", "id", "lucy")
	DebugLogger.info("Loaded character: %s" % character)

func save_character() -> void:
	config.set_value("character", "id", character)

	var save_result: Error = config.save(SETTINGS_PATH)

	if save_result != OK:
		DebugLogger.warning("Failed to save settings: error=%d" % save_result)
	else:
		DebugLogger.info("Settings saved")

func apply_screen_mode() -> void:
	match screen_mode:
		0:
			DebugLogger.info("Setting WINDOWED")
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
			call_deferred("apply_screen_size")
		1:
			DebugLogger.info("Setting EXCLUSIVE FULLSCREEN")
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
			)
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
		2:
			DebugLogger.info("Setting BORDERLESS")
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				true
			)
			call_deferred("apply_screen_size")

func apply_screen_size() -> void:
	if screen_mode == 1: return
	
	var size: Vector2i
	
	if screen_size == 0:
		size = DisplayServer.screen_get_size()
	elif screen_size - 1 < SCREEN_SIZES.size():
		size = SCREEN_SIZES[screen_size - 1]
	else:
		screen_size = 0
		size = DisplayServer.screen_get_size()
	
	DisplayServer.window_set_size(size)
	call_deferred("center_window")

func center_window() -> void:
	var screen: int = DisplayServer.window_get_current_screen()
	var screen_position: Vector2i = DisplayServer.screen_get_position(screen)
	@warning_ignore("shadowed_variable")
	var screen_size: Vector2i = DisplayServer.screen_get_size(screen)
	var window_size: Vector2i = DisplayServer.window_get_size()

	@warning_ignore("integer_division")
	var position: Vector2i = (
		screen_position
		+ (screen_size - window_size) / 2
	)

	DisplayServer.window_set_position(position)
