@tool
class_name ApplyEnemyEffect
extends CardEffect

@export var effect: EffectData
@export var duration: int
@export var duration_from_spent_energy: bool = false:
	set(value):
		duration_from_spent_energy = value
		notify_property_list_changed()

func _validate_property(property: Dictionary) -> void:
	if property.name == "duration":
		if duration_from_spent_energy:
			property.usage |= PROPERTY_USAGE_READ_ONLY

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	if enemy == null or effect == null:
		return

	if duration_from_spent_energy:
		enemy.add_effect(
			effect,
			spent_energy
		)
	else:
		enemy.add_effect(effect, duration)
