# My dear LewdTheMoon, if by any chance you're reading this, 
# please contact me, i've got something to tell, you my guy :3
extends Control

signal pause

@onready var pause_menu: Control = $Pause
@onready var win_menu: Control = $WinMenu
@onready var loss_menu: Control = $LossMenu
@onready var combat: Combat = $Combat

func _on_texture_button_pressed() -> void:
	pause.emit()
	
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_texture_button_pressed()
		get_viewport().set_input_as_handled()

func _on_run_won() -> void:
	win_menu.visible = true
	DiscordActivity.set_status("TID_DISCORD_WIN")

func _on_combat_combat_lost() -> void:
	loss_menu.visible = true
	combat.visible = false
	DiscordActivity.set_status("TID_DISCORD_LOSS")
