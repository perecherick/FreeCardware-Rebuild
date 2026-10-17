@tool
class_name LoadEventValues
extends EventEffect

@export var values: Array[StringNamePair]

func apply(player: PlayerState, event: Event) -> void:
	for value: StringNamePair in values:
		player.set(value.key, event.get_value(value.value))
