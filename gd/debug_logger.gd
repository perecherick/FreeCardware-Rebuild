# I don't think that logger is kinda needed for this easy and linear
# game, but i really wanted to add it, it's pretty simple
# Maybe for future?
extends Node

var enabled: bool = OS.is_debug_build()
var log_file: FileAccess

func _ready() -> void:
	if enabled: start_logger()

func start_logger() -> void:
	var date: Dictionary = Time.get_datetime_dict_from_system()
	var file_name: String = "debug-%04d-%02d-%02d_%02d-%02d-%02d.log" % [
		date.year,
		date.month,
		date.day,
		date.hour,
		date.minute,
		date.second
	]
	var dir: String = "user://logs/"
	
	DirAccess.make_dir_recursive_absolute(dir)
	
	log_file = FileAccess.open(dir + file_name, FileAccess.WRITE)
	
	if log_file == null:
		enabled = false
		push_error("Failed to create debug log file")
		return
	
	enabled = true
	info("Debug logger started")

func end_logger() -> void:
	if enabled:
		info("Debug logger finished")
		enabled = false
		log_file.close()
		log_file = null

func info(message: Variant, color: Color = Color.WHITE) -> void:
	if !enabled:
		return
	
	var line: String = "[%s] %s" % [
		Time.get_time_string_from_system(),
		str(message)
	]
	
	print_rich(
		"[color=%s]%s[/color]" % [
			color.to_html(),
			line
		]
	)
	
	if log_file:
		log_file.store_line(line)
		log_file.flush()

func warning(message: Variant) -> void:
	if !enabled:
		return
	
	info("WARNING: " + str(message), Color.YELLOW)

func error(message: Variant) -> void:
	if !enabled:
		return
	
	info("ERROR: " + str(message), Color.RED)
