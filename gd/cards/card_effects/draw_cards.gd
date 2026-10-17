@tool
class_name DrawCardsEffect
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
	combat.draw_cards(amount)
