@tool
class_name HardwareBeforeCombatEffect
extends HardwareEffect

@export var health_change: int
@export var lp_change: int
@export var energy_change: int

func apply_after_enemy_move(_combat: Combat, player: PlayerState) -> void:
	if health_change > 0:
		player.heal(health_change)
	elif health_change < 0:
		player.take_damage(-health_change)
	
	if lp_change > 0:
		player.add_lp(lp_change)
	elif lp_change < 0:
		player.reduce_lp(-lp_change)
	
	if energy_change > 0:
		player.gain_energy(energy_change)
	elif energy_change < 0:
		player.spend_energy(-energy_change)

func apply_before_combat(_combat: Combat, _player: PlayerState):
	pass

func apply_after_combat(_player: PlayerState):
	pass
