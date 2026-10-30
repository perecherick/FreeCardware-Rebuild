# i want my java back i'm tired of this shit 
class_name EventCombat
extends Combat

signal event_combat_won
signal event_combat_lost

var conditions: Array[EventCondition]
var lose_move: EnemyMove
var escaped: bool

func start_combat(
	enemies: Array[EnemyData],
	player_state: PlayerState,
	condition_list: Array[EventCondition] = [],
	player_lose_move: EnemyMove = null
) -> void:
	conditions = condition_list
	lose_move = player_lose_move
	super.start_combat(enemies, player_state)

func _check_lose_conditions() -> bool:
	var has_condition: bool = false
	
	for condition: EventCondition in conditions:
		if condition == null:
			continue
		
		has_condition = true
		
		if !condition.check(player, null):
			return false
	
	return has_condition

func _finish_combat(result: COMBAT_RESULT) -> void:
	if combat_finished:
		return
	
	combat_finished = true
	is_player_turn = false
	combat_hud.set_end_turn_enabled(false)
	
	_process_card_combat_end_effects()
	
	clear_enemy_target()
	clear_player_target()
	
	match result:
		COMBAT_RESULT.WIN:
			event_combat_won.emit()
		COMBAT_RESULT.LOSS:
			event_combat_lost.emit()

func perform_enemy_actions(enemy_view: EnemyView) -> void:
	if escaped:
		if !_check_lose_conditions():
			escaped = false
			await super.perform_enemy_actions(enemy_view)
			return
		
		await _perform_lose_move(enemy_view)
		_finish_combat(COMBAT_RESULT.LOSS)
		return
	
	await super.perform_enemy_actions(enemy_view)
	
	if escaped and lose_move != null:
		enemy_view.update_intent(
			lose_move,
			player
		)

func _execute_enemy_action(
	enemy_view: EnemyView,
	action: MoveData
) -> void:
	super._execute_enemy_action(enemy_view, action)
	
	if (!escaped and lose_move != null and _check_lose_conditions()):
		escaped = true

func _perform_lose_move(enemy_view: EnemyView) -> void:
	for action: MoveData in lose_move.actions:
		super._execute_enemy_action(
			enemy_view,
			action
		)
		
		await get_tree().create_timer(0.15).timeout

func _refresh_enemy_intents() -> void:
	if !escaped:
		super._refresh_enemy_intents()
		return
	
	for child: Node in enemies_root.get_children():
		var enemy_view: EnemyView = child as EnemyView
		var enemy: EnemyState = enemy_view.enemy_state
		
		if enemy.is_dead():
			continue
		
		enemy_view.update_intent(
			lose_move,
			player
		)
