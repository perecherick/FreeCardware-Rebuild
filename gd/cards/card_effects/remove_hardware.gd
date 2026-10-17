@tool
class_name RemoveHardwareOnPlay
extends CardEffect

@export var hardwares: Array[HardwareData]

@warning_ignore("unused_parameter")
func apply(
	combat: Combat,
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	for hardware: HardwareData in hardwares:
		if hardware == null:
			continue

		combat.player.remove_all_hardware(hardware.id)
