class_name RunManager
extends Node

signal run_won
signal character_changed(id: String)
signal run_started(player: PlayerState)

@onready var map: Map = $"../Map"
@onready var map_generator: MapGenerator = $"../Map/MapGenerator"
@onready var act_transition: ActTransition = $"../ActTransition"
@onready var hud: Control = $"../PlayerHud"
@onready var combat_scene: Combat = $"../Combat"
@onready var event_combat_scene: EventCombat = $"../EventCombat"
@onready var debug_combat_scene: DebugCombat = $"../DebugCombat"
@onready var deck: Deck = $"../Deck"
@onready var card_hand: Control = $"../Combat/CardHand"
@onready var reward_menu: RewardMenu = $"../RewardMenu"
@onready var event_menu: Event = $"../Event"
@onready var standart_sprite: StandardSprite = $"../PlayerHud/PlayerSprite/VisualRoot/StandartSprite"
@onready var player_sprite: PlayerSprite = $"../PlayerHud/PlayerSprite"
@onready var sex_animation: SexAnimation = $"../PlayerHud/PlayerSprite/VisualRoot/SexAnimation"

const MAX_ACTS: int = 3

var difficulty: String = "normal"
var mode: String = "normal"
var character_selected: CharacterData
var player: PlayerState
var act: int = 1
var is_infinite: bool
var is_transitioning: bool
var current_location_type: String
var enemy_battles_completed: int

var event_win_step: StringName
var event_lose_step: StringName

func _ready() -> void:
	combat_scene.combat_won.connect(_on_combat_won)
	reward_menu.card_picked.connect(_on_reward_card_picked)
	reward_menu.continue_pressed.connect(_on_reward_continue_pressed)
	event_menu.event_finished.connect(_leave_event)
	event_menu.start_event_combat.connect(_start_event_combat)
	event_combat_scene.event_combat_won.connect(_event_combat_won)
	event_combat_scene.event_combat_lost.connect(_event_combat_lost)
	debug_combat_scene.debug_combat_won.connect(_on_debug_combat_won)
	debug_combat_scene.debug_combat_lost.connect(_on_debug_combat_lost)

func start_run() -> void:
	act = 1
	enemy_battles_completed = 0
	is_transitioning = false

	var character_id: String = "none"
	character_id = character_selected.id

	DebugLogger.info(
		"Run started: mode=%s, difficulty=%s, act=%d, endless=%s, character=%s"
		% [mode, difficulty, act, is_infinite, character_id]
	)
	
	player = PlayerState.new()
	
	player.setup(character_selected)
	player_sprite.setup_player_state(player)
	hud.setup(player)
	deck.setup(player.deck)
	player.card_added.connect(_on_player_deck_changed)
	player.card_removed.connect(_on_player_deck_changed)
	
	map.generate_map(mode, difficulty, act)
	map.visible = true
	DiscordActivity.set_run_status(act, mode, difficulty)
	AudioManager.play_music(&"start_run")
	run_started.emit(player)

func _on_map_act_completed() -> void:
	if is_transitioning:
		DebugLogger.warning("Ignored duplicate act completion while transitioning")
		return
	
	is_transitioning = true
	
	if !is_infinite and act >= MAX_ACTS:
		DebugLogger.info("Run won after act %d" % act)
		run_won.emit()
		is_transitioning = false
		return
	
	var previous_act: int = act
	act += 1
	
	DebugLogger.info("Act advanced: %d -> %d" % [previous_act, act])
	DiscordActivity.set_run_status(act, mode, difficulty)
	
	act_transition.play_act(act)
	map.generate_map(mode, difficulty, act)
	
	is_transitioning = false
	player.heal(player.max_hp)
	player.reduce_lp(player.max_lp)

func select_character(character: CharacterData) -> void:
	if character == null:
		DebugLogger.warning("Cannot select null character")
		return

	character_selected = character
	character_changed.emit(character.id)
	DebugLogger.info("Character selected: %s" % character.id)

func _on_location_selected(location_type: String) -> void:
	current_location_type = location_type
	match location_type:
		"shop":
			_start_event("shop")
		"rest":
			_start_event("rest")
		"hardware":
			_start_event("hardware")
		"event":
			_start_event("random")
		"mini_boss":
			_start_mini_boss_combat()
		"enemy":
			_start_enemy_combat()
		"boss":
			_on_map_act_completed()
		"event":
			pass

func _start_mini_boss_combat() -> void:
	var pool: Array[EnemyData] = EnemyLibrary.get_pool(
		EnemyData.EnemyType.MINI_BOSS
	)
	
	_start_combat([pool.pick_random()])

func _start_enemy_combat() -> void:
	var pool_type: EnemyData.EnemyType = EnemyData.EnemyType.NORMAL
	
	if enemy_battles_completed < 3:
		pool_type = EnemyData.EnemyType.STARTING
	
	var pool: Array[EnemyData] = EnemyLibrary.get_pool(pool_type)
	var config: Dictionary = get_config()
	var enemy_count: int = _get_enemy_count(config)
	
	var combat_enemies: Array[EnemyData] = _pick_enemies(
		pool,
		enemy_count
	)
	
	_start_combat(combat_enemies)

