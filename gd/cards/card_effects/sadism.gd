@tool
class_name SadismEffect
extends CardEffect

@export var damage_per_lp: int

func set_damage(
	combat: Combat,
	_preview: CardPreview,
	_enemy: EnemyState = null
) -> int:
	return combat.player.lp * damage_per_lp

func set_lp(
	_combat: Combat,
	_preview: CardPreview,
	_enemy: EnemyState = null
) -> int:
	return 0
