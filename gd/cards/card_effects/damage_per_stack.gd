@tool
class_name DamagePerStackEffect
extends CardEffect

@export var hardware: HardwareData
@export var damage_per_stack: int

func _get_bonus_damage(
	combat: Combat
) -> int:
	var stacks: int = combat.player.get_hardware_count(
		hardware.id
	)
	
	return stacks * damage_per_stack

@warning_ignore("unused_parameter")
func set_damage(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	return preview.damage + _get_bonus_damage(combat)

func modify_base_preview(preview: CardPreview) -> void:
	preview.set_value("admg", damage_per_stack)