func _start_event_combat(
	enemy: EnemyData,
	win_step: StringName,
	lose_step: StringName,
	condition_list: Array[EventCondition],
	player_lose_move: EnemyMove
) -> void:
	event_win_step = win_step
	event_lose_step = lose_step
	
	map.hide()
	event_combat_scene.show()
	event_menu.hide()
	event_combat_scene.start_combat(
		[enemy], 
		player, 
		condition_list, 
		player_lose_move
	)

func start_debug_combat(enemy: EnemyData) -> void:
	map.hide()
	debug_combat_scene.show()
	debug_combat_scene.start_combat([enemy], player)

func _start_combat(combat_enemies: Array[EnemyData]) -> void:
	map.hide()
	combat_scene.show()
	event_menu.hide()
	combat_scene.start_combat(combat_enemies, player)

func _get_enemy_count(config: Dictionary) -> int:
	var groups: Dictionary = config.get("enemy_groups", {})

	var rule: Dictionary = groups.get(
		act,
		{
			"minimum": 1,
			"extra_chances": []
		}
	)

	var count: int = int(rule.get("minimum", 1))
	var extra_chances: Array = rule.get("extra_chances", [])

	for chance in extra_chances:
		if randi_range(1, 100) <= int(chance):
			count += 1

	return clampi(count, 1, 3)

func _pick_enemies(
	pool: Array[EnemyData],
	count: int
) -> Array[EnemyData]:
	var result: Array[EnemyData] = []

	if pool.is_empty():
		DebugLogger.warning("Enemy list is empty")
		return result

	var available: Array[EnemyData] = pool.duplicate()

	while result.size() < count:
		if available.is_empty():
			available = pool.duplicate()

		var index: int = randi_range(0, available.size() - 1)
		result.append(available[index])
		available.remove_at(index)

	return result

func get_config() -> Dictionary:
	return map_generator.get_config(mode, difficulty)

func _get_combat_reward_pool() -> Array[CardData]:
	var pool_type: CardData.CardType

	if current_location_type == "boss":
		pool_type = CardData.CardType.BOSS_REWARD
	else:
		pool_type = CardData.CardType.NORMAL_REWARD

	return CardLibrary.get_reward_pool(pool_type)

func _on_combat_won() -> void:
	combat_scene.hide()
	
	if current_location_type == "enemy":
		enemy_battles_completed += 1
	
		DebugLogger.info(
			"Enemy battles completed: %d/3" % enemy_battles_completed
		)

	var gold_reward: int = _get_combat_gold_reward()

	if gold_reward > 0:
		player.change_gold(gold_reward)

		DebugLogger.info(
			"Gold reward received: %d"
			% gold_reward
		)

	var reward_pool: Array[CardData] = (
		_get_combat_reward_pool()
	)

	reward_menu.open_reward(
		reward_pool,
		3
	)
	
	AudioManager.play_music(&"run")

func _on_reward_card_picked(card: CardData) -> void:
	if card == null:
		return
	
	player.add_card(card)
	
	DebugLogger.info(
		"Card added to player deck: %s"
		% card.resource_path
	)

func _on_reward_continue_pressed() -> void:
	map.visible = true
	reward_menu.visible = false
	current_location_type = ""

func _get_combat_gold_reward() -> int:
	match current_location_type:
		"enemy":
			return randi_range(15, 40)
		"mini_boss":
			return randi_range(25, 60)
		"boss":
			return randi_range(50, 125)
		_:
			DebugLogger.warning(
				"Unknown reward location type: %s"
				% current_location_type
			)
			return 0

func _on_player_deck_changed(_card: CardData) -> void:
	deck.setup(player.deck)

func _start_event(label: String) -> void:
	var event: EventData = null

	match label:
		"shop":
			event = get_event(&"shop")
		"rest":
			event = get_event(&"rest")
		"hardware":
			event = get_event(&"hardware")
		"random":
			event = get_random_event()
		_:
			DebugLogger.warning("Unknown event label: %s" % label)
			return

	_open_event(event)

func get_event(event_id: StringName) -> EventData:
	var events_list: Dictionary[StringName, EventData] = EventLibrary.events
	if !events_list.has(event_id):
		DebugLogger.error("Event not found: %s" % event_id)
		return null

	return events_list[event_id]

func get_random_event() -> EventData:
	var events_list: Dictionary[StringName, EventData] = EventLibrary.events
	var event_list: Array[EventData]
	
	for event: EventData in events_list.values():
		if event.id == &"shop" or event.id == &"rest" or event.id == &"hardware":
			continue
		event_list.append(event)

	return event_list.pick_random()

func _leave_event() -> void:
	event_menu.hide()
	map.show()
	AudioManager.play_music(&"run")

func _open_event(event: EventData) -> void:
	if event == null:
		return

	if player == null:
		DebugLogger.warning("Cannot open event without active player")
		return

	event_menu.setup(player, event)

	map.hide()
	event_menu.show()

func open_debug_event(event: EventData) -> void:
	_open_event(event)

func _event_combat_won() -> void:
	event_combat_scene.hide()
	event_menu.show()
	event_menu.go_to_step(event_win_step)

func _event_combat_lost() -> void:
	event_combat_scene.hide()
	event_menu.show()
	event_menu.go_to_step(event_lose_step)

func _on_debug_combat_won() -> void:
	debug_combat_scene.hide()
	map.show()
	AudioManager.play_music(&"run")

func _on_debug_combat_lost() -> void:
	debug_combat_scene.hide()
	map.show()
	player.heal(player.max_hp)
	player.reduce_lp(player.max_lp)
	AudioManager.play_music(&"run")
