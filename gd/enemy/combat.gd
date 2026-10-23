class_name Combat
extends Control

enum COMBAT_RESULT {
	WIN,
	LOSS
}

signal combat_won
signal combat_lost

@export var enemy_scene: PackedScene
@onready var enemies_root: Node2D = %EnemiesRoot
@onready var player_sprite: PlayerSprite = $"../PlayerHud/PlayerSprite"
@onready var standart_sprite: StandardSprite = $"../PlayerHud/PlayerSprite/VisualRoot/StandartSprite"
@onready var combat_hud: CombatHud = $"CombatHud"
@onready var card_hand: CardHand = $"CardHand"
@onready var sex_animation: SexAnimation = $"../PlayerHud/PlayerSprite/VisualRoot/SexAnimation"

const ENEMY_SCALE: float = 2.5
const ENEMY_DELAY: float = 0.3

var targeted_enemy: EnemyView
var targeted_player: PlayerSprite

var player: PlayerState

var draw_pile: Array[CardData]
var discard_pile: Array[CardData]

var is_player_turn: bool
var combat_finished: bool

var played_cards_this_turn: Dictionary[String, int] 
var drawn_cards_this_turn: Dictionary[String, int] 

func start_combat(
	enemies: Array[EnemyData],
	player_state: PlayerState,
	_condition_list: Array[EventCondition] = [],
	_player_lose_move: EnemyMove = null
) -> void:
	combat_finished = false
	player = player_state
	played_cards_this_turn = {}
	
	if !player.orgasm.is_connected(_on_player_orgasm):
		player.orgasm.connect(_on_player_orgasm)
	
	if !player.sex_exited.is_connected(_on_player_sex_exited):
		player.sex_exited.connect(_on_player_sex_exited)
	
	if !player.energy_changed.is_connected(_on_player_energy_changed):
		player.energy_changed.connect(_on_player_energy_changed)
	
	_setup_card_piles()
	clear_enemies()
	
	var count: int = enemies.size()
	if count == 0:
		return
	
	var step: float = 1216 / float(count)
	
	for i in count:
		var enemy_state: EnemyState = EnemyState.new()
		enemy_state.setup(enemies[i])
		enemy_state.effects_changed.connect(_refresh_enemy_intents)
		enemy_state.orgasm.connect(_on_enemy_orgasm.bind(enemy_state))

		enemy_state.orgasm_over.connect(_on_enemy_orgasm_over.bind(enemy_state))
		
		var enemy_view: EnemyView = enemy_scene.instantiate()
		enemies_root.add_child(enemy_view)
		
		enemy_view.position = Vector2(
			step * (i + 0.5) + 30,
			460
		)
		
		enemy_view.setup(enemy_state, ENEMY_SCALE)
		enemy_view.update_intent(
			enemy_state.get_current_move(player),
			player
		)
	
	combat_hud.setup(player)
	start_player_turn()
	AudioManager.play_music(&"battle")

func draw_cards(amount: int) -> void:
	var drawn: int = 0
	var blocked_cards: Array[CardData] = []

	while drawn < amount:
		if draw_pile.is_empty():
			_reshuffle_discard()

		if draw_pile.is_empty():
			break

		var card: CardData = draw_pile.pop_back()

		if !can_draw_card(card):
			blocked_cards.append(card)
			continue

		register_card_draw(card)
		card_hand.add_card(card)
		drawn += 1

	discard_pile.append_array(blocked_cards)

	_update_pile_counts()
	_on_player_energy_changed()
	card_hand.update_card_availability()

func _setup_card_piles() -> void:
	draw_pile = player.deck.duplicate()
	draw_pile.shuffle()

	discard_pile.clear()
	card_hand.clear_hand()

	_update_pile_counts()

func _reshuffle_discard() -> void:
	if discard_pile.is_empty():
		return

	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()

	discard_pile.clear()

func _update_pile_counts() -> void:
	combat_hud.change_pile_counts(
		draw_pile.size(),
		discard_pile.size()
	)

