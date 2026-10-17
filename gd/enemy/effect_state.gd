class_name EffectState
extends RefCounted

var data: EffectData
var turns_left: int
var stacks: int

func _init(
	effect_data: EffectData,
	duration: int = -1,
	initial_stacks: int = -1
) -> void:
	data = effect_data

	if duration >= 0:
		turns_left = duration
	else:
		turns_left = data.default_duration

	if initial_stacks >= 0:
		stacks = initial_stacks
	else:
		stacks = data.default_stacks

func tick() -> bool:
	if data.stacks_change_per_turn != 0:
		stacks += data.stacks_change_per_turn

		if data.max_stacks > 0:
			stacks = mini(stacks, data.max_stacks)

		stacks = maxi(stacks, 0)

	if data.duration_mode == EffectData.DurationMode.TURNS:
		turns_left -= 1

	if stacks <= 0:
		return false

	if (
		data.duration_mode == EffectData.DurationMode.TURNS
		and turns_left <= 0
	):
		return false

	return true
