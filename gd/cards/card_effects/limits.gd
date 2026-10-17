@tool
class_name LimitEffect
extends CardEffect

@export var min_damage: int
@export var max_damage: int
@export var min_pp: int
@export var max_pp: int
@export var min_lp: int
@export var max_lp: int

func apply_limits(preview: CardPreview) -> void:
	DebugLogger.info("Limint: %d, %d, %d" % [preview.damage, min_damage, max_damage])
	if min_damage > 0:
		preview.damage = maxi(preview.damage, min_damage)
	
	if max_damage > 0:
		preview.damage = mini(preview.damage, max_damage)
	
	if min_pp > 0:
		preview.pp = maxi(preview.pp, min_pp)
	
	if max_pp > 0:
		preview.pp = mini(preview.pp, max_pp)
	
	if max_lp > 0:
		preview.lp = mini(preview.lp, max_lp)
	
	if min_lp > 0:
		preview.lp = maxi(preview.lp, min_lp)
	
	DebugLogger.info("After lims: %d" % preview.damage)

func modify_base_preview(preview: CardPreview) -> void:
	preview.set_value("mindmg", min_damage)
	preview.set_value("maxdmg", max_damage)
	preview.set_value("minpp", min_pp)
	preview.set_value("maxpp", max_pp)
	preview.set_value("minlp", min_lp)
	preview.set_value("maxlp", max_lp)
