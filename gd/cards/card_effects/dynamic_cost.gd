@tool
class_name DynamicCost
extends CardEffect

@warning_ignore("unused_parameter")
func set_energy_cost(
	combat: Combat,
	preview: CardPreview
) -> int:
	return combat.player.energy
