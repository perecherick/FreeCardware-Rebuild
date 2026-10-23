class_name EventChoiceButton
extends Button

signal choice_selected(choice: EventChoice)

var choice_data: EventChoice

func _ready() -> void:
	pressed.connect(_on_pressed)

func setup(
	choice: EventChoice, 
	player: PlayerState, 
	event: Event
) -> void:
	choice_data = choice

	text = tr(choice.text).format(event.values)
	disabled = !choice.is_available(player, event)

func _on_pressed() -> void:
	choice_selected.emit(choice_data)
