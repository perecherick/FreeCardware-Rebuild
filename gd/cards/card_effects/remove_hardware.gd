@tool
class_name RemoveHardwareOnPlay
extends CardEffect

@export var hardwares: Array[HardwareData]

func apply(
	combat: Combat,
	_card: CardData,
	_enemy: EnemyState = null,
	_spent_energy: int = 0,
	_preview: CardPreview = null
) -> void:
	for hardware: HardwareData in hardwares:
		if hardware == null:
			continue

		combat.player.remove_all_hardware(hardware.id)
