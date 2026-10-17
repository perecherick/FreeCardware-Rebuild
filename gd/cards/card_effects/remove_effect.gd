@tool
class_name RemoveEffect
extends CardEffect

@export var effect_to_remove: Array[EffectData]

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	for effect: EffectData in effect_to_remove:
		enemy.remove_effect(effect.id)
