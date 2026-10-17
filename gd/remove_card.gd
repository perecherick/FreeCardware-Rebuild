class_name RemoveCard
extends Control

@export var card_scene: PackedScene

@onready var grid: GridContainer = %GridContainer

var player: PlayerState

func open(player_state: PlayerState) -> void:
	player = player_state
	_refresh_cards()
	show()

func _refresh_cards() -> void:
	_clear_cards()
	
	for card: CardData in player.deck:
		var card_view: CardView = card_scene.instantiate()
		
		grid.add_child(card_view)
		
		card_view.setup(card, 2, 3)
		
		card_view.pressed.connect(_on_card_pressed)

func _on_card_pressed(card_view: CardView) -> void:
	player.remove_card(card_view.card_data)
	hide()

func _clear_cards() -> void:
	for child: Node in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
