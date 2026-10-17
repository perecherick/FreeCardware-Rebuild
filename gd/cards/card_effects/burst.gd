@tool
class_name BurstEffect
extends CardEffect

@export var mark_effect: EffectData

@export var damage_per_mark: int
@export var heal_per_mark: int

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	if enemy == null:
		return 0
	
	var mark: EffectState = enemy.get_effect(mark_effect.id)
	if mark == null:
		return 0
	
	return mark.stacks * damage_per_mark

@warning_ignore("unused_parameter")
func set_hp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	if enemy == null:
		return 0
	
	var mark: EffectState = enemy.get_effect(mark_effect.id)
	if mark == null:
		return 0
	
	return mark.stacks * heal_per_mark
