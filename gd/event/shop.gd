class_name Shop
extends Control

const CARDS_AMOUNT: int = 5

@export var card_scene: PackedScene

@onready var cards_root: Control = %Cards

var cards: Array[CardData]
var player: PlayerState

func setup(
	player_state: PlayerState
) -> void:
	_generate_cards()
	player = player_state

func _clear_cards() -> void:
	for child: Node in cards_root.get_children():
		child.queue_free()

func _generate_cards() -> void:
	var all_cards: Array[CardData] = CardLibrary.all_cards
	var normal_cards: Array[CardData] = []
	
	for card: CardData in all_cards:
		if card == null:
			continue
		
		if card.card_type != CardData.CardType.NORMAL_REWARD:
			continue
		
		normal_cards.append(card)
	
	_clear_cards()
	cards.clear()
	
	for i: int in range(CARDS_AMOUNT):
		var card: CardData = normal_cards.pick_random()
		
		if card == null:
			continue
		
		cards.append(card)
		
		var card_view: CardView = card_scene.instantiate()
		cards_root.add_child(card_view)
		
		card_view.setup(card, 2.0, 2.5, card_view.HoverPivot.CENTER, true)
		
		card_view.pressed.connect(_on_card_pressed)

func _on_card_pressed(card_view: CardView) -> void:
	if card_view == null or card_view.card_data == null:
		return
	
	var card: CardData = card_view.card_data
	
	if player.gold < card.card_cost:
		return
	
	player.change_gold(-card.card_cost)
	
	player.add_card(card)
	
	cards.erase(card)
	card_view.queue_free()
	
	DebugLogger.info(
		"Shop card bought: %s for %d"
		% [card.id, card.card_cost]
	)
