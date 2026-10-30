class_name GameEvent
extends RefCounted

var cancelled: bool = false

func cancel() -> void:
	cancelled = true

func is_cancelled() -> bool:
	return cancelled
