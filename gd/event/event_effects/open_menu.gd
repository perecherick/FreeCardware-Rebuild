@tool
class_name OpenMenu
extends EventEffect

@export var menu_to_open: PackedScene

func apply(player: PlayerState, event: Event) -> void:
	var menu: Node = menu_to_open.instantiate()

	event.custom_root.add_child(menu)
	menu.open(player)
