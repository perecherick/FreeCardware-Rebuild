@tool
class_name ClothesChange
extends EventEffect

@export var gain_panties: bool = false:
	set(value):
		gain_panties = value
		notify_property_list_changed()

@export var strip_panties: bool = false:
	set(value):
		strip_panties = value
		notify_property_list_changed()

@export var fix_clothes: bool = false:
	set(value):
		fix_clothes = value
		notify_property_list_changed()

@export var torn_clothes: bool = false:
	set(value):
		torn_clothes = value
		notify_property_list_changed()

@export var put_on_clothes: bool = false:
	set(value):
		put_on_clothes = value
		notify_property_list_changed()

@export var remove_clothes: bool = false:
	set(value):
		remove_clothes = value
		notify_property_list_changed()

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"gain_panties":
			if strip_panties:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"strip_panties":
			if gain_panties:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"fix_clothes":
			if torn_clothes:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"torn_clothes":
			if fix_clothes:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"put_on_clothes":
			if remove_clothes:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"remove_clothes":
			if put_on_clothes:
				property.usage |= PROPERTY_USAGE_READ_ONLY

func apply(player: PlayerState, _event: Event) -> void:
	if gain_panties:
		player.put_panties_on()

	if strip_panties:
		player.strip_panties()

	if fix_clothes:
		player.put_on_clothes()

	if torn_clothes:
		player.tear_clothes()

	if put_on_clothes:
		player.put_on_clothes()

	if remove_clothes:
		player.remove_clothes()
