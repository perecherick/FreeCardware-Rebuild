class_name Deck
extends Control

@export var card_scene: PackedScene
@onready var grid: GridContainer = %GridContainer
@onready var visual: Control = %Visual

func setup(cards: Array[CardData]) -> void:
	clear()
	for card: CardData in cards:
		add_card(card)

func add_card(card: CardData) -> void:
	var card_node: Node = card_scene.instantiate()
	grid.add_child(card_node)
	card_node.setup(card, 2, 3)

func clear() -> void:
	for child: Node in grid.get_children():
		child.queue_free()

func _on_button_pressed() -> void:
	visual.visible = !visual.visible
