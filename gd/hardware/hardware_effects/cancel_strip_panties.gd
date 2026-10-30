@tool
class_name CancelStripPantiesHardwareEffect
extends HardwareEffect

func handle_event(event: GameEvent, hardware: HardwareData) -> void:
	if (
		event is not EnemyMoveStripPantiesEvent
		or !event.player.has_hardware(hardware.id)
		or event.player.panties_removed
		or event.is_cancelled()
	): return
	
	event.player.remove_hardware(hardware.id)
	event.cancel()
