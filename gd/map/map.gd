# Love you guys, thanks for reading this shitty aah code
# and these cringey comments 
class_name Map
extends Control

@onready var map_generator: Node = $MapGenerator
@onready var lines_root: Node2D = %Lines

@onready var location_nodes_root: Control = %LocationNodes
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var locations_root: Control = %Locations

const MAP_LOCATION_SCENE: PackedScene = preload("res://tscn/map/map_location.tscn")
const X_STEP: float = 175.0
const Y_STEP: float = 150.0
const LINE_OFFSET: float = 7.0
const PATH_COUNT: int = 6
const TOP_PADDING: float = 625.0
const BOTTOM_PADDING: float = 250.0
const MAP_WIDTH: float = 1216.0
const SCROLL_STEP: float = 900.0 

var map_content_height: float = 0.0
var current_boss_type: String = "dragon"
var act: int = 1

var paths: Array = []
var connections: Dictionary = {}
var location_nodes: Dictionary = {}
var last_point: Vector2i
var has_started: bool = false

@warning_ignore("unused_signal")
signal act_completed
signal location_selected(location_type: String)

func generate_map(
	run_mode: String,
	difficulty: String,
	new_act: int
) -> void:
	act = new_act
	location_nodes.clear()
	has_started = false
	last_point = Vector2i(-1, -1)

	paths = map_generator.generate_paths(run_mode, difficulty)
	connections = map_generator.build_connections(paths)
	clear_lines()
	clear_location_nodes()

	current_boss_type = map_generator.get_random_boss_type()

	var map_height: int = map_generator.get_map_height_from_paths(paths)
	
	setup_scroll_size(map_height)

	draw_paths(paths)
	draw_locations(paths, run_mode, difficulty, map_height)

	call_deferred("scroll_to_bottom")
	focus_initial_location()
	DebugLogger.info(
		"Map generated: mode=%s, difficulty=%s, act=%d, height=%d, boss=%s, locations=%d"
		% [run_mode, difficulty, act, map_height, current_boss_type, location_nodes.size()]
	)

func draw_paths(paths_to_draw: Array) -> void:
	for path_index in range(paths_to_draw.size()):
		var path: Array = paths_to_draw[path_index]

		var line: Line2D = Line2D.new()
		line.width = 6.0
		line.antialiased = true
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.default_color = get_path_color(path_index)
		line.z_index = 0

		lines_root.add_child(line)

		for point in path:
			@warning_ignore("shadowed_global_identifier")
			var floor: int = point[0]
			var column: int = point[1]

			line.add_point(get_map_point(floor, column, path_index))

@warning_ignore("shadowed_global_identifier")
func get_map_point(floor: int, column: int, path_index: int) -> Vector2:
	var center_offset: float = (path_index - float(PATH_COUNT - 1) / 2.0) * LINE_OFFSET

	return Vector2(
		100.0 + column * X_STEP + center_offset,
		map_content_height - BOTTOM_PADDING - floor * Y_STEP
	)

func clear_lines() -> void:
	for child in lines_root.get_children():
		child.queue_free()

func clear_location_nodes() -> void:
	location_nodes.clear()

	for child in location_nodes_root.get_children():
		child.queue_free()

func get_path_color(index: int) -> Color:
	match index:
		0: return Color.LIME_GREEN
		1: return Color.YELLOW
		2: return Color.ORANGE
		3: return Color.RED
		4: return Color.CYAN
		5: return Color.PURPLE
		_: return Color.WHITE

func setup_scroll_size(map_height: int) -> void:
	map_content_height = (map_height + 2) * Y_STEP + TOP_PADDING + BOTTOM_PADDING

	locations_root.custom_minimum_size = Vector2(MAP_WIDTH, map_content_height)
	locations_root.size = locations_root.custom_minimum_size

func scroll_to_bottom() -> void:
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func _process(delta: float) -> void:
	if !visible: return
	
	if Input.is_action_pressed("scroll_down"):
		scroll_description(SCROLL_STEP * delta)

	if Input.is_action_pressed("scroll_up"):
		scroll_description(-SCROLL_STEP * delta)

