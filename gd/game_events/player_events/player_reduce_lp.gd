class_name PlayerReduceLPEvent
extends PlayerGameEvent

var lp: int

func _init(
	player_state: PlayerState,
	amount: int
) -> void:
	super(player_state)
	self.lp = amount
