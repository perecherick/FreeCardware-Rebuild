class_name CombatEndEvent
extends GameEvent

var combat: Combat
var result: Combat.COMBAT_RESULT

func _init(
	combat_state: Combat,
	combat_result: Combat.COMBAT_RESULT
) -> void:
	self.combat = combat_state
	self.result = combat_result
