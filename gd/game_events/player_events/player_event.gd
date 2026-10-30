@abstract
class_name PlayerGameEvent
extends GameEvent

var player: PlayerState

func _init(_player_state: PlayerState) -> void:
	self.player = _player_state
