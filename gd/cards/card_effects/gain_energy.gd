@tool
class_name GainEnergyEffect
extends CardEffect

@export var amount: int

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	combat.player.gain_energy(amount)

func modify_base_preview(preview: CardPreview) -> void:
	preview.set_value("gen", amount)
