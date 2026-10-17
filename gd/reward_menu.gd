class_name RewardMenu
extends Control

signal card_picked(card: CardData)
signal continue_pressed

@export var card_scene: PackedScene

@onready var cards_root: HBoxContainer = %Cards
@onready var continue_button: Button = %Continue
@onready var animation_player: AnimationPlayer = %AnimationPlayer

const APPEAR_ANIMATION: StringName = &"reward_appear"

var selected_card_view: CardView = null

func open_reward(
	card_pool: Array[CardData],
	choices_count: int = 3
) -> void:
	_clear_cards()

	selected_card_view = null
	continue_button.disabled = false

	var reward_cards: Array[CardData] = _pick_random_cards(
		card_pool,
		choices_count
	)

	visible = true

	if reward_cards.is_empty():
		DebugLogger.warning("Reward card pool is empty")
		continue_button.disabled = false
		_play_appear_animation()
		return

	for card_data: CardData in reward_cards:
		var card_view: CardView = card_scene.instantiate()

		if card_view == null:
			DebugLogger.warning(
				"Reward card scene root is not CardView"
			)
			continue

		cards_root.add_child(card_view)

		card_view.setup(
			card_data,
			1.0,
			1.3,
			CardView.HoverPivot.CENTER
		)

		card_view.pressed.connect(_on_card_pressed)

	_play_appear_animation()

func _pick_random_cards(
	card_pool: Array[CardData],
	amount: int
) -> Array[CardData]:
	var available: Array[CardData] = card_pool.duplicate()
	var result: Array[CardData] = []

	available.shuffle()

	var final_amount: int = mini(
		amount,
		available.size()
	)

	for i: int in final_amount:
		result.append(available[i])

	return result

func _on_card_pressed(card_view: CardView) -> void:
	if card_view == null or card_view.card_data == null:
		return

	if selected_card_view == card_view:
		selected_card_view = null
	else:
		selected_card_view = card_view

	_update_card_selection()

func _update_card_selection() -> void:
	for child: Node in cards_root.get_children():
		var card_view: CardView = child

		if card_view == null:
			continue

		if selected_card_view == null:
			card_view.modulate = Color.WHITE

		elif card_view == selected_card_view:
			card_view.modulate = Color.WHITE

		else:
			card_view.modulate = Color(
				0.4,
				0.4,
				0.4,
				1.0
			)

func _on_continue_pressed() -> void:
	continue_button.disabled = true

	if (
		is_instance_valid(selected_card_view)
		and selected_card_view.card_data != null
	):
		card_picked.emit(selected_card_view.card_data)

		DebugLogger.info(
			"Reward card confirmed: %s"
			% selected_card_view.card_data.resource_path
		)
	else:
		DebugLogger.info("Card reward skipped")

	continue_pressed.emit()

func close_reward() -> void:
	visible = false
	_clear_cards()

func _play_appear_animation() -> void:
	if !animation_player.has_animation(APPEAR_ANIMATION):
		DebugLogger.warning(
			"Reward animation not found: %s"
			% APPEAR_ANIMATION
		)
		return
	
	animation_player.play(APPEAR_ANIMATION)

func _clear_cards() -> void:
	selected_card_view = null
	
	for child: Node in cards_root.get_children():
		cards_root.remove_child(child)
		child.queue_free()
