@tool
class_name ClothesSpiritEffect
extends CardEffect

@export var damage_per_clothes: int
@export var damage_per_torn_clothes: int
@export var damage_per_panties: int

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	var damage: int = 0

	if !combat.player.panties_removed:
		damage += damage_per_panties

	match combat.player.clothes_state:
		PlayerState.ClothesState.NORMAL:
			damage += damage_per_clothes

		PlayerState.ClothesState.TORN:
			damage += damage_per_torn_clothes

	return damage
