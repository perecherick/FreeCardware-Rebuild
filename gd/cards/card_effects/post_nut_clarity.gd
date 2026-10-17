@tool
class_name PostNutClarityEffect
extends CardEffect

@export var energy: int

func modify_base_preview(preview: CardPreview) -> void:
	preview.set_value("gen", energy)

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	if combat.player.is_orgasming():
		combat.player.end_orgasm()
		combat.player.gain_energy(energy)
