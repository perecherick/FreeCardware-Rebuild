extends Control

signal selected(character: CharacterData)

var character_data: CharacterData

func setup(data: CharacterData) -> void:
	character_data = data
	%TextureRect.texture_normal = data.background
	%StandardSprite.set_character(data.id)

func _on_texture_rect_pressed() -> void:
	selected.emit(character_data)
