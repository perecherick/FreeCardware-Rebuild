@tool
class_name TentacleInsideEffect
extends CardEffect

@warning_ignore("unused_parameter")
func set_pp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	var min_value: int = preview.values.get("minpp", 0)
	var max_value: int = preview.values.get("maxpp", 0)
	
	var total: int = randi_range(min_value, max_value)
	
	return total

@warning_ignore("unused_parameter")
func set_lp(
	combat: Combat,
	preview: CardPreview,
	enemy: EnemyState = null
) -> int:
	var min_value: int = preview.values.get("minlp", 0)
	var max_value: int = preview.values.get("maxlp", 0)
	
	var total: int = randi_range(min_value, max_value)
	
	return total
