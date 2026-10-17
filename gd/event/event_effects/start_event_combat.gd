@tool
class_name StartEventCombat
extends EventEffect

@export var enemy: EnemyData
@export var win_step: StringName
@export var lose_step: StringName
@export var lose_condition: Array[EventCondition]
@export var player_lose_move: EnemyMove

func apply(_player: PlayerState, event: Event) -> void:
	event.start_combat(
		enemy,
		win_step,
		lose_step,
		lose_condition, 
		player_lose_move
	)