func start_player_turn() -> void:
	is_player_turn = true
	if !player.is_orgasming():
		player.reset_energy()
	if player.has_hardware("brace"):
		player.remove_hardware("brace")
	combat_hud.set_end_turn_enabled(true)
	
	drawn_cards_this_turn.clear()
	draw_cards(5)
	card_hand.update_card_availability()

func end_player_turn() -> void:
	if !is_player_turn:
		return

	var was_orgasming: bool = player.is_orgasming()

	is_player_turn = false
	combat_hud.set_end_turn_enabled(false)

	var remaining_cards: Array[CardData] = card_hand.take_all_cards()
	discard_pile.append_array(remaining_cards)

	_update_pile_counts()

	await perform_enemy_turn()
	
	if combat_finished:
		return

	_process_card_turn_end_effects()

	if was_orgasming:
		player.consume_orgasm_turn()
		_refresh_enemy_intents()

	if player.hp > 0:
		start_player_turn()

func perform_enemy_actions(enemy_view: EnemyView) -> void:
	var enemy: EnemyState = enemy_view.enemy_state

	if enemy.is_disabled():
		await enemy_view.play_skip_turn()

		enemy.tick_effects()

		enemy_view.update_intent(
			enemy.get_current_move(player),
			player
		)

		return

	enemy.tick_effects()

	var move: EnemyMove = enemy.get_current_move(player)
	
	enemy.advance_move(player)
	
	await _perform_enemy_move(enemy_view, move)
	
	enemy_view.update_intent(
		enemy.get_current_move(player),
		player
	)

func _perform_enemy_move(
	enemy_view: EnemyView,
	move: EnemyMove
) -> void:
	if move == null:
		return

	for action: MoveData in move.actions:
		_execute_enemy_action(enemy_view, action)
		AudioManager.play_sound(&"hit")

		if player.hp <= 0:
			return

		await get_tree().create_timer(0.15).timeout

func perform_enemy_turn() -> void:
	var alive_enemies: Array[EnemyView] = []

	for child: Node in enemies_root.get_children():
		var enemy_view: EnemyView = child

		if enemy_view == null:
			continue

		var enemy: EnemyState = enemy_view.enemy_state

		if enemy == null or enemy.is_dead():
			continue

		alive_enemies.append(enemy_view)

	for i: int in alive_enemies.size():
		await perform_enemy_actions(alive_enemies[i])

		if player.hp <= 0:
			_finish_combat(COMBAT_RESULT.LOSS)
			return

		if i < alive_enemies.size() - 1:
			await get_tree().create_timer(ENEMY_DELAY).timeout

func _execute_enemy_action(
	enemy_view: EnemyView,
	action: MoveData
) -> void:
	var enemy: EnemyState = enemy_view.enemy_state
	
	if action.damage > 0:
		if player.has_hardware("brace"):
			player.remove_hardware("brace")
		else:
			player.take_damage(action.damage)
			player_sprite.play_damage_hit()
	
	if action.pp > 0:
		player.take_lp(action.pp)
		player_sprite.play_lp_hit()
	
	if action.self_heal > 0:
		enemy.heal(action.self_heal)
	
	if action.self_pp > 0:
		enemy.take_pp(action.self_pp)
	
	if action.card_to_add != null and action.cards_count > 0:
		add_temporary_card_to_draw_pile(
			action.card_to_add,
			action.cards_count
		)
	
	if action.sex_value > 0:
		_apply_sex_action(enemy_view, action)
	
	if action.exit_sex:
		_exit_sex()
	
	if action.tear_clothes:
		_tear_player_clothes()
	
	if action.remove_clothes:
		_remove_player_clothes()
	
	if action.strip_panties:
		_strip_player_panties()
	
	enemy_view.play_cast()

func clear_enemies() -> void:
	for child: Node in enemies_root.get_children():
		child.queue_free()

func get_enemy_target(mouse: Vector2) -> EnemyView:
	if targeted_enemy != null:
		if targeted_enemy.contains_mouse_extended(mouse):
			return targeted_enemy
		
		targeted_enemy.set_selected(false)
		targeted_enemy = null
	
	for child: Node in enemies_root.get_children():
		var enemy: EnemyView = child
		
		if enemy != null and enemy.contains_mouse(mouse):
			targeted_enemy = enemy
			targeted_enemy.set_selected(true)
			return targeted_enemy
	
	return null

