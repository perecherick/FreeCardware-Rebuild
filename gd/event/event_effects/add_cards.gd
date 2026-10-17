@tool
class_name EventAddCards
extends EventEffect

@export var add_cards: Array[CardData]
@export var remove_cards: Array[CardData]
@export var duplicate_current_deck: bool

func apply(player: PlayerState, event: Event) -> void:
	if duplicate_current_deck:
		var current_deck: Array[CardData] = player.deck.duplicate()
		
		event.set_value(&"cards", current_deck.size())
		
		for card: CardData in current_deck:
			player.add_card(card)
	
	for card: CardData in add_cards:
		player.add_card(card)
	
	for card: CardData in remove_cards:
		player.remove_card(card)
