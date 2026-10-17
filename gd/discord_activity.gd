# Ik that this is useless, but for some reason i really wanted to
# add this
extends Node

var presence: DiscordRichPresence

var details: String = "Loading..."
var state: String

var run_act: int = 1
var run_mode: String = "normal"
var run_difficulty: String = "normal"

var started_at: int

func start_activity() -> void:
	if presence != null:
		return
	
	started_at = int(Time.get_unix_time_from_system())
	
	presence = DiscordRichPresence.new()
	presence.app_id = "1542554779509727343"
	add_child(presence)
	
	update_activity()

func set_status(label: String, label2: String = "") -> void:
	details = label
	state = label2
	update_activity()

func set_run_status(
	act: int,
	mode: String,
	difficulty: String
) -> void:
	details = "run"
	run_act = act
	run_mode = mode
	run_difficulty = difficulty
	
	update_activity()

func update_activity() -> void:
	if presence == null:
		return
	
	var details_text: String = ""
	var state_text: String = ""

	if details == "run":
		details_text = tr("TID_DISCORD_RUN").format({
			"act": run_act
		})
	
		state_text = "%s • %s: %s" % [
			tr(_get_mode_tid()),
			tr("RUN_DIFFICULTY"),
			tr(_get_difficulty_tid())
		]
	else:
		details_text = tr(details)
		state_text = tr(state)
	
	var activity: Dictionary = {
		"details": details_text,
		"timestamps": {
			"start": started_at
		}
	}
	
	if !state_text.is_empty():
		activity["state"] = state_text
	
	presence.set_activity(activity)	

func _get_mode_tid() -> String:
	match run_mode:
		"normal":
			return "NORMAL_RUN"
		"pure":
			return "PURE_RUN"
		"lewd":
			return "LEWD_RUN"
		_:
			return "NORMAL_RUN"

func _get_difficulty_tid() -> String:
	match run_difficulty:
		"normal":
			return "DIF_NORMAL"
		"hard":
			return "DIF_HARD"
		"insane":
			return "DIF_INSANE"
		_:
			return "DIF_NORMAL"

func kill_activity() -> void:
	if presence == null:
		return
	
	presence.clear_activity()
	presence.queue_free()
	presence = null
