@tool
class_name ReverseLewdnessDamageEffect
extends CardEffect

@export var lewdness_per_damage_loss: int

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	if combat.player.lewdness <= 0:
		return preview.damage
	else:
		@warning_ignore("integer_division")
		return preview.damage - (combat.player.lewdness / lewdness_per_damage_loss)
