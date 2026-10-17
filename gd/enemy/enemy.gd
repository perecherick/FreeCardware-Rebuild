class_name EnemyView
extends Node2D

@onready var visual: Node2D = %Visual
@onready var sprite: Sprite2D = %Sprite
@onready var enemy_name: Label = %Name
@onready var hp_label: Label = %HP
@onready var pp_label: Label = %PP
@onready var intent_text: Label = %Intend
@onready var statuses_label: RichTextLabel = %Statuses
@onready var selection_area: Control = %SelectionArea
@onready var selection: Sprite2D = %Selection
@onready var combat_animator: CombatVisualAnimator = %CombatVisualAnimator

var enemy_state: EnemyState

@warning_ignore("shadowed_variable_base_class")
func setup(enemy: EnemyState, scale: float = 1.0) -> void:
	enemy_state = enemy
	_set_sprite(enemy.data.texture)
	_set_name(enemy.data.name)
	_set_scale(scale)
	change_hp(enemy.hp, enemy.max_hp)
	change_pp(enemy.pp, enemy.max_pp)
	set_statuses(enemy.effects)
	
	enemy.hp_changed.connect(change_hp)
	enemy.pp_changed.connect(change_pp)
	enemy.effects_changed.connect(_update_statuses)

func _set_sprite(texture: Texture) -> void:
	sprite.texture = texture

func _set_name(n: String) -> void:
	enemy_name.text = tr(n)

func set_statuses(effects: Array[EffectState]) -> void:
	statuses_label.clear()
	for effect: EffectState in effects:
		var data: EffectData = effect.data
		var suffix: String = ""
		if data.duration_mode == EffectData.DurationMode.TURNS:
			suffix = " X%d" % effect.turns_left
		elif effect.stacks > 1:
			suffix = " X%d" % effect.stacks
		statuses_label.append_text(
			"[color=%s]%s%s[/color]\n"
			% [
				data.color,
				tr(data.name),
				suffix
			]
		)

func change_hp(hp: int, max_hp: int) -> void:
	hp_label.text = "%d/%dHP" % [hp, max_hp]

func change_pp(pp: int, max_pp: int) -> void:
	pp_label.text = "%d/%dPP" % [pp, max_pp]

func set_intend_text(text: String) -> void:
	intent_text.text = tr(text)

@warning_ignore("shadowed_variable_base_class")
func _set_scale(scale: float) -> void:
	visual.scale = Vector2(scale, scale)

func _on_area_2d_mouse_entered() -> void:
	enemy_name.visible = true

func _on_area_2d_mouse_exited() -> void:
	enemy_name.visible = false

func contains_mouse(mouse: Vector2) -> bool:
	return selection_area.get_global_rect().has_point(mouse)

func contains_mouse_extended(mouse: Vector2, margin: float = 80.0) -> bool:
	return selection_area.get_global_rect().grow(margin).has_point(mouse)

func get_card_target_position() -> Vector2:
	var rect: Rect2 = selection_area.get_global_rect()

	return Vector2(
		rect.end.x + 20.0,
		rect.get_center().y
	)

func set_selected(value: bool) -> void:
	selection.visible = value

func update_intent(move: EnemyMove, player: PlayerState) -> void:
	var disable_effect: EffectState = enemy_state.get_disable_effect()

	if disable_effect != null:
		intent_text.text = tr(
			disable_effect.data.disable_intent
		)
		return

	if move == null:
		intent_text.text = ""
		return
	
	if move == null:
		intent_text.text = ""
		return
	
	var parts: Array[String] = []
	var previous_type: String = ""
	var i: int = 0
	
	while i < move.actions.size():
		var effects: Array[Dictionary] = _get_action_effects(
			move.actions[i],
			player
		)
		
		if effects.is_empty():
			i += 1
			continue
		
		if effects.size() > 1:
			var mixed_parts: Array[String] = []
			
			for effect: Dictionary in effects:
				mixed_parts.append(
					"%s %d" % [
						effect["type"],
						effect["value"]
					]
				)
			
			parts.append(" + ".join(mixed_parts))
			previous_type = ""
			i += 1
			continue
		
		var effect: Dictionary = effects[0]
		var count: int = 1
		
		while i + count < move.actions.size():
			var next_effects: Array[Dictionary] = _get_action_effects(
				move.actions[i + count],
				player
			)
			
			if next_effects.size() != 1:
				break
				
			if (
				next_effects[0]["type"] != effect["type"]
				or next_effects[0]["value"] != effect["value"]
			):
				break
			
			count += 1
		
		var prefix: String = ""
		
		if previous_type != effect["type"]:
			prefix = "%s " % effect["type"]
		
		var part: String = "%s%d" % [
			prefix,
			effect["value"]
		]
		
		if count > 1:
			part += "×%d" % count
		
		parts.append(part)
		previous_type = effect["type"]
		i += count
	
	intent_text.text = "%s\n%s" % [
		tr(move.intent),
		" → ".join(parts)
	]

func _get_action_effects(
	action: MoveData,
	player: PlayerState
) -> Array[Dictionary]:
	var effects: Array[Dictionary] = []
	
	if action.damage > 0:
		effects.append({
			"type": "DMG",
			"value": action.damage
		})
	
	if action.pp > 0:
		var lp_amount: int = action.pp
		
		if player.is_orgasming():
			lp_amount *= 2
		
		effects.append({
			"type": "LP",
			"value": lp_amount
		})
		
		if player.is_orgasming():
			effects.append({
				"type": "DMG",
				"value": action.pp
			})
	
	return effects

func _update_statuses() -> void:
	set_statuses(enemy_state.effects)

func play_damage_hit() -> void:
	await combat_animator.play_hp_hit()

func play_pp_hit() -> void:
	await combat_animator.play_lust_hit()

func play_skip_turn() -> void:
	await combat_animator.play_skip_turn()

func play_cast() -> void:
	await combat_animator.play_cast()
