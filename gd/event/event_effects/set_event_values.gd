@tool
class_name SetEventValue
extends EventEffect

@export var values: Array[StringNamePair]

func apply(_player: PlayerState, event: Event) -> void:
	for value: StringNamePair in values:
		event.set_value(value.key, value.value)
