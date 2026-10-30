class_name EventMenu
extends Control

signal event_selected(event: EventData)

@onready var events_root: VBoxContainer = %VBoxContainer

func setup() -> void:
	var event_list: Array[EventData] = EventLibrary.events.values()
	event_list.sort_custom(
		func(a: EventData, b: EventData) -> bool:
			return String(a.id).nocasecmp_to(String(b.id)) < 0
	)
	
	for event: EventData in event_list:
		var button: Button = Button.new()
		
		button.text = event.id.capitalize()
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_font_override("font", preload("res://fonts/ark-pixel-12px-proportional-latin.ttf"))
		button.pressed.connect(_on_event_pressed.bind(event))
		
		events_root.add_child(button)

func _on_event_pressed(event: EventData) -> void:
	hide()
	event_selected.emit(event)
