class_name HardwareData
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export_enum("pink", "aqua", "orange", "purple", "white") var color: String = "white"
@export var lewdness: int = 0

@export var stackable: bool
@export var max_stacks: int

@export_category("After combat")

@export var hp_after_combat: int
@export var lp_after_combat: int
