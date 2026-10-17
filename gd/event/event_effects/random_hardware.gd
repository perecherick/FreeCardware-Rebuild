@tool
class_name RandomHardware
extends EventEffect

@export var hardware: Array[HardwareData]

func apply(_player: PlayerState, event: Event) -> void:
	event.set_value(&"hardware", hardware.pick_random())
