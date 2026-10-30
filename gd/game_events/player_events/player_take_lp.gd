class_name PlayerTakeLPEvent
extends PlayerGameEvent

var amount: int
var source: Object

func _init(
	player_state: PlayerState,
	lp: int,
	lp_source: Object = null
) -> void:
	super(player_state)
	self.amount = lp
	self.source = lp_source
