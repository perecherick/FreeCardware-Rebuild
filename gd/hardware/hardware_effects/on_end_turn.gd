@tool
class_name OnEndTurnHardwareEffect
extends HardwareEffect

@export var required_card_id: String

func handle_event(event: GameEvent, hardware: HardwareData) -> void:
	if (
		event is not PlayerEndTurnEvent
		or !event.player.has_hardware(hardware.id) 
		or event.is_cancelled()
	): return
	
	if required_card_id not in event.combat.played_cards_this_turn:
		event.player.remove_all_hardware(hardware.id)
