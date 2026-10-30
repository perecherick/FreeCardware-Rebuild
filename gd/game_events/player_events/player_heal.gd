class_name PlayerHealEvent
extends PlayerGameEvent

var hp: int

func _init(
	player_state: PlayerState,
	amount: int
) -> void:
	super(player_state)
	self.hp = amount
