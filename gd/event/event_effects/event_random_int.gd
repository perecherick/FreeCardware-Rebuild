@tool
class_name EventRandomInt
extends EventEffect

@export var key: StringName
@export var min_int: int
@export var max_int: int

func apply(_player: PlayerState, event: Event) -> void:
	event.set_value(key, randi_range(min_int, max_int))
