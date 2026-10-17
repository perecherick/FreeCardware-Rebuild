class_name MapVisuals
extends Control

@onready var icon: TextureRect = %Icon
@onready var label: Label = %Label
@onready var circle: TextureRect = %Circle
@onready var animation: AnimationPlayer = %AnimationPlayer

@onready var normal_icon_size: Vector2 = icon.size

var location_type: String = "enemy"
var boss_type: String = ""
var is_valid: bool = false

const ICONS: Dictionary = {
	"enemy": preload("res://img/map/enemy.png"),
	"event": preload("res://img/map/event.png"),
	"hardware": preload("res://img/map/hardware.png"),
	"shop": preload("res://img/map/shop.png"),
	"rest": preload("res://img/map/rest.png"),
	"mini_boss": preload("res://img/map/mini_boss.png"),
	"boss_dragon": preload("res://img/enemies/bosses/dragon.png"),
	"boss_cat": preload("res://img/enemies/bosses/cat.png"),
}

const BOSS_VISUALS: Dictionary = {
	"dragon": {
		"texture": ICONS["boss_dragon"],
		"offset": Vector2(-130, -110),
	},
	"cat": {
		"texture": ICONS["boss_cat"],
		"offset": Vector2(-110, -140),
	},
}

func setup(
	new_type: String,
	new_boss_type: String,
	new_is_valid: bool
) -> void:
	location_type = new_type
	boss_type = new_boss_type
	is_valid = new_is_valid

	reset_visual()

	if location_type == "boss":
		setup_boss_icon()
	else:
		setup_normal_icon()

	update_valid_animation()

func setup_normal_icon() -> void:
	icon.texture = ICONS.get(location_type, ICONS["enemy"])
	label.text = "TID_" + location_type.to_upper()

func setup_boss_icon() -> void:
	var data: Dictionary = BOSS_VISUALS[boss_type]
	var texture: Texture2D = data["texture"]

	icon.texture = texture
	icon.size = texture.get_size() * 2.0
	icon.position = data["offset"] * 2.0
	icon.pivot_offset = icon.size * 0.5
	icon.modulate = Color.BLACK

	label.text = "TID_BOSS"

func reset_visual() -> void:
	animation.stop()

	scale = Vector2.ONE

	icon.rotation = 0.0
	icon.texture = null
	icon.position = Vector2.ZERO
	icon.size = normal_icon_size
	icon.pivot_offset = normal_icon_size * 0.5
	icon.modulate = Color.WHITE

	label.visible = false
	label.text = ""

	circle.visible = false

func set_hovered(hovered: bool) -> void:
	label.visible = hovered

	if hovered and is_valid and location_type != "boss":
		scale = Vector2(1.5, 1.5)
	else:
		scale = Vector2.ONE

func set_selected(selected: bool) -> void:
	circle.visible = selected

func update_valid_animation() -> void:
	animation.stop()
	icon.rotation = 0.0

	if is_valid and location_type != "boss":
		animation.play("rotation")

func set_valid(value: bool) -> void:
	is_valid = value
	update_valid_animation()
