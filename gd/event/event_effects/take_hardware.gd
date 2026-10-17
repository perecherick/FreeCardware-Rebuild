@tool
class_name TakeHardware
extends EventEffect

func apply(player: PlayerState, event: Event) -> void:
	player.add_hardware(event.get_value(&"hardware"))
