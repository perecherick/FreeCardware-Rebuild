class_name CombatMenu
extends Control

signal debug_combat_request(enemy_data: EnemyData)

@onready var enemy_root: VBoxContainer = %VBoxContainer

func setup() -> void:
	var enemy_list: Array[EnemyData] = EnemyLibrary.all_enemies.duplicate()
	
	for enemy: EnemyData in enemy_list:
		var button: Button = Button.new()
		
		button.text = tr(enemy.name)
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_font_override("font", preload("res://fonts/ark-pixel-12px-proportional-latin.ttf"))
		button.pressed.connect(_on_enemy_combat_pressed.bind(enemy))
		
		enemy_root.add_child(button)

func _on_enemy_combat_pressed(enemy_data: EnemyData) -> void:
	hide()
	debug_combat_request.emit(enemy_data)
