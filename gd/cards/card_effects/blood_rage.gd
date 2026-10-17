@tool
class_name BloodRageEffect
extends CardEffect

@export var damage_per_hp: int = 4
@export var min_hp_spend: int = 0
@export var max_hp_spend: int = 4

func _get_hp_to_spend(combat: Combat) -> int:
	return clampi(
		combat.player.hp - 1,
		min_hp_spend,
		max_hp_spend
	)

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return _get_hp_to_spend(combat) * damage_per_hp

@warning_ignore("unused_parameter")
func set_hp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return -(_get_hp_to_spend(combat))
