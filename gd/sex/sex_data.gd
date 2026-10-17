class_name SexData
extends Resource

enum SexType {
	ORAL,
	VAGINAL,
	ANAL,
	MANUAL
}

@export var id: StringName
@export var sex_type: SexType
@export var max_state: int = 5
@export var return_state: int = 3
