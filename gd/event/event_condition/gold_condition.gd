@tool
class_name EventConditionGold
extends EventCondition

@export var required: int

func check(player: PlayerState, _event: Event) -> bool:
	if player.gold >= required:
		return true
	else:
		return false
