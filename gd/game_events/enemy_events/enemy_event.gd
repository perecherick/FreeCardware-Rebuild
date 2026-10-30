@abstract
class_name EnemyGameEvent
extends GameEvent

var enemy: EnemyState

func _init(enemy_state: EnemyState) -> void:
	self.enemy = enemy_state