func clear_enemy_target() -> void:
	if targeted_enemy == null:
		return

	targeted_enemy.set_selected(false)
	targeted_enemy = null

func add_temporary_card_to_draw_pile(
	card: CardData,
	amount: int = 1,
	shuffle: bool = true
) -> void:
	if card == null or amount <= 0:
		return

	for i: int in amount:
		draw_pile.append(card)

	if shuffle:
		draw_pile.shuffle()

	_update_pile_counts()

func get_player_target(mouse: Vector2) -> PlayerSprite:
	if standart_sprite == null:
		DebugLogger.warning("player_view is null")
		return null
	
	if targeted_player != null:
		if targeted_player.contains_mouse_extended(mouse):
			return targeted_player
		
		targeted_player.set_selected(false)
		targeted_player = null
	
	if player_sprite.contains_mouse(mouse):
		targeted_player = player_sprite
		targeted_player.set_selected(true)
		return targeted_player
	
	return null

func clear_player_target() -> void:
	if targeted_player == null:
		return
	
	targeted_player.set_selected(false)
	targeted_player = null

func try_play_card(card_view: CardView) -> bool:
	var card: CardData = card_view.card_data

	if targeted_enemy != null:
		if !card.can_target_enemy():
			return false

		var enemy: EnemyState = targeted_enemy.enemy_state

		if !can_play_card(card):
			return false

		var spent_energy: int = get_card_energy_cost(
			card,
			enemy
		)

		var preview: CardPreview = card_view.get_preview(
			self,
			enemy
		)

		if !player.spend_energy(spent_energy):
			return false

		_play_card_on_enemy(
			card,
			targeted_enemy,
			spent_energy,
			preview
		)

		_discard_played_card(card_view)
		return true

	if targeted_player != null:
		if !card.can_target_self():
			return false

		if !can_play_card(card):
			return false
		
		var spent_energy: int = get_card_energy_cost(card)
		var preview: CardPreview = get_card_preview(card)
		
		if !player.spend_energy(spent_energy):
			return false
		
		_play_card_on_player(
			card,
			preview,
			spent_energy
		)
		
		_discard_played_card(card_view)
		return true

	return false

func _discard_played_card(card_view: CardView) -> void:
	var card: CardData = card_view.card_data
	
	if !card.exhaust:
		discard_pile.append(card)
	
	card_view.queue_free()
	
	_update_pile_counts()
	card_hand.update_card_availability()

func _play_card_on_enemy(
	card: CardData,
	enemy_view: EnemyView,
	spent_energy: int,
	preview: CardPreview
) -> void:
	var enemy: EnemyState = enemy_view.enemy_state

	if preview.damage > 0:
		enemy.take_damage(preview.damage)
		enemy_view.play_damage_hit()

	if preview.pp > 0:
		enemy.take_pp(preview.pp)
		enemy_view.play_pp_hit()
	elif preview.pp < 0:
		enemy.reduce_pp(abs(preview.pp))

	if preview.lp > 0:
		player.add_lp(preview.lp)
	elif preview.lp < 0:
		player.reduce_lp(-preview.lp)
	
	if preview.hp > 0:
		player.heal(preview.hp)
	elif preview.hp < 0:
		player.take_damage(abs(preview.hp))

	if card.sex_type != null:
		player.apply_sex(
			card.sex_type,
			card.sex_state_change,
			enemy,
			PlayerState.SexInitiator.PLAYER
		)

	elif card.sex_state_change != 0:
		if player.in_sex and player.active_enemy == enemy:
			player.change_sex_state(card.sex_state_change)

	_apply_card_effects(
		card,
		enemy,
		spent_energy,
		preview
	)
	
	if player.is_orgasming():
		player.set_energy(0)
	
	register_card_play(card)

	_handle_enemy_death(enemy_view)
	
	_on_player_energy_changed()
	AudioManager.play_sound(&"hit")

