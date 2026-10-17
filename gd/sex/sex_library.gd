extends Node

var sex_list: Array[SexData]

func _ready() -> void:
	for file: String in ResourceLoader.list_directory("res://tres/sex"):
		if file.ends_with(".tres"):
			var data: SexData = load("res://tres/sex/%s" % file)
			sex_list.append(data) 
