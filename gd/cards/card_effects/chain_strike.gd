@tool
class_name ChainStrikeEffect
extends CardEffect

@export var hardware: HardwareData

func _remove_hardware_if_card_not_played(
	combat: Combat,
	card: CardData
) -> void:
	if hardware == null:
		return

	if combat.get_card_plays_this_turn(card) > 0:
		return

	combat.player.remove_all_hardware(hardware.id)

func on_player_turn_end(combat: Combat, card: CardData) -> void:
	_remove_hardware_if_card_not_played(combat, card)

func on_combat_end(combat: Combat, card: CardData) -> void:
	_remove_hardware_if_card_not_played(combat, card)
