@tool
class_name ChangeGold
extends EventEffect

@export var amount: int
@export var add_current: bool
@export var value_key: StringName

func apply(player: PlayerState, event: Event) -> void:
	if add_current:
		player.change_gold(player.gold)
		return
	
	if !value_key.is_empty():
		if !event.values.has(value_key):
			DebugLogger.error("Missing event value: %s" % value_key)
			return
		
		#TODO: fix this -
		player.change_gold(-event.get_value(value_key))
		return
	
	player.change_gold(amount)
