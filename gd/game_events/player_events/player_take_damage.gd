class_name PlayerTakeDamageEvent
extends PlayerGameEvent

var amount: int
var source: Object

func _init(
	player_state: PlayerState,
	damage: int,
	damage_source: Object = null
) -> void:
	super(player_state)
	amount = damage
	source = damage_source
