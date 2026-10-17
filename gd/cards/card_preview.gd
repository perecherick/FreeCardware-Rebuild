class_name CardPreview
extends RefCounted

var damage: int
var pp: int
var lp: int
var hp: int
var energy_cost: int

var values: Dictionary = {}

func _init(card: CardData) -> void:
	damage = card.damage
	pp = card.pp
	lp = card.lp
	hp = card.hp
	energy_cost = card.energy_cost

func set_value(key: StringName, value: Variant) -> void:
	values[key] = value
