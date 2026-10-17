# Fucking fuck i'm really that stupid?
# p.s. why other funcs are not @abstract?
# cause they are not used in every card
@tool
@abstract
class_name CardEffect
extends Resource

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	pass

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return preview.damage

@warning_ignore("unused_parameter")
func set_pp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return preview.pp

@warning_ignore("unused_parameter")
func set_lp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return preview.lp

@warning_ignore("unused_parameter")
func set_hp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return preview.hp

@warning_ignore("unused_parameter")
func on_player_turn_end(
	combat: Combat,
	card: CardData
) -> void:
	pass

@warning_ignore("unused_parameter")
func on_combat_end(
	combat: Combat,
	card: CardData
) -> void:
	pass

@warning_ignore("unused_parameter")
func set_energy_cost(
	combat: Combat,
	preview: CardPreview
) -> int:
	return preview.energy_cost

@warning_ignore("unused_parameter")
func modify_base_preview(preview: CardPreview) -> void:
	pass

@warning_ignore("unused_parameter")
func apply_limits(preview: CardPreview) -> void:
	pass
