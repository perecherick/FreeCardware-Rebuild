@tool
class_name LewdnessCondition
extends EventCondition

@export var lewdness: int

func check(player: PlayerState, _event: Event) -> bool:
	if player.lewdness >= lewdness:
		return true
	else:
		return false
