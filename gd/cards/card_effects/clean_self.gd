@tool
class_name CleanSelfEffect
extends CardEffect

@export var hardwares: Array[HardwareData]

@export var heal_per_cum: int
@export var lp_per_cum: int

func _get_heal(combat: Combat) -> int:
	var count: int = 0
	
	for hardware: HardwareData in hardwares:
		if hardware == null:
			continue
		
		if combat.player.has_hardware(hardware.id):
			count += 1
	
	return count * heal_per_cum

func _get_lp(combat: Combat) -> int:
	var count: int = 0
	
	for hardware: HardwareData in hardwares:
		if hardware == null:
			continue
		
		if combat.player.has_hardware(hardware.id):
			count += 1
	
	return count * lp_per_cum

@warning_ignore("unused_parameter")
func set_hp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return _get_heal(combat)

@warning_ignore("unused_parameter")
func set_lp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return _get_lp(combat)
