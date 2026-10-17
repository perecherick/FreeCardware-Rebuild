# i don't know, i'm really sorry
class_name PlayerSprite
extends Node2D

@onready var standart_sprite: StandardSprite = %StandartSprite
@onready var sex_animation: SexAnimation = %SexAnimation
@onready var combat_animator: CombatVisualAnimator = %CombatVisualAnimator
@onready var selection_area: Control = %SelectionArea
@onready var selection: Sprite2D = %Selection

var player_state: PlayerState

func setup_player_state(state: PlayerState) -> void:
	player_state = state
	
	player_state.sex_changed.connect(_on_sex_changed)
	player_state.sex_exited.connect(_on_sex_exited)
	player_state.appearance_changed.connect(_on_appearance_changed)
	
	standart_sprite.setup_player_state(player_state)
	_on_sex_exited()

func _on_sex_changed(
	sex_type: SexData,
	sex_value: int
) -> void:
	standart_sprite.hide()
	sex_animation.show()
	sex_animation.start_sex(player_state, sex_type, sex_value)

func _on_sex_exited() -> void:
	sex_animation.stop_sex()
	sex_animation.hide()
	standart_sprite.show()

func _on_appearance_changed() -> void:
	if !player_state.in_sex:
		return
	
	sex_animation.update_sprite()

func _has_clothes() -> bool:
	return (
		player_state.clothes_state
		!= PlayerState.ClothesState.REMOVED
	)

func play_damage_hit() -> void:
	await combat_animator.play_hp_hit()

func play_lp_hit() -> void:
	await combat_animator.play_lust_hit()

func play_card_cast() -> void:
	await combat_animator.play_cast()

func contains_mouse(mouse: Vector2) -> bool:
	return selection_area.get_global_rect().has_point(mouse)

func contains_mouse_extended(mouse: Vector2, margin: float = 80.0) -> bool:
	return selection_area.get_global_rect().grow(margin).has_point(mouse)

func get_card_target_position() -> Vector2:
	var rect: Rect2 = selection_area.get_global_rect()
	
	return Vector2(
		rect.position.x - 20.0,
		rect.get_center().y
	)

func set_selected(value: bool) -> void:
	selection.visible = value
