class_name CharacterData
extends Resource

@export var id: String 
@export var background: Texture2D
@export var order: int

@export_category("Stats")
@export var max_hp: int
@export var max_lp: int
@export var max_energy: int

@export_category("Starting")
@export var starting_deck: Array[CardData]
@export var starting_hardware: Array[HardwareData]
