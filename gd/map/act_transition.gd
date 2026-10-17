# i hate godot especially animations its so fucking inconvenient
class_name ActTransition
extends Control

@onready var label: Label = %Label
@onready var animation: AnimationPlayer = %AnimationPlayer

func play_act(act_number: int) -> void:
	DebugLogger.info("Act transition started: %d" % act_number)

	label.text = tr("TID_ACT") % act_number
	animation.play("act_transition")
	await animation.animation_finished

	DebugLogger.info("Act transition finished: %d" % act_number)
