class_name EventData
extends Resource

@export var id: StringName
@export var steps: Array[EventStep]
@export var starting_step: EventStep
@export var conditional_starting_steps: Array[EventConditionalStep]

func get_step(step_id: StringName) -> EventStep:
	for step: EventStep in steps:
		if step == null:
			continue

		if step.id == step_id:
			return step

	return null

func get_starting_step(player: PlayerState, event: Event) -> EventStep:
	for condition: EventConditionalStep in conditional_starting_steps:
		if condition == null:
			continue
		
		if condition.condition != null and condition.condition.check(player, event):
			return get_step(condition.next_step)
	
	return starting_step
