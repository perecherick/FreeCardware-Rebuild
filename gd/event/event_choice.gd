class_name EventChoice
extends Resource

@export_multiline var text: String
@export var next_step: StringName
@export var finish_event: bool = false

@export var conditions: Array[EventCondition]
@export var conditional_next_steps: Array[EventConditionalStep]
@export var effects: Array[EventEffect]

func is_available(player: PlayerState, event: Event) -> bool:
	for condition: EventCondition in conditions:
		if !condition.check(player, event):
			return false

	return true

func apply_effects(player: PlayerState, event: Event) -> void:
	for effect: EventEffect in effects:
		if effect == null:
			continue
		
		effect.apply(player, event)

func get_next_step(player: PlayerState, event: Event) -> StringName:
	for branch: EventConditionalStep in conditional_next_steps:
		if branch == null:
			continue
		
		if branch.condition != null and branch.condition.check(player, event):
			return branch.next_step
	
	return next_step
