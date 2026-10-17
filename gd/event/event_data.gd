class_name EventData
extends Resource

@export var id: StringName
@export var steps: Array[EventStep]

func get_step(step_id: StringName) -> EventStep:
	for step: EventStep in steps:
		if step == null:
			continue

		if step.id == step_id:
			return step

	return null