func scroll_description(amount: float) -> void:
	var bar: VScrollBar = scroll_container.get_v_scroll_bar()
	scroll_container.scroll_vertical = clampi(
		scroll_container.scroll_vertical + int(amount),
		0,
		int(bar.max_value)
	)

func draw_locations(
	paths_to_draw: Array,
	mode: String,
	difficulty: String,
	boss_floor: int
) -> void:
	var points: Array = map_generator.get_unique_points_from_paths(paths_to_draw)

	for point in points:
		@warning_ignore("shadowed_global_identifier")
		var floor: int = point[0]
		var column: int = point[1]
		var map_point: Vector2i = Vector2i(floor, column)

		var location = MAP_LOCATION_SCENE.instantiate()
		location_nodes_root.add_child(location)

		var location_type: String = map_generator.generate_location_type(
			floor,
			act,
			difficulty,
			mode,
			boss_floor
		)
		var boss_type: String = ""

		if location_type == "boss":
			boss_type = current_boss_type

		location.setup(
			location_type,
			boss_type,
			is_valid_loc(floor, column),
			map_point
		)

		location.selected.connect(_on_location_selected)
		location_nodes[map_point] = location

		location.position = get_location_point(floor, column) - location.size * 0.5
		location.z_index = 10

@warning_ignore("shadowed_global_identifier")
func get_location_point(floor: int, column: int) -> Vector2:
	return Vector2(
		100.0 + column * X_STEP,
		map_content_height - BOTTOM_PADDING - floor * Y_STEP
	)

@warning_ignore("shadowed_global_identifier")
func is_valid_loc(floor: int, column: int) -> bool:
	var target: Vector2i = Vector2i(floor, column)

	if !has_started:
		return floor == 0

	return connections.has(last_point) and connections[last_point].has(target)

func _on_location_selected(point: Vector2i) -> void:
	if !location_nodes.has(point):
		DebugLogger.warning("Selected map point does not exist: %s" % point)
		return

	var selected_location: MapLocation = location_nodes[point]

	DebugLogger.info(
		"Location selected: point=%s, type=%s, act=%d"
		% [point, selected_location.location_type, act]
	)

	last_point = point
	has_started = true

	match selected_location.location_type:
		"enemy", "mini_boss", "shop", "rest", "hardware", "event":
			location_selected.emit(selected_location.location_type)
		"boss":
			DebugLogger.info("Boss location selected")
			location_selected.emit(selected_location.location_type)
			return

	var valid_locations: Array[MapLocation] = []

	for map_point: Vector2i in location_nodes:
		var location: MapLocation = location_nodes[map_point]

		var valid: bool = (
			connections.has(last_point)
			and connections[last_point].has(map_point)
		)

		location.set_valid(valid)

		if valid:
			valid_locations.append(location)

	if valid_locations.is_empty():
		DebugLogger.warning("No valid locations after selecting: %s" % point)

	focus_nearest_location(valid_locations, point)

func focus_nearest_location(
	locations: Array[MapLocation],
	from_point: Vector2i
) -> void:
	if locations.is_empty():
		return

	locations.sort_custom(
		func(a: MapLocation, b: MapLocation) -> bool:
			return abs(a.map_point.y - from_point.y) < abs(b.map_point.y - from_point.y)
	)

	var location: MapLocation = locations[0]
	location.grab_focus()
	scroll_container.ensure_control_visible(location)

func focus_initial_location() -> void:
	var valid_locations: Array[MapLocation] = []

	for location: MapLocation in location_nodes.values():
		if location.is_valid:
			valid_locations.append(location)

	if valid_locations.is_empty():
		return

	valid_locations.sort_custom(
		func(a: MapLocation, b: MapLocation) -> bool:
			return abs(a.map_point.y - 3) < abs(b.map_point.y - 3)
	)

	var location: MapLocation = valid_locations[0]
	location.grab_focus()
	scroll_container.ensure_control_visible(location)
