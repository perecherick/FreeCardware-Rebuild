# I don't think that logger is kinda needed for this easy and linear
# game, but i really wanted to add it, it's pretty simple
# Maybe for future?
extends Node

var enabled: bool = OS.is_debug_build()
var log_file: FileAccess

func _ready() -> void:
	if !enabled:
		return
	
	log_file = FileAccess.open("user://debug.log", FileAccess.WRITE)
	info("Debug logger started")

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
	
	push_error(str(message))
	info("ERROR: " + str(message), Color.RED)
