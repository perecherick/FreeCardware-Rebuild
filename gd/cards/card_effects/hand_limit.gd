@tool
class_name HandLimitEffect
extends CardEffect

@export var max_in_hand: int

func can_draw(
	combat: Combat,
	card: CardData
) -> bool:
	return (
		combat.get_card_draws_this_turn(card)
		< max_in_hand
	)
