@tool
class_name ChangeClothesEffect
extends CardEffect

@export var remove_panties: bool
@export var gain_panties: bool

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	if remove_panties:
		combat.player.strip_panties()
	if gain_panties:
		combat.player.put_panties_on()
