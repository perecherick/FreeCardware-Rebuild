class_name CombatHud
extends Control

signal end_turn_pressed

@onready var battery_icon: TextureRect = %Battery
@onready var energy_count: Label = %EnergyCount
@onready var end_turn_button: Button = %EndTurn
@onready var deck: Label = %Cards
@onready var discard: Label = %Discard

func setup(player: PlayerState) -> void:
	if !player.energy_changed.is_connected(change_energy):
		player.energy_changed.connect(change_energy)
	
	change_energy(player.energy, player.max_energy)

func change_energy(energy: int, max_energy: int) -> void:
	energy_count.text = "%d/%d" % [energy, max_energy]

func _on_button_pressed() -> void:
	end_turn_pressed.emit()

func set_end_turn_enabled(value: bool) -> void:
	end_turn_button.disabled = !value

func change_pile_counts(deck_amount: int, discard_amount: int) -> void:
	deck.text = tr("TID_DECK_COUNT").format({
		"count": deck_amount
	})

	discard.text = tr("TID_DISCARD_COUNT").format({
		"count": discard_amount
	})
