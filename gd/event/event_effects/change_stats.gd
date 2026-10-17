@tool
class_name ChangeStats
extends EventEffect

@export var max_hp: int
@export var current_hp: int
@export var current_hp_percent: float
@export var add_current_hp: bool

@export var max_lp: int
@export var current_lp: int
@export var current_lp_percent: float
@export var add_current_lp: bool

# Fuck ts and onahole event fucking shit i hate it ts driving me crazy
@export var current_lp_random_min: int
@export var current_lp_random_max: int
@export var prevent_orgasm: bool

@export var add_lewdness: int
@export var duplicate_lewdness: bool

func apply(player: PlayerState, _event: Event) -> void:
	if max_hp != 0:
		player.change_max_hp(max_hp)
	
	if add_current_hp:
		player.heal(player.hp)
	elif current_hp > 0:
		player.heal(current_hp)
	elif current_hp < 0:
		player.take_damage(abs(current_hp))
	
	if current_hp_percent != 0.0:
		var hp_amount: int = roundi(
			player.max_hp * abs(current_hp_percent) / 100.0
		)

		if current_hp_percent > 0.0:
			player.heal(hp_amount)
		else:
			player.take_damage(hp_amount)

	if max_lp != 0:
		player.change_max_lp(max_lp)

	var lp_amount: int = current_lp
	
	if add_current_lp:
		lp_amount = player.lp
	elif current_lp_percent != 0.0 or current_lp_random_max != 0:
		var lp_percent_amount: int = roundi(
			player.max_lp * abs(current_lp_percent) / 100.0
		)
		
		if prevent_orgasm and current_lp_percent > 0.0:
			lp_percent_amount = mini(
				lp_percent_amount,
				maxi(player.max_lp - player.lp - 1, 0)
			)
		
		if current_lp_percent > 0.0:
			player.add_lp(lp_percent_amount)
		else:
			player.reduce_lp(lp_percent_amount)
	
	if current_lp_random_min != 0 or current_lp_random_max != 0:
		lp_amount = randi_range(
			current_lp_random_min,
			current_lp_random_max
		)

	if prevent_orgasm and lp_amount > 0:
		lp_amount = mini(
			lp_amount,
			maxi(player.max_lp - player.lp - 1, 0)
		)

	if lp_amount > 0:
		player.add_lp(lp_amount)
	elif lp_amount < 0:
		player.reduce_lp(abs(lp_amount))
	
	if duplicate_lewdness:
		player.lewdness += player.lewdness
	elif add_lewdness != 0:
		player.lewdness = maxi(player.lewdness + add_lewdness, 0)
