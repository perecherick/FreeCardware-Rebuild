class_name PlayerState
extends Resource

signal hp_changed(current: int, max: int)
signal lp_changed(current: int, max: int)
signal gold_changed(amount: int)
signal energy_changed(energy: int, max_energy: int)
signal card_added(card: CardData)
signal card_removed(card: CardData)
signal sex_changed(sex_type: SexData, sex_state: int)
signal hardware_changed
signal sex_exited
signal appearance_changed
signal orgasm
signal orgasm_over

enum ClothesState {
	NORMAL,
	TORN,
	REMOVED
}

enum SexInitiator {
	NONE,
	ENEMY,
	PLAYER
}

var character: CharacterData

var max_hp: int
var hp: int

var max_lp: int
var lp: int

var gold: int

var energy: int
var max_energy: int

var lewdness: int

var deck: Array[CardData]
var hardware: Array[HardwareData]

var clothes_state: ClothesState:
	set(value):
		if clothes_state == value:
			return
		
		clothes_state = value
		_on_clothes_state_changed()

var panties_removed: bool:
	set(value):
		if panties_removed == value:
			return

		panties_removed = value
		_on_panties_state_changed()

var in_sex: bool
var current_sex: SexData
var sex_state: int
var active_enemy: EnemyState
var sex_initiator: SexInitiator
var orgasm_skip_left: int

func setup(data: CharacterData) -> void:
	character = data
	
	max_hp = data.max_hp
	hp = data.max_hp
	
	max_lp = data.max_lp
	lp = 0
	
	gold = 0
	
	max_energy = data.max_energy
	energy = data.max_energy
	
	lewdness = 0
	
	deck = data.starting_deck.duplicate()
	hardware = data.starting_hardware.duplicate()
	
	clothes_state = ClothesState.NORMAL
	panties_removed = false
	
	in_sex = false
	current_sex = null
	sex_state = 0
	active_enemy = null
	sex_initiator = SexInitiator.NONE
	orgasm_skip_left = 0

func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)

func heal(amount: int) -> void:
	hp = clampi(hp + amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)

func take_lp(amount: int) -> void:
	if amount <= 0:
		return
	
	var total_amount: int = (
		amount * 2 if is_orgasming() else amount
	)
	
	lp = clampi(lp + total_amount, 0, max_lp)
	if is_orgasming():
		take_damage(amount)
	
	if lp >= max_lp:
		lp = 0
		start_orgasm()
	
	lp_changed.emit(lp, max_lp)

func add_lp(amount: int) -> void:
	lp = clampi(lp + amount, 0, max_lp)
	if lp >= max_lp:
		lp = 0
		start_orgasm()
	lp_changed.emit(lp, max_lp)

func reduce_lp(amount: int) -> void:
	lp = clampi(lp - amount, 0, max_lp)
	lp_changed.emit(lp, max_lp)

func change_max_hp(amount: int) -> void:
	max_hp = maxi(max_hp + amount, 0)
	hp = clampi(hp, 0, max_hp)
	hp_changed.emit(hp, max_hp)

func change_max_lp(amount: int) -> void:
	max_lp = maxi(max_lp + amount, 0)
	lp = clampi(lp, 0, max_lp)
	lp_changed.emit(lp, max_lp)

func change_gold(amount: int) -> void:
	gold = maxi(gold + amount, 0)
	gold_changed.emit(gold)

func add_card(card: CardData) -> void:
	if card == null:
		return

	deck.append(card)
	card_added.emit(card)

func remove_card(card: CardData) -> void:
	if card == null:
		return
	
	deck.erase(card)
	card_removed.emit(card)

func reset_energy() -> void:
	energy = max_energy
	energy_changed.emit(energy, max_energy)

func set_energy(amount: int) -> void:
	energy = amount
	energy_changed.emit(energy, max_energy)

func spend_energy(amount: int) -> bool:
	if amount < 0 or energy < amount:
		return false

	energy -= amount
	energy_changed.emit(energy, max_energy)
	return true

func gain_energy(amount: int) -> void:
	energy = max(energy + amount, 0)
	energy_changed.emit(energy, max_energy)

func tear_clothes() -> void:
	match clothes_state:
		ClothesState.NORMAL:
			clothes_state = ClothesState.TORN

		ClothesState.TORN:
			clothes_state = ClothesState.REMOVED

		ClothesState.REMOVED:
			return

func put_on_clothes() -> void:
	clothes_state = ClothesState.NORMAL

