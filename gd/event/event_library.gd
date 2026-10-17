extends Node

var events: Dictionary[StringName, EventData]

func _ready() -> void:
	var files: PackedStringArray = ResourceLoader.list_directory("res://tres/events/event_data")
	
	for file_name: String in files:
		var path: String = "res://tres/events/event_data/" + file_name
		var resource: Resource = ResourceLoader.load(path)
		var event: EventData = resource
		
		if event.id.is_empty():
			DebugLogger.error("EventData has empty id: %s" % path)
			continue
		
		if events.has(event.id):
			DebugLogger.error("Duplicate EventData id: %s" % event.id)
			continue
		
		events[event.id] = event
