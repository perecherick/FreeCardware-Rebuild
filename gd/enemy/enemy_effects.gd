class_name EffectData
extends Resource

enum DurationMode {
	PERMANENT,
	TURNS
}

@export var id: String
@export var name: String

@export_enum("white", "pink", "red", "orange") var color: String

@export var duration_mode: DurationMode
@export var default_duration: int

@export var default_stacks: int
@export var stacks_change_per_turn: int
@export var max_stacks: int

@export_category("Disable")

@export var disables_turn: bool
@export var disable_intent: String
