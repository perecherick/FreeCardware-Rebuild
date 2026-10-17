class_name StandardSprite
extends Node2D

@export var follow_selected_character: bool = false

@onready var nude_base: Node2D = %NudeBase
@onready var default_clothes: Node2D = %DefaultClothes
@onready var torn_clothes: Node2D = %TornClothes
@onready var panties: Node2D = %Panties
@onready var blush: Node2D = %Blush
@onready var edge: Node2D = %Edge
@onready var orgasm: Node2D = %Orgasm

var player_state: PlayerState

const IGNORED_MISSING_TEXTURES: Array[String] = [
	"res://img/lucy_sprite/selection.png"
]

func _ready() -> void:
	if !follow_selected_character:
		return
	var run_manager: RunManager = get_tree().get_first_node_in_group("run_manager")
	
	run_manager.character_changed.connect(set_character)
	
	set_character(run_manager.character_selected.id)

func set_character(id: String) -> void:
	var folder: String = "res://img/%s_sprite" % id
	var stats: Dictionary = {
		"loaded": 0,
		"missing": 0
	}
	
	_apply_textures(self, folder, "", stats)
	
	DebugLogger.info(
		"Character textures applied: %s (loaded=%d, missing=%d)"
		% [id, stats["loaded"], stats["missing"]]
	)

func _apply_textures(
	node: Node,
	base_folder: String,
	relative_folder: String,
	stats: Dictionary
) -> void:
	for child: Node in node.get_children():
		
		var file_name: String = child.name.to_snake_case()
		if child is Sprite2D:
			var path: String = base_folder.path_join(relative_folder).path_join(
				file_name + ".png"
			)
			if path not in IGNORED_MISSING_TEXTURES:
				if ResourceLoader.exists(path):
					child.texture = load(path)
					stats["loaded"] += 1
				else:
					stats["missing"] += 1
					DebugLogger.warning("Missing character texture: %s" % path)
					child.texture = null
		
		if child.get_child_count() > 0:
			var next_folder: String = relative_folder.path_join(file_name)
			_apply_textures(child, base_folder, next_folder, stats)

func setup_player_state(state: PlayerState) -> void:
	player_state = state
	player_state.appearance_changed.connect(_update_appearance)
	player_state.lp_changed.connect(_on_lp_changed)
	player_state.orgasm_over.connect(_update_appearance)
	
	_update_appearance()

func _update_appearance() -> void:
	if player_state == null:
		return

	default_clothes.visible = (
		player_state.clothes_state
		== PlayerState.ClothesState.NORMAL
	)

	torn_clothes.visible = (
		player_state.clothes_state
		== PlayerState.ClothesState.TORN
	)

	panties.visible = !player_state.panties_removed

	orgasm.visible = player_state.is_orgasming()

	edge.visible = (
		!orgasm.visible
		and player_state.lp >= player_state.max_lp - 2
	)

	blush.visible = (
		!orgasm.visible
		and !edge.visible
		and player_state.lp >= player_state.max_lp / 2.0
	)

func _on_lp_changed(
	_current: int,
	_maximum: int
) -> void:
	_update_appearance()
