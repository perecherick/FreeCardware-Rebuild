class_name HardwareEventHandler
extends Node

func _ready() -> void:
	for signal_info: Dictionary in GameEvents.get_script().get_script_signal_list():
		var event_signal: Signal = Signal(GameEvents, signal_info["name"])
		event_signal.connect(_dispatch_event)

func _dispatch_event(event: GameEvent) -> void:
	var player: PlayerState
		
	if event is CombatEndEvent:
		player = event.combat.player
	else:
		player = event.player
	
	for hardware: HardwareData in player.hardware.duplicate():
		if !player.has_hardware(hardware.id): continue
		
		for effect: HardwareEffect in hardware.effects:
			if event.is_cancelled(): return
			
			if effect != null:
				effect.handle_event(event, hardware)
