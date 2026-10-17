# Ой блять я так заебался я даже переводить это не буду сорри
class_name CardHand
extends Control

@onready var hand: HBoxContainer = %Hand

@onready var combat: Combat = $"../"
@export var card_scene: PackedScene

var dragged_card: CardView = null

func set_cards(cards: Array[CardData]) -> void:
	for card: CardData in cards:
		add_card(card)

func add_card(card: CardData) -> void:
	var card_node: Node = card_scene.instantiate()
	hand.add_child(card_node)
	card_node.pressed.connect(_on_card_pressed)
	card_node.setup(card, 2, 3, CardView.HoverPivot.BOTTOM)

func give_random_cards(cards: Array[CardData], count: int = 5) -> Array[CardData]:
	if cards.size() <= count:
		return cards
	
	var random_cards: Array[CardData] = cards.duplicate()
	random_cards.shuffle()
	random_cards.resize(count)
	
	return random_cards

func take_all_cards() -> Array[CardData]:
	var cards: Array[CardData] = []

	dragged_card = null

	combat.clear_enemy_target()
	combat.clear_player_target()

	for child: Node in hand.get_children():
		var card_view: CardView = child

		if card_view == null:
			continue

		if card_view.is_queued_for_deletion():
			continue

		cards.append(card_view.card_data)
		card_view.queue_free()

	return cards

func clear_hand() -> void:
	dragged_card = null

	combat.clear_enemy_target()
	combat.clear_player_target()

	for child: Node in hand.get_children():
		child.queue_free()

func _on_card_pressed(card: CardView) -> void:
	if dragged_card != null:
		return

	dragged_card = card

	dragged_card.start_drag(get_global_mouse_position())
	_set_cards_hover_enabled(false)

func _set_cards_hover_enabled(value: bool) -> void:
	for child: Node in hand.get_children():
		var card: CardView = child

		if card != null:
			card.set_hover_input_enabled(value)

func _input(event: InputEvent) -> void:
	if dragged_card == null:
		return

	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and !event.pressed
	):
		_stop_drag()

func _stop_drag() -> void:
	if dragged_card == null:
		return

	var card: CardView = dragged_card
	dragged_card = null

	var played: bool = combat.try_play_card(card)

	combat.clear_enemy_target()
	combat.clear_player_target()

	if !played:
		card.stop_drag()

	_set_cards_hover_enabled(true)

func update_card_availability() -> void:
	for child: Node in hand.get_children():
		var card_view: CardView = child

		if card_view == null:
			continue

		card_view.set_available(
			combat.can_play_card(card_view.card_data)
		)

func _process(_delta: float) -> void:
	if dragged_card == null:
		return

	var mouse: Vector2 = get_global_mouse_position()
	var card: CardData = dragged_card.card_data

	if card.can_target_enemy():
		var enemy: EnemyView = combat.get_enemy_target(mouse)

		if enemy != null:
			combat.clear_player_target()

			dragged_card.drag_to_target(
				enemy.get_card_target_position(),
				mouse,
				dragged_card.get_preview(
					combat,
					enemy.enemy_state
				)
			)

			return

	if card.can_target_self():
		var player: PlayerSprite = combat.get_player_target(mouse)

		if player != null:
			combat.clear_enemy_target()

			dragged_card.drag_to_target(
				player.get_card_target_position(),
				mouse,
				dragged_card.get_preview(combat)
			)

			return

	combat.clear_enemy_target()
	combat.clear_player_target()

	dragged_card.drag_to(mouse)

func get_card_views() -> Array[CardView]:
	var cards: Array[CardView] = []

	for child: Node in hand.get_children():
		var card_view: CardView = child

		if card_view == null:
			continue

		if card_view.is_queued_for_deletion():
			continue

		cards.append(card_view)

	return cards
