class_name CheatMenu
extends Control

signal event_requested(event: EventData)

@onready var debug_menu: VBoxContainer = %DebugMenu
@onready var sub_menus: Control = %SubMenus
@onready var event_menu: EventMenu = %EventMenu
@onready var add_card_menu: AddCardMenu = %AddCard
@onready var remove_card_menu: RemoveCard = %RemoveCard
@onready var sex_menu: SexMenu = %SexMenu
@onready var hardware_menu: HardwareMenu = %HardwareMenu
@onready var combat_menu: CombatMenu = %CombatMenu

var player: PlayerState

func setup() -> void:
	for child: Control in sub_menus.get_children():
		if child.has_method("setup"):
			child.setup()

func setup_player(player_state: PlayerState) -> void:
	player = player_state
	for child: Control in sub_menus.get_children():
		if child.has_method("setup_player"):
			child.setup_player(player)

func _on_toggle_menu_pressed() -> void:
	if player == null: return
	debug_menu.visible = !debug_menu.visible
	sub_menus.visible = debug_menu.visible
	_hide_sub_menus()

func _on_event_menu_pressed() -> void:
	_toggle_sub_menu(event_menu)

func _on_clothes_toggle_pressed() -> void:
	if player.clothes_state != player.ClothesState.REMOVED:
		player.clothes_state = player.ClothesState.REMOVED
	else:
		player.clothes_state = player.ClothesState.NORMAL

func _on_torn_toggle_pressed() -> void:
	if player.clothes_state == player.ClothesState.REMOVED:
		return

	if player.clothes_state == player.ClothesState.TORN:
		player.clothes_state = player.ClothesState.NORMAL
	else:
		player.clothes_state = player.ClothesState.TORN

func _on_panties_toggle_pressed() -> void:
	player.panties_removed = !player.panties_removed

func _on_add_card_pressed() -> void:
	_toggle_sub_menu(add_card_menu)

func _hide_sub_menus() -> void:
	for child: Control in sub_menus.get_children():
		child.hide()

func _toggle_sub_menu(menu: Control) -> void:
	var was_visible: bool = menu.visible
	_hide_sub_menus()
	menu.visible = !was_visible

func _on_remove_card_pressed() -> void:
	if remove_card_menu.visible:
		remove_card_menu.hide()
		return
	
	_hide_sub_menus()
	remove_card_menu.open(player)

func _on_sex_menu_pressed() -> void:
	_toggle_sub_menu(sex_menu)

func _on_add_card_card_selected(card: CardData) -> void:
	player.add_card(card)

func _on_event_menu_event_selected(event: EventData) -> void:
	event_requested.emit(event)

func _on_hardware_menu_pressed() -> void:
	_toggle_sub_menu(hardware_menu)

func _on_combat_menu_pressed() -> void:
	_toggle_sub_menu(combat_menu)
