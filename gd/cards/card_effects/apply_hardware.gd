@tool
class_name ApplyHardware
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
	var player: PlayerState = combat.player
	
	if hardware == null:
		return
	
	if !hardware.stackable and player.has_hardware(hardware.id):
		return
	
	player.add_hardware(hardware)
