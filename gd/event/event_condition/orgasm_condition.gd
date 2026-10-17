@tool
class_name OrgasmCondition
extends EventCondition

func check(player: PlayerState, _event: Event) -> bool:
	return player.is_orgasming()