func remove_clothes() -> void:
	clothes_state = ClothesState.REMOVED

func strip_panties() -> void:
	panties_removed = true

func put_panties_on() -> void:
	panties_removed = false

func _on_clothes_state_changed() -> void:
	appearance_changed.emit()
	_update_clothes_hardware()

func _on_panties_state_changed() -> void:
	appearance_changed.emit()
	_update_clothes_hardware()

func apply_sex(
	sex_type: SexData,
	value: int,
	enemy: EnemyState = null,
	initiator: SexInitiator = SexInitiator.NONE
) -> void:
	var new_sex: bool = (
		!in_sex
		or current_sex != sex_type
	)
	
	if new_sex:
		in_sex = true
		current_sex = sex_type
		sex_state = value
		active_enemy = enemy
		sex_initiator = initiator
		
		sex_changed.emit(current_sex, sex_state)
	else:
		sex_initiator = initiator
		change_sex_state(value)

	DebugLogger.info(
		"Sex changed: %s" % sex_type.id
	)

func exit_sex() -> void:
	if !in_sex:
		return

	in_sex = false
	current_sex = null
	sex_state = 0
	active_enemy = null
	sex_initiator = SexInitiator.NONE

	sex_exited.emit()

func is_orgasming() -> bool:
	return orgasm_skip_left > 0

func start_orgasm() -> void:
	orgasm_skip_left = 2
	energy = 0
	change_max_lp(1)
	energy_changed.emit(energy, max_energy)
	orgasm.emit()

func consume_orgasm_turn() -> void:
	if orgasm_skip_left <= 0:
		return

	orgasm_skip_left -= 1

	if orgasm_skip_left == 0:
		orgasm_over.emit()

func change_sex_state(amount: int) -> void:
	if amount == 0 or !in_sex:
		return
	
	sex_state = maxi(sex_state + amount, 0)
	
	if sex_state > current_sex.max_state:
		sex_state = current_sex.return_state
	
	if sex_state == 0:
		exit_sex()
		return
	
	sex_changed.emit(current_sex, sex_state)

func get_hardware(id: String) -> HardwareData:
	for effect: HardwareData in hardware:
		if effect.id == id:
			return effect

	return null

func has_hardware(id: String) -> bool:
	return get_hardware(id) != null

func add_hardware(effect: HardwareData) -> void:
	if effect == null:
		return
	
	if !effect.stackable and has_hardware(effect.id):
		return
	
	if (
		effect.stackable
		and effect.max_stacks > 0
		and get_hardware_count(effect.id) >= effect.max_stacks
	):
		return
	
	hardware.append(effect)
	hardware_changed.emit()

func remove_hardware(id: String) -> void:
	for i: int in range(hardware.size() - 1, -1, -1):
		if hardware[i].id != id:
			continue

		hardware.remove_at(i)
		hardware_changed.emit()
		return

func remove_all_hardware(id: String) -> void:
	var removed: bool = false

	for i: int in range(hardware.size() - 1, -1, -1):
		if hardware[i].id != id:
			continue

		hardware.remove_at(i)
		removed = true

	if removed:
		hardware_changed.emit()

func get_hardware_count(id: String) -> int:
	var count: int = 0

	for hardware_data: HardwareData in hardware:
		if hardware_data.id == id:
			count += 1

	return count

func apply_after_combat_hardware() -> void:
	for item: HardwareData in hardware:
		if item.hp_after_combat > 0:
			heal(item.hp_after_combat)
		elif item.hp_after_combat < 0:
			take_damage(-item.hp_after_combat)
		if item.lp_after_combat > 0:
			take_lp(item.lp_after_combat)
		elif item.lp_after_combat < 0:
			reduce_lp(-item.lp_after_combat)

func end_orgasm() -> void:
	if !is_orgasming():
		return

	orgasm_skip_left = 0
	orgasm_over.emit()

func _update_clothes_hardware() -> void:
	match clothes_state:
		ClothesState.NORMAL:
			remove_hardware("torn_clothes")
			remove_hardware("nude")
		ClothesState.TORN:
			remove_hardware("nude")
			add_hardware(preload("res://tres/hardware/torn_clothes.tres"))
		ClothesState.REMOVED:
			remove_hardware("torn_clothes")
			add_hardware(preload("res://tres/hardware/nude.tres"))
	
	if panties_removed:
		add_hardware(preload("res://tres/hardware/exposed_pussy.tres"))
	else:
		remove_hardware("exposed_pussy")
