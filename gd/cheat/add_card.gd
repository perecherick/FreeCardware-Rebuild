class_name AddCardMenu
extends Control

signal card_selected(card: CardData)

@export var card_scene: PackedScene

@onready var damage_list: HFlowContainer = %DamgeList
@onready var pp_list: HFlowContainer = %PPList
@onready var sex_list: HFlowContainer = %SexList
@onready var misc_list: HFlowContainer = %MiscList

func setup() -> void:
	for card: CardData in CardLibrary.all_cards:
		if card.attack:
			_add_card(card, damage_list)
		if card.pleasure:
			_add_card(card, pp_list)
		if card.sex:
			_add_card(card, sex_list)
		if card.misc:
			_add_card(card, misc_list)

func _add_card(card: CardData, list: HFlowContainer):
	var card_view: CardView = card_scene.instantiate()
	list.add_child(card_view)
	card_view.setup(card, 2.0, 2.5)
	card_view.pressed.connect(_on_card_pressed)

func _on_card_pressed(card_view: CardView) -> void:
	var card: CardData = card_view.card_data
	card_selected.emit(card)
