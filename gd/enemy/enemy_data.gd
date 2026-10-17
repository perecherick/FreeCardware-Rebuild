class_name EnemyData
extends Resource

enum EnemyType {
	STARTING,
	NORMAL,
	MINI_BOSS,
	BOSS,
	EVENT
}

@export var id: String
@export var name: String
@export var texture: Texture
@export var type: EnemyType

@export_category("Enemy stats")

@export var max_hp: int
@export var starting_hp: int
@export var max_pp: int
@export var starting_pp: int
@export var effects: Array[EffectData]

@export_category("Move list")

@export var move_list: Array[EnemyMove]
@export var enemy_initiated_sex_moves: Array[EnemyMove]
@export var player_initiated_sex_moves: Array[EnemyMove]
@export var player_orgasm_moves: Array[EnemyMove]
