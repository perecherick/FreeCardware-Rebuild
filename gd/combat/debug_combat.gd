class_name DebugCombat
extends Combat

signal debug_combat_won
signal debug_combat_lost

func _finish_combat(result: COMBAT_RESULT) -> void:
	if combat_finished:
		return
	
	combat_finished = true
	is_player_turn = false
	combat_hud.set_end_turn_enabled(false)
	
	_process_card_combat_end_effects()
	
	clear_enemy_target()
	clear_player_target()
	
	match result:
		COMBAT_RESULT.WIN:
			debug_combat_won.emit()
		COMBAT_RESULT.LOSS:
			debug_combat_lost.emit()