func _play_card_on_player(
	card: CardData,
	card_preview: CardPreview,
	spent_energy: int
) -> void:
	if card.sex_state_change != 0:
		if player.in_sex:
			player.change_sex_state(card.sex_state_change)
	
	if card_preview.hp > 0:
		player.heal(card_preview.hp)
	elif card_preview.hp < 0:
		player.take_damage(card_preview.hp)
	
	if card_preview.lp > 0:
		player.add_lp(card_preview.lp)
	elif card_preview.lp < 0:
		player.reduce_lp(abs(card_preview.lp))
	
	_apply_card_effects(
		card,
		null,
		spent_energy
	)
	
	if player.is_orgasming():
		player.set_energy(0)
	
	register_card_play(card)
	_on_player_energy_changed()

func _on_combat_hud_end_turn_pressed() -> void:
	await end_player_turn()

func can_play_card(card: CardData) -> bool:
	if !is_player_turn:
		return false
	if player.energy < get_card_energy_cost(card):
		return false
	if (
		card.works_only_in
		and (
			!player.in_sex
			or player.current_sex.sex_type != card.works_only_in
		)
	):
		return false

	# Потом сюда постепенно добавишь:
	#
	# if card запрещена в текущем mode:
	#     return false
	#
	# if card нельзя использовать в sex:
	#     return false
	#
	# if card требует определённый status:
	#     return false
	#
	# if card once_per_turn и уже использовалась:
	#     return false
	#
	# if card требует одежду / отсутствие одежды:
	#     return false

	return true

func _apply_sex_action(
	enemy_view: EnemyView,
	action: MoveData
) -> void:
	player.apply_sex(
		action.sex_type,
		action.sex_value,
		enemy_view.enemy_state,
		PlayerState.SexInitiator.ENEMY
	)

func _exit_sex() -> void:
	player.exit_sex()

func _tear_player_clothes() -> void:
	player.tear_clothes()

func _remove_player_clothes() -> void:
	player.remove_clothes()

func _strip_player_panties() -> void:
	player.strip_panties()

func _on_player_orgasm() -> void:
	for child: Node in enemies_root.get_children():
		var enemy_view: EnemyView = child

		if enemy_view == null:
			continue

		var enemy: EnemyState = enemy_view.enemy_state

		if enemy == null or enemy.is_dead():
			continue

		enemy.player_orgasm_move_index = 0

	_refresh_enemy_intents()

func _refresh_enemy_intents() -> void:
	for child: Node in enemies_root.get_children():
		var enemy_view: EnemyView = child

		if enemy_view == null:
			continue

		var enemy: EnemyState = enemy_view.enemy_state

		if enemy == null or enemy.is_dead():
			continue

		enemy_view.update_intent(
			enemy.get_current_move(player),
			player
		)

func _on_player_sex_exited() -> void:
	for child: Node in enemies_root.get_children():
		var enemy_view: EnemyView = child

		if enemy_view == null:
			continue

		enemy_view.update_intent(
			enemy_view.enemy_state.get_current_move(player),
			player
		)

func _check_victory() -> void:
	if combat_finished:
		return

	for child: Node in enemies_root.get_children():
		var enemy_view: EnemyView = child
		if enemy_view == null:
			continue

		var enemy: EnemyState = enemy_view.enemy_state
		if enemy != null and !enemy.is_dead():
			return

	DebugLogger.info("Combat won")
	_finish_combat(COMBAT_RESULT.WIN)

func _handle_enemy_death(enemy_view: EnemyView) -> void:
	if !is_instance_valid(enemy_view):
		return

	var enemy: EnemyState = enemy_view.enemy_state

	if enemy == null or !enemy.is_dead():
		return

	if targeted_enemy == enemy_view:
		targeted_enemy.set_selected(false)
		targeted_enemy = null

	if player.in_sex and player.active_enemy == enemy:
		player.exit_sex()

	enemy_view.queue_free()
	_check_victory()

func _on_enemy_orgasm(enemy: EnemyState) -> void:
	if !player.in_sex:
		return

	if player.active_enemy != enemy:
		return

	sex_animation.show_orgasm()

func _on_enemy_orgasm_over(enemy: EnemyState) -> void:
	if !player.in_sex:
		return

	if player.active_enemy != enemy:
		return

	#sex_animation.finish_orgasm(
		#player.sex_state
	#)

