@tool
class_name ContractionEffect
extends CardEffect

@export var additional_pp_for_blowjob: int
@export var additional_pp_for_vaginal: int

@warning_ignore("unused_parameter")
func set_pp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	if combat.player.current_sex.sex_type == SexData.SexType.ORAL:
		return additional_pp_for_blowjob
	if combat.player.current_sex.sex_type == SexData.SexType.VAGINAL:
		return additional_pp_for_vaginal
	return 0
