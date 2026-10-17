@tool
class_name EnergyToLpEffect
extends CardEffect

@export var lp_per_energy: int
 
@warning_ignore("unused_parameter")
func set_lp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return -(preview.energy_cost * lp_per_energy)
