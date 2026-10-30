extends Node

var hardware_list: Array[HardwareData]

func _ready() -> void:
	var files: PackedStringArray = ResourceLoader.list_directory("res://tres/hardware")
	
	for file_name: String in files:
		if file_name.get_extension() not in ["tres", "res"]:
			continue
		var path: String = "res://tres/hardware/" + file_name
		var resource: Resource = ResourceLoader.load(path)
		var hardware: HardwareData = resource
		
		if resource is HardwareData:
			hardware_list.append(hardware)
