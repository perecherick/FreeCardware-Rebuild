class_name PlayerEndTurnEvent
extends PlayerGameEvent

var combat: Combat

func _init(player_state: PlayerState, combat_state: Combat) -> void:
	super(player_state)
	self.combat = combat_state
