@tool
class_name DiceEffect
extends CardEffect

@export var energy: int
@export var heal: int
@export var reduce_lp: int
@export var draw_cards: int
@export var gold: int

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	var player: PlayerState = combat.player

	match randi_range(0, 5):
		0:
			player.gain_energy(energy)
		1:
			player.heal(heal)
		2:
			player.reduce_lp(reduce_lp)
		3:
			combat.draw_cards(draw_cards)
		4:
			player.change_gold(gold)
		5:
			pass
