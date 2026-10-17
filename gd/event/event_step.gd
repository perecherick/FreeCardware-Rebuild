class_name EventStep
extends Resource

@export var id: StringName

@export_multiline var text: String

@export var custom_scene: PackedScene

@export var frames: Array[Texture2D]
@export var fps: float = 12.0
@export var loop: bool = true

@export var next_step: StringName
@export var conditional_next_steps: Array[EventConditionalStep]
@export var effects: Array[EventEffect]
@export var choices: Array[EventChoice]

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
