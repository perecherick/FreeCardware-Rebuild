@tool
class_name HardwareAfterCombatEffect
extends HardwareEffect

@export var health_change: int
@export var lp_change: int

func handle_event(event: GameEvent, hardware: HardwareData) -> void:
	if (
		event is not CombatEndEvent
		or !event.combat.player.has_hardware(hardware.id)
		or event.is_cancelled()
	): return
	
	if health_change > 0:
		event.combat.player.heal(health_change)
	elif health_change < 0:
		event.combat.player.take_damage(-health_change)
	
	if lp_change > 0:
		event.combat.player.take_lp(lp_change)
	elif lp_change < 0:
		event.combat.player.reduce_lp(-lp_change)
