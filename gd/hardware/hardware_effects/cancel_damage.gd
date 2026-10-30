@tool
class_name CancelDamageHardwareEffect
extends HardwareEffect

func handle_event(event: GameEvent, hardware: HardwareData) -> void:
	if (
		event is not PlayerTakeDamageEvent 
		or !event.player.has_hardware(hardware.id) 
		or event.is_cancelled()
	): return
	
	event.player.remove_hardware(hardware.id)
	event.cancel()
