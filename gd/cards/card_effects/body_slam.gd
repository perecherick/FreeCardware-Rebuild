@tool
class_name BodySlamEffect
extends CardEffect

@export var lewdness_per_damage: int
@export var lewdness_per_pp: int

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return max(preview.damage, combat.player.lewdness * lewdness_per_damage)

@warning_ignore("unused_parameter")
func set_pp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return max(preview.pp, combat.player.lewdness * lewdness_per_pp)

func modify_base_preview(preview: CardPreview) -> void:
	preview.set_value("dlewd", lewdness_per_damage)
	preview.set_value("plewd", lewdness_per_pp)