func _apply_card_effects(
	card: CardData,
	enemy: EnemyState = null,
	spent_energy: int = 0,
	preview: CardPreview = null
) -> void:
	for effect: CardEffect in card.card_effects:
		if effect == null:
			continue
	
		effect.apply(
			self,
			card,
			enemy,
			spent_energy,
			preview
		)

func get_card_preview(
	card: CardData,
	enemy: EnemyState = null
) -> CardPreview:
	var preview: CardPreview = card.get_base_preview()
	
	for effect: CardEffect in card.card_effects:
		if effect == null:
			continue
		
		preview.energy_cost = effect.set_energy_cost(
			self,
			preview
		)
	
	for effect: CardEffect in card.card_effects:
		if effect == null:
			continue
		
		preview.damage = effect.set_damage(
			self,
			preview,
			enemy
		)
		
		preview.pp = effect.set_pp(
			self,
			preview,
			enemy
		)
		
		preview.lp = effect.set_lp(
			self,
			preview,
			enemy
		)
		
		preview.hp = effect.set_hp(
			self,
			preview,
			enemy
		)
		
	for effect: CardEffect in card.card_effects:
		if effect == null:
			continue
		
		effect.apply_limits(preview)
	
	return preview

@warning_ignore("unused_parameter")
func get_card_energy_cost(
	card: CardData,
	enemy: EnemyState = null
) -> int:
	var preview: CardPreview = card.get_base_preview()
	
	for effect: CardEffect in card.card_effects:
		if effect == null:
			continue
		
		preview.energy_cost = effect.set_energy_cost(
			self,
			preview
		)
	
	return maxi(preview.energy_cost, 0)

func register_card_play(card: CardData) -> void:
	played_cards_this_turn[card.id] = (
		played_cards_this_turn.get(card.id, 0) + 1
	)

func get_card_plays_this_turn(card: CardData) -> int:
	return played_cards_this_turn.get(card.id, 0)

func _process_card_turn_end_effects() -> void:
	var processed: Dictionary[String, bool] = {}

	for card: CardData in player.deck:
		if processed.has(card.id):
			continue

		processed[card.id] = true

		for effect: CardEffect in card.card_effects:
			if effect == null:
				continue

			effect.on_player_turn_end(
				self,
				card
			)

	played_cards_this_turn.clear()

@warning_ignore("unused_parameter")
func _on_player_energy_changed(energy: int = 0, max_energy: int = 0) -> void:
	for card_view: CardView in card_hand.get_card_views():
		card_view.invalidate_preview()

		card_view.set_energy_cost(
			get_card_energy_cost(card_view.card_data)
		)

		card_view._set_description(
			card_view.card_data
		)

	card_hand.update_card_availability()

func _process_card_combat_end_effects() -> void:
	var processed: Dictionary[String, bool] = {}

	for card: CardData in player.deck:
		if processed.has(card.id):
			continue

		processed[card.id] = true

		for effect: CardEffect in card.card_effects:
			if effect == null:
				continue

			effect.on_combat_end(self, card)

func _finish_combat(result: COMBAT_RESULT) -> void:
	if combat_finished:
		return
	
	combat_finished = true
	is_player_turn = false
	combat_hud.set_end_turn_enabled(false)
	
	_process_card_combat_end_effects()
	
	clear_enemy_target()
	clear_player_target()
	
	match result:
		COMBAT_RESULT.WIN:
			combat_won.emit()
		COMBAT_RESULT.LOSS:
			combat_lost.emit()

func register_card_draw(card: CardData) -> void:
	drawn_cards_this_turn[card.id] = (
		drawn_cards_this_turn.get(card.id, 0) + 1
	)

func get_card_draws_this_turn(card: CardData) -> int:
	return drawn_cards_this_turn.get(card.id, 0)

func can_draw_card(card: CardData) -> bool:
	for effect: CardEffect in card.card_effects:
		if effect is HandLimitEffect:
			var limit: HandLimitEffect = effect

			if !limit.can_draw(self, card):
				return false

	return true
