@abstract
class_name EnemyMoveEvent
extends EnemyGameEvent

var move: MoveData

func _init(enemy_state: EnemyState, move_data: MoveData) -> void:
	super(enemy_state)
	self.move = move_data
