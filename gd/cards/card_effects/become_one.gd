@tool
class_name BecomeOneEffect
extends CardEffect

func _get_split_pp(
	combat: Combat,
	enemy: EnemyState
) -> int:
	if enemy == null:
		return 0
	
	var total: int = combat.player.lp + enemy.pp
	
	@warning_ignore("integer_division")
	var player_lp: int = total / 2
	var enemy_pp: int = total - player_lp
	
	return enemy_pp

func _get_split_lp(
	combat: Combat,
	enemy: EnemyState
) -> int:
	if enemy == null:
		return 0
	
	var total: int = combat.player.lp + enemy.pp
	
	@warning_ignore("integer_division")
	var player_lp: int = total / 2
	
	return player_lp

@warning_ignore("unused_parameter")
func set_pp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	if enemy == null:
		return 0
	
	return _get_split_pp(combat, enemy) - enemy.pp

@warning_ignore("unused_parameter")
func set_lp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	if enemy == null:
		return 0
	
	return _get_split_lp(combat, enemy) - combat.player.lp
