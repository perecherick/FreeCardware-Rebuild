class_name CardView
extends Control

enum HoverPivot {
	CENTER,
	BOTTOM
}

@onready var card_name: Label = %CardName
@onready var card_description: RichTextLabel = %CardDescription
@onready var card_texture: TextureRect = %CardImage
@onready var card_energy_cost: Label = %EnergyCost
@onready var card_light: TextureRect = %Light
@onready var card_visual: Control = %Visual
@onready var hover_area: Control = %HoverArea
@onready var shop_price: Label = %ShopCost

var card_data: CardData
var combat: Combat
var cached_preview: CardPreview 
var cached_enemy: EnemyState

var hover_pivot: HoverPivot = HoverPivot.CENTER
var normal_scale: float = 1.0
var hover_scale: float = 1.0
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var target_scale: float = 1.5

signal pressed(card: CardView)

func setup(
	card: CardData, 
	scale_v: float = 1.0, 
	hover_scale_v: float = 1.0,
	hover_pivot_v: HoverPivot = HoverPivot.CENTER,
	show_price: bool = false
) -> void:
	card_data = card
	normal_scale = scale_v
	hover_scale = hover_scale_v
	hover_pivot = hover_pivot_v
	
	_set_name(card.name)
	_set_description(card)
	_set_image(card.img)
	set_energy_cost(card.energy_cost)
	_set_light_type(card)
	_set_scale()
	if show_price:
		_show_shop_price()

@warning_ignore("shadowed_variable_base_class")
func _set_name(name: String) -> void:
	card_name.text = tr(name)
	if tr(name).length() > 10:
		card_name.add_theme_font_size_override("font_size", 12)
		card_name.add_theme_font_override("font", preload("res://fonts/ark-pixel-12px-proportional-latin.ttf"))
	else:
		card_name.add_theme_font_size_override("font_size", 16)
		card_name.add_theme_font_override("font", preload("res://fonts/ark-pixel-16px-proportional-latin.ttf"))

func _set_description(
	card: CardData
) -> void:
	var preview: CardPreview = card.get_base_preview()

	var format_values: Dictionary = {
		"dmg": "[color=orange]%s[/color]" % preview.damage,
		"pp": "[color=deep_pink]%s[/color]" % preview.pp,
		"lp": "[color=violet]%s[/color]" % abs(preview.lp),
		"hp": "[color=red]%s[/color]" % preview.hp,
		"ene": "[color=aqua]%s[/color]" % preview.energy_cost,
	}

	for key: StringName in preview.values:
		var value: Variant = preview.values[key]
		var color: Color = card.description_colors.get(
			key,
			Color.WHITE
		)

		format_values[String(key)] = "[color=#%s]%s[/color]" % [
			color.to_html(),
			value
		]

	var description: String = tr(card.description).format(format_values)

	if card.exhaust:
		description += "\n%s" % tr("TID_EXHAUST")

	card_description.text = description

func _set_hover_description(preview: CardPreview) -> void:
	var description: String = card_data.hover_description

	if description.is_empty():
		description = card_data.description

	var format_values: Dictionary = {
		"dmg": "[color=orange]%s[/color]" % preview.damage,
		"pp": "[color=deep_pink]%s[/color]" % abs(preview.pp),
		"lp": "[color=violet]%s[/color]" % abs(preview.lp),
		"hp": "[color=red]%s[/color]" % abs(preview.hp),
		"ene": "[color=aqua]%s[/color]" % preview.energy_cost,
		"turns": "%s" % preview.energy_cost
	}

	for key: StringName in preview.values:
		var value: Variant = preview.values[key]
		var color: Color = card_data.description_colors.get(
			key,
			Color.WHITE
		)

		format_values[String(key)] = "[color=#%s]%s[/color]" % [
			color.to_html(),
			value
		]

	card_description.text = tr(description).format(format_values)

func _set_image(img: Texture) -> void:
	card_texture.texture = img

func set_energy_cost(cost: int) -> void:
	card_energy_cost.text = str(cost)

func set_available(value: bool) -> void:
	if !value:
		card_light.texture = preload("res://img/cards/lights/off.png")
		return

	_set_light_type(card_data)

