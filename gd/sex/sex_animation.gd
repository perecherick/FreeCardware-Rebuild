class_name SexAnimation
extends Node2D

@onready var sex_step_cum: Sprite2D = %Cum

var player: PlayerState
var current_sex: SexData
var current_step: int

func start_sex(
	player_state: PlayerState, 
	sex_type: SexData, 
	step: int = 1
) -> void:
	_clear_textures()
	player = player_state
	current_sex = sex_type
	current_step = step
	
	_update_sprite_texture()
	update_sprite()

func stop_sex() -> void:
	_clear_textures()
	current_sex = null
	current_step = 0

func update_sprite() -> void:
	var head_step: int = _get_available_step("head")
	var body_step: int = _get_available_step("body")
	
	for sprite: Sprite2D in find_children("*", "Sprite2D", true, false):
		sprite.hide()
		
		if sprite.texture == null:
			continue
		
		var sprite_name: String = String(sprite.name).to_snake_case()
		
		if sprite_name.begins_with("head_"):
			sprite.visible = sprite_name == "head_%d" % head_step
			continue
		if sprite_name.begins_with("body_"):
			sprite.visible = sprite_name == "body_%d" % body_step
			continue
		
		match sprite_name:
			"clothes":
				sprite.visible = (
					player.clothes_state != player.ClothesState.REMOVED
				)
			"creampie":
				sprite.visible = (player.has_hardware("creampie"))
			"facial":
				sprite.visible = (player.has_hardware("facial"))
			"panties":
				sprite.visible = !player.panties_removed
			"1", "2", "3", "4", "5":
				sprite.visible = str(current_step) == sprite.name

func _get_available_step(type: String) -> int:
	var best_step: int = 0
	var prefix: String = type + "_"
	
	for sprite: Sprite2D in find_children("*", "Sprite2D", true, false):
		var sprite_name: String = sprite.name.to_snake_case()
		
		if !sprite_name.begins_with(prefix):
			continue
		
		if sprite.texture == null:
			continue
		
		var step: int = int(sprite_name.trim_prefix(prefix))
		
		if step <= current_step:
			best_step = maxi(best_step, step)
	
	return best_step

func _update_sprite_texture() -> void:
	var path: String = "res://img/%s_sprite/sex/%s" % [
		player.character.id,
		current_sex.id
	]
	
	_load_textures(self, path)

func _load_textures(node: Node2D, path: String) -> void:
	for child: Node2D in node.get_children():
		var child_path: String = path.path_join(child.name.to_snake_case())
		
		if child is Sprite2D:
			var texture_path: String = child_path + ".png"
			if ResourceLoader.exists(texture_path):
				child.texture = load(texture_path)
			continue
		
		_load_textures(child, child_path)

func _clear_textures() -> void:
	for sprite: Sprite2D in find_children("*", "Sprite2D", true, false):
		sprite.texture = null

func show_orgasm() -> void:
	sex_step_cum.show()

func get_max_step() -> int:
	var max_step: int = 1
	for sprite: Sprite2D in find_children("*", "Sprite2D", true, false):
		max_step = maxi(max_step, int(sprite.name))
	return max_step
