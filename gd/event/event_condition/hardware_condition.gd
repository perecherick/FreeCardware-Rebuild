@tool
class_name HardwareCondition
extends EventCondition

@export var hardware: HardwareData

func check(player: PlayerState, _event: Event) -> bool:
	return player.has_hardware(hardware.id)
