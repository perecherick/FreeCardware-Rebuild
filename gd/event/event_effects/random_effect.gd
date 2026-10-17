@tool
class_name RandomEventEffect
extends EventEffect

@export var effect_list: Array[EventEffect]
@export var text_list: Array[StringName]

func apply(player: PlayerState, event: Event) -> void:
	var index: int = randi_range(0, effect_list.size() - 1)
	
	effect_list[index].apply(player, event)
	event.set_value(&"step_text", text_list[index])
