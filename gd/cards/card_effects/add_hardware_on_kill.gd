@tool
class_name KillEffect
extends CardEffect

@export var hardware: HardwareData

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	if enemy == null:
		return
	
	if !enemy.is_dead():
		return
	
	combat.player.add_hardware(hardware)
