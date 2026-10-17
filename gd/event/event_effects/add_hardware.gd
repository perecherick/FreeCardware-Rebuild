@tool
class_name EventAddHardware
extends EventEffect

@export var hardware_list: Array[HardwareData]

func apply(player: PlayerState, _event: Event) -> void:
	for hardware: HardwareData in hardware_list:
		player.add_hardware(hardware)
