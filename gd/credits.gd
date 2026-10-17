extends Control

signal show_settings

@onready var text_label: RichTextLabel = $CreditsContainer/RichTextLabel
@onready var back_button: Button = $CreditsContainer/Button

func _ready():
	update_credits()
	update_back()

func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			return
		
		update_credits()
		update_back()

func update_back():
	back_button.text = tr("MENU_BACK")

func update_credits():
	text_label.text = """[center][b]%s[/b]

%s LewdTheMoon

[b]%s[/b]
@perecherick
@AHN
@nubaleen

[b]%s[/b]
@OpenNSFWSP
@chiyo1000nights
MonsterBox
MagicalMysticVA

[b]%s[/b]
gelbana[/center]""" % [
		tr("CREDITS"),
		tr("CREDITS_GAME_BY"),
		tr("CREDITS_MODDED_BY"),
		tr("CREDITS_VA_PACKS"),
		tr("CREDITS_SECRET_CODE")
	]

func _on_button_pressed() -> void:
	show_settings.emit()
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_button_pressed()

func _on_visibility_changed() -> void:
	if visible:
		back_button.grab_focus()
