class_name CombatVisualAnimator
extends Node

const HP_HIT_COLOR: Color = Color(
	1.0,
	0.3,
	0.3,
	1.0
)

const LUST_HIT_COLOR: Color = Color(
	1.0,
	0.4,
	0.75,
	1.0
)

@export var visual_root: Node2D

@export_group("Offsets")
@export var back_offset: Vector2 = Vector2(24.0, 0.0)
@export var forward_offset: Vector2 = Vector2(-16.0, 0.0)

@export_group("Durations")
@export var hit_duration: float = 0.07
@export var return_duration: float = 0.13

var origin_position: Vector2
var origin_modulate: Color

func _ready() -> void:
	origin_position = visual_root.position
	origin_modulate = visual_root.modulate

func play_hp_hit() -> void:
	await _play_hit(HP_HIT_COLOR)

func play_lust_hit() -> void:
	await _play_hit(LUST_HIT_COLOR)

func play_cast() -> void:
	if visual_root == null:
		return

	_reset_visual()

	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		visual_root,
		"position",
		origin_position + forward_offset,
		0.08
	)

	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		visual_root,
		"position",
		origin_position,
		0.12
	)

	await tween.finished

func play_skip_turn() -> void:
	if visual_root == null:
		return

	_reset_visual()

	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		visual_root,
		"position",
		origin_position + back_offset,
		0.07
	)

	tween.tween_property(
		visual_root,
		"position",
		origin_position + forward_offset,
		0.09
	)

	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		visual_root,
		"position",
		origin_position,
		0.11
	)

	await tween.finished

func _play_hit(hit_color: Color) -> void:
	if visual_root == null:
		return

	_reset_visual()

	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		visual_root,
		"position",
		origin_position + back_offset,
		hit_duration
	)

	tween.parallel().tween_property(
		visual_root,
		"modulate",
		hit_color,
		hit_duration
	)

	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		visual_root,
		"position",
		origin_position,
		return_duration
	)

	tween.parallel().tween_property(
		visual_root,
		"modulate",
		origin_modulate,
		return_duration
	)

	await tween.finished

func reset_visual() -> void:
	if visual_root == null:
		return

	_reset_visual()

func _reset_visual() -> void:
	visual_root.position = origin_position
	visual_root.modulate = origin_modulate
