@tool
class_name EventValueCondition
extends EventCondition

@export var key: StringName
@export var value: StringName

func check(_player: PlayerState, event: Event) -> bool:
	return event.get_value(key) == value
