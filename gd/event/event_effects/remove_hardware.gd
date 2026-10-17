@tool
class_name EventRemoveHardware
extends EventEffect

@export var hardware_list: Array[HardwareData]

func apply(player: PlayerState, _event: Event) -> void:
	for hardware: HardwareData in hardware_list:
		player.remove_all_hardware(hardware.id)