func _set_light_type(card: CardData) -> void:
	if card.attack: 
		card_light.texture = preload("res://img/cards/lights/damage.png")
	elif card.sex:
		card_light.texture = preload("res://img/cards/lights/sex.png")
	elif card.pp: 
		card_light.texture = preload("res://img/cards/lights/pleasure.png")
	elif card.misc: 
		card_light.texture = preload("res://img/cards/lights/misc.png")

func _set_scale() -> void:
	custom_minimum_size = Vector2(94 * normal_scale, 167 * normal_scale)
	card_visual.scale = Vector2(normal_scale, normal_scale)
	hover_area.scale = Vector2(normal_scale, normal_scale)

func _show_shop_price() -> void:
	shop_price.visible = true
	shop_price.text = "%dG" % [card_data.card_cost]

func _on_hover_area_mouse_entered() -> void:
	if dragging:
		return

	z_index = 1000

	var scale_diff: float = hover_scale - normal_scale
	var extra_size: Vector2 = card_visual.size * scale_diff

	match hover_pivot:
		HoverPivot.CENTER:
			card_visual.position = Vector2(
				-extra_size.x * 0.5,
				-extra_size.y * 0.5
			)
		HoverPivot.BOTTOM:
			card_visual.position = Vector2(
				-extra_size.x * 0.5,
				-extra_size.y * 1.7
			)
	
	card_visual.scale = Vector2.ONE * hover_scale

func _on_hover_area_mouse_exited() -> void:
	if dragging:
		return

	reset_visual()

func _on_hover_area_gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton 
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		pressed.emit(self)

func start_drag(mouse_position: Vector2) -> void:
	dragging = true

	drag_offset = card_visual.global_position - mouse_position

	z_index = 1000
	card_visual.scale = Vector2.ONE * hover_scale

func drag_to(mouse_position: Vector2) -> void:
	if !dragging:
		return
	
	var target_position: Vector2 = mouse_position + drag_offset
	
	card_visual.global_position = card_visual.global_position.lerp(
		target_position,
		0.35
	)
	
	card_visual.scale = card_visual.scale.lerp(
		Vector2.ONE * hover_scale,
		0.2
	)
	
	_set_description(card_data)

func drag_to_target(
	anchor: Vector2,
	mouse: Vector2, 
	preview: CardPreview
) -> void:
	if !dragging:
		return
	
	var visual_size: Vector2 = card_visual.size * target_scale
	
	var base_position: Vector2 = Vector2(
		anchor.x,
		anchor.y - visual_size.y / 2.0
	)
	
	var mouse_offset: Vector2 = mouse - anchor
	mouse_offset = mouse_offset.limit_length(80.0) * 0.15
	
	var target_position: Vector2 = base_position + mouse_offset
	
	card_visual.global_position = card_visual.global_position.lerp(
		target_position,
		0.2
	)
	
	card_visual.scale = card_visual.scale.lerp(
		Vector2.ONE * target_scale,
		0.2
	)
	
	_set_hover_description(preview)

func stop_drag() -> void:
	dragging = false
	z_index = 0

	card_visual.position = Vector2.ZERO
	card_visual.scale = Vector2.ONE * normal_scale
	_set_description(card_data)

func set_hover_input_enabled(value: bool) -> void:
	hover_area.mouse_filter = (
		Control.MOUSE_FILTER_STOP
		if value
		else Control.MOUSE_FILTER_IGNORE
	)

	if !value and !dragging:
		reset_visual()

func reset_visual() -> void:
	z_index = 0
	card_visual.z_index = 0
	card_visual.position = Vector2.ZERO
	card_visual.scale = Vector2.ONE * normal_scale

func set_combat(value: Combat) -> void:
	combat = value

@warning_ignore("shadowed_variable")
func get_preview(
	combat: Combat,
	enemy: EnemyState = null
) -> CardPreview:
	if cached_preview == null or cached_enemy != enemy:
		cached_preview = combat.get_card_preview(
			card_data,
			enemy
		)
		
		cached_enemy = enemy
	
	return cached_preview

func invalidate_preview() -> void:
	cached_preview = null
	cached_enemy = null
