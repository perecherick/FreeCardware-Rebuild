@tool
class_name ChangeGold
extends EventEffect

@export var amount: int
@export var add_current: bool

func apply(player: PlayerState, _event: Event) -> void:
	if add_current:
		player.change_gold(player.gold)
		return
	
	player.change_gold(amount)
