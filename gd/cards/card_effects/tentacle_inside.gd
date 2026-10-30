@tool
class_name TentacleInsideEffect
extends CardEffect

func set_pp(
	_combat: Combat,
	preview: CardPreview,
	_enemy: EnemyState = null
) -> int:
	var min_value: int = preview.values.get("minpp", 0)
	var max_value: int = preview.values.get("maxpp", 0)
	
	var total: int = randi_range(min_value, max_value)
	
	return total

func set_lp(
	_combat: Combat,
	preview: CardPreview,
	_enemy: EnemyState = null
) -> int:
	var min_value: int = preview.values.get("minlp", 0)
	var max_value: int = preview.values.get("maxlp", 0)
	
	var total: int = randi_range(min_value, max_value)
	
	return total
