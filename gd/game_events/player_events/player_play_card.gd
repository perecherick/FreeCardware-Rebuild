class_name PlayerPlayCardEvent
extends PlayerGameEvent

var card: CardData

func _init(
	player_state: PlayerState, 
	card_data: CardData
) -> void:
	super(player_state)
	self.card = card_data
