@tool
class_name ModifyCardDuringSexEffect
extends CardEffect

@export var damage_buff: int

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	if combat.player.in_sex:
		return preview.damage + damage_buff
	else:
		return preview.damage
