@tool
class_name ClothesCondition
extends EventCondition

@export var has_panties: bool:
	set(value):
		has_panties = value
		notify_property_list_changed()

@export var no_panties: bool:
	set(value):
		no_panties = value
		notify_property_list_changed()

@export var clothes_intact: bool:
	set(value):
		clothes_intact = value
		notify_property_list_changed()

@export var clothes_torn: bool:
	set(value):
		clothes_torn = value
		notify_property_list_changed()

@export var clothed: bool:
	set(value):
		clothed = value
		notify_property_list_changed()

@export var nude: bool:
	set(value):
		nude = value
		notify_property_list_changed()

@export var has_any_clothing: bool

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"has_panties":
			if no_panties:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"no_panties":
			if has_panties:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"clothes_intact":
			if clothes_torn:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"clothes_torn":
			if clothes_intact:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"clothed":
			if nude:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"nude":
			if clothed:
				property.usage |= PROPERTY_USAGE_READ_ONLY

func check(player: PlayerState, _event: Event) -> bool:
	if has_panties and player.panties_removed:
		return false
	
	if no_panties and !player.panties_removed:
		return false
	
	if clothes_intact and player.clothes_state == player.ClothesState.TORN:
		return false
	
	if clothes_torn and !player.clothes_state == player.ClothesState.TORN:
		return false
	
	if clothed and !player.clothes_state == player.ClothesState.NORMAL:
		return false
	
	if nude and !player.clothes_state == player.ClothesState.REMOVED:
		return false
	
	if has_any_clothing:
		if (
			player.clothes_state == player.ClothesState.REMOVED
			and player.panties_removed
		):
			return false
	
	return true
