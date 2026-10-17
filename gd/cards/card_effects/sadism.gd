@tool
class_name SadismEffect
extends CardEffect

@export var damage_per_lp: int

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return combat.player.lp * damage_per_lp

@warning_ignore("unused_parameter")
func set_lp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return 0
