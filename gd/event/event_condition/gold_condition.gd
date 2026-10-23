@tool
class_name EventConditionGold
extends EventCondition

@export var required: int
@export var value_key: StringName

func check(player: PlayerState, event: Event) -> bool:
	var amount: int = required
	
	if !value_key.is_empty():
		if !event.values.has(value_key):
			return false
		
		amount = int(event.get_value(value_key))
	
	return player.gold >= amount
