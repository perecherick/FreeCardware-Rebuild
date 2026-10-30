class_name EnemyMoveStripPantiesEvent
extends EnemyMoveEvent

var player: PlayerState

func _init(
	enemy_state: EnemyState, 
	move_data: MoveData, 
	player_state: PlayerState
) -> void:
	super(enemy_state, move_data)
	self.player = player_state
