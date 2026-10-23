extends Node

@export var sex_library: AudioStreamInteractive

@onready var music_bus: AudioStreamPlayer = $"Music"
@onready var sfx_bus: AudioStreamPlayer = $"SFX"
@onready var sex_bus: AudioStreamPlayer = $"Sex"

var sex_streams: Dictionary[StringName, AudioStream]

func _ready() -> void:
	for i: int in range(sex_library.clip_count):
		var label: StringName = sex_library.get_clip_name(i)
		sex_streams[label] = sex_library.get_clip_stream(i)
	
	sex_bus.play()

func play_music(label: StringName) -> void:
	_play_clip(music_bus, label)

func play_sound(label: StringName) -> void:
	_play_clip(sfx_bus, label)

func play_sex_sound(label: StringName) -> void:
	sex_bus.get_stream_playback().play_stream(sex_streams.get(label))

func _play_clip(bus: AudioStreamPlayer, label: StringName) -> void:
	if !bus.playing: bus.play()
	
	var playback: AudioStreamPlaybackInteractive = bus.get_stream_playback()
	playback.switch_to_clip_by_name(label)
