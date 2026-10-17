@tool
class_name SaveEventValues
extends EventEffect

@export var values: Array[StringNamePair]

func apply(player: PlayerState, event: Event) -> void:
	for value: StringNamePair in values:
		event.set_value(value.value, player.get(value.key))
