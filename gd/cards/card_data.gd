class_name CardData
extends Resource

enum TargetType {
	ENEMY,
	SELF,
	BOTH
}

enum CardType {
	INNATE,
	EVENT,
	BATTLE,
	NORMAL_REWARD,
	BOSS_REWARD
}

@export var id: String
@export var name: String
@export var img: Texture
@export_multiline var description: String
@export_multiline var hover_description: String
@export var energy_cost: int
@export var damage: int
@export var pp: int
@export var lp: int
@export var hp: int
@export var card_cost: int
@export var exhaust: bool

@export var description_colors: Dictionary[StringName, Color]

@export var sex_type: SexData
@export var sex_state_change: int

@export_category("Card Special Effects")

@export var card_effects: Array[CardEffect]

@export_category("Card Types")

@export var attack: bool = false
@export var pleasure: bool = false
@export var sex: bool = false
@export var misc: bool = false

@export var card_type: CardType = CardType.INNATE
@export var target_type: TargetType = TargetType.ENEMY

@export_category("Works only in sex")

@export var works_only_in: SexData.SexType

func can_target_enemy() -> bool:
	return target_type == TargetType.ENEMY \
		or target_type == TargetType.BOTH

func can_target_self() -> bool:
	return target_type == TargetType.SELF \
		or target_type == TargetType.BOTH

func get_base_preview() -> CardPreview:
	var preview: CardPreview = CardPreview.new(self)
	
	for effect: CardEffect in card_effects:
		if effect == null:
			continue
		
		effect.modify_base_preview(preview)
	
	return preview
