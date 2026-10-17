@tool
class_name BattleTranceEffect
extends CardEffect

@export var lp_per_hp: int = 2

func _get_lp_budget(combat: Combat) -> int:
	@warning_ignore("integer_division")
	return combat.player.lp / 2

func _get_heal_amount(combat: Combat) -> int:
	if lp_per_hp <= 0:
		return 0

	var missing_hp: int = maxi(
		combat.player.max_hp - combat.player.hp,
		0
	)

	@warning_ignore("integer_division")
	var heal_from_lp: int = (
		_get_lp_budget(combat) / lp_per_hp
	)

	return mini(
		missing_hp,
		heal_from_lp
	)

func _get_lp_to_spend(combat: Combat) -> int:
	return _get_heal_amount(combat) * lp_per_hp

@warning_ignore("unused_parameter")
func set_lp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return -_get_lp_to_spend(combat)

@warning_ignore("unused_parameter")
func set_hp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return _get_heal_amount(combat)
