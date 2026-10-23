class_name EnemyState
extends Resource

const ORGASM_EFFECT: EffectData = preload(
	"res://tres/enemies/effects/orgasm.tres"
)

signal hp_changed(current: int, max: int)
signal pp_changed(current: int, max: int)

var data: EnemyData

var max_hp: int
var hp: int

var max_pp: int
var pp: int

var effects: Array[EffectState]

var normal_move_index: int = 0
var enemy_sex_move_index: int = 0
var player_sex_move_index: int = 0
var player_orgasm_move_index: int = 0

signal orgasm
signal orgasm_over
signal effects_changed

func setup(enemy_data: EnemyData) -> void:
	data = enemy_data
	
	max_hp = enemy_data.max_hp
	hp = enemy_data.starting_hp
	
	max_pp = enemy_data.max_pp
	pp = enemy_data.starting_pp
	
	effects.clear()

	for effect_data: EffectData in enemy_data.effects:
		effects.append(
			EffectState.new(effect_data)
		)
	
	normal_move_index = 0
	enemy_sex_move_index = 0
	player_sex_move_index = 0
	player_orgasm_move_index = 0

func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)

func take_pp(amount: int) -> void:
	if amount <= 0:
		return
	
	pp = clampi(pp + amount, 0, max_pp)
	
	if is_orgasming():
		take_damage(amount)
		pp = clampi(pp + amount, 0, max_pp)

	if pp >= max_pp:
		pp = 0
		start_orgasm()

	pp_changed.emit(pp, max_pp)

func reduce_pp(amount: int) -> void:
	if amount <= 0:
		return
	
	pp = maxi(pp - amount, 0)
	pp_changed.emit(pp, max_pp)

func is_dead() -> bool:
	return hp <= 0

func advance_move(player: PlayerState) -> void:
	if (
		player.is_orgasming()
		and !data.player_orgasm_moves.is_empty()
	):
		player_orgasm_move_index = (
			player_orgasm_move_index + 1
		) % data.player_orgasm_moves.size()
		
		return
	
	if player.in_sex and player.active_enemy == self:
		match player.sex_initiator:
			PlayerState.SexInitiator.ENEMY:
				if data.enemy_initiated_sex_moves.is_empty():
					return
				
				enemy_sex_move_index = (
					enemy_sex_move_index + 1
				) % data.enemy_initiated_sex_moves.size()
			PlayerState.SexInitiator.PLAYER:
				if data.player_initiated_sex_moves.is_empty():
					return
				player_sex_move_index = (
					player_sex_move_index + 1
				) % data.player_initiated_sex_moves.size()
			_:
				return
		return
	
	if data.move_list.is_empty():
		return
	
	normal_move_index = (
		normal_move_index + 1
	) % data.move_list.size()

func get_sex_moves(player: PlayerState) -> Array[EnemyMove]:
	if !player.in_sex:
		return []
	if player.active_enemy != self:
		return []
	match player.sex_initiator:
		PlayerState.SexInitiator.ENEMY:
			return data.enemy_initiated_sex_moves
		PlayerState.SexInitiator.PLAYER:
			return data.player_initiated_sex_moves
		_:
			return []

func get_current_move(player: PlayerState) -> EnemyMove:
	var moves: Array[EnemyMove]
	var index: int
	
	if (
		player.is_orgasming()
		and !data.player_orgasm_moves.is_empty()
	):
		moves = data.player_orgasm_moves
		index = player_orgasm_move_index
	
	elif player.in_sex and player.active_enemy == self:
		moves = get_sex_moves(player)
		
		match player.sex_initiator:
			PlayerState.SexInitiator.ENEMY:
				index = enemy_sex_move_index
			PlayerState.SexInitiator.PLAYER:
				index = player_sex_move_index
			_:
				return null
	else:
		moves = data.move_list
		index = normal_move_index
	
	if moves.is_empty():
		return null
	
	return moves[index % moves.size()]

func tick_effects() -> void:
	var was_orgasming: bool = is_orgasming()
	@warning_ignore("shadowed_variable_base_class")
	var changed: bool = false

	for i: int in range(effects.size() - 1, -1, -1):
		var effect: EffectState = effects[i]

		if !effect.tick():
			effects.remove_at(i)

		changed = true

	if changed:
		effects_changed.emit()

	if was_orgasming and !is_orgasming():
		orgasm_over.emit()

func get_effect(id: String) -> EffectState:
	for effect: EffectState in effects:
		if effect.data.id == id:
			return effect

	return null

func has_effect(id: String) -> bool:
	return get_effect(id) != null

func is_orgasming() -> bool:
	return has_effect("orgasm")

func start_orgasm() -> void:
	var existing: EffectState = get_effect("orgasm")

	if existing != null:
		existing.turns_left = ORGASM_EFFECT.default_duration
	else:
		effects.append(
			EffectState.new(ORGASM_EFFECT)
		)

	effects_changed.emit()
	orgasm.emit()
	AudioManager.play_sex_sound(&"cum")

func get_disable_effect() -> EffectState:
	for effect: EffectState in effects:
		if effect.data.disables_turn:
			return effect
	
	return null

func is_disabled() -> bool:
	return get_disable_effect() != null

func add_effect(
	effect_data: EffectData,
	duration: int = -1
) -> void:
	if effect_data == null:
		return

	var final_duration: int = (
		duration
		if duration >= 0
		else effect_data.default_duration
	)

	if (
		effect_data.duration_mode == EffectData.DurationMode.TURNS
		and final_duration <= 0
	):
		return

	var existing: EffectState = get_effect(effect_data.id)

	if existing != null:
		existing.stacks += effect_data.default_stacks

		if effect_data.max_stacks > 0:
			existing.stacks = mini(
				existing.stacks,
				effect_data.max_stacks
			)

		if effect_data.duration_mode == EffectData.DurationMode.TURNS:
			existing.turns_left = final_duration

	else:
		var effect_state: EffectState = EffectState.new(
			effect_data,
			final_duration
		)

		effects.append(effect_state)

	effects_changed.emit()

func remove_effect(id: String) -> void:
	for i: int in range(effects.size() - 1, -1, -1):
		if effects[i].data.id == id:
			effects.remove_at(i)
			effects_changed.emit()
			return
