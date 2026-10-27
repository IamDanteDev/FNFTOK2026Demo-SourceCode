extends Node









const VERSION_INFO = {
	"major": 0, 
	"minor": 6, 
	"patch": 0, 
	"status": "beta", 
}


const MAIN_MENU_PATH = "res://scenes/states/menus/main_menu/main_menu_new.tscn"
const FREEPLAY_PATH = "res://scenes/states/menus/freeplay_menu/freeplay_menu.tscn"
const SETTINGS_PATH = "res://scenes/states/menus/settings_menu/settings_menu.tscn"

const TRANSITION_SCENE = preload("res://scenes/other/transition/transition.tscn")
const MAIN_UI_THEME = preload("res://assets/resources/themes/main.tres")
const SOUNDTRAY_SCENE = preload("res://scenes/game/hud/soundtray/soundtray.tscn")

var Last_Story_Freeplay_Option = 0
var Last_Extra_Freeplay_Option = 0
var Active_Freeplay_Tab: String = "storytab"
var Inactive_Freeplay_Tab: String = "extratab"

var Last_Story_Chapter = 0

var game_mode: String
var difficulty: String
var chapter: String
var story_array: Array = []
var story_count: int = 0

var stage_name: String
var player_name: String
var enemy_name: String
var gf_name: String

var soundtray
var cur_chart

var boot_splashes: Array = ["res://Ilustracion_sin_titulo.png", "res://Ilustracion_sin_titulo_1.png", "res://Untitled_Artwork-14.png"]

var bf_skin_int = 0

func _input(event):
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_ENTER:
				if event.alt_pressed:
					var windowed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED or 
						DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED)

					if windowed:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
					else:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if event.is_action_pressed("vol_up"):
		if Main.game_mode != "editor":
			soundtray.update_volume(1)

	if event.is_action_pressed("vol_down"):
		if Main.game_mode != "editor":
			soundtray.update_volume(-1)

	if event.is_action_pressed("mute"):
		if Main.game_mode != "editor":
			soundtray.update_volume( - INF)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	soundtray = SOUNDTRAY_SCENE.instantiate()
	add_child(soundtray)
	_update_window_res(1600, 900)

func _update_window_res(size_x, size_y):
	DisplayServer.window_set_size(Vector2(size_x, size_y))
	print(str(size_y) + "p")
	center_window()

func center_window() -> void :
	var window = get_window()
	var screen = window.current_screen
	var screen_rect = DisplayServer.screen_get_usable_rect(screen)
	var window_size = window.get_size_with_decorations()
	window.position = screen_rect.position + (screen_rect.size / 2 - window_size / 2)


func _process(_delta):

	if not ResourceLoader.exists("res://veryimportantdog.jpg"):
		get_tree().quit()

	Debug.hud.add_property("FPS", snappedf(Performance.get_monitor(Performance.TIME_FPS), 0), 0)
	Debug.hud.add_property("MEM", str(snappedf(Performance.get_monitor(Performance.MEMORY_STATIC) * 1e-06, 1)) + "Mb", 1)







func get_version_info():
	var dict = VERSION_INFO.duplicate()


	var string_prefix = ""
	if dict.status != "":
		string_prefix += "-%s" % dict.status

	dict.string = "%s.%s.%s%s" % [
		dict.major, dict.minor, dict.patch, string_prefix
	]


	return dict

func get_song_data(song_name, song_difficulty = "hard"):
	difficulty = song_difficulty.to_upper()
	var song_data = {}
	song_data["chart_path"] = "res://assets/songs/%s/%s-%s.json" % [song_name, song_name, song_difficulty]
	var start_data = {"song_data": song_data}
	return start_data

func load_playstate(data, do_transition = true):
	if data != null:
		var play_state = PlayState.new()
		var song_data = data.get("song_data", {})
		play_state.chart_path = song_data.get("chart_path", "")
		if do_transition:
			Main.change_scene_transition(play_state)
		else:
			Main.change_scene(play_state)

func get_week_data(week_name):
	var week_path = "res://assets/weeks/%s.json" % [week_name]

	var week_string = FileAccess.get_file_as_string(week_path)
	var week_data = JSON.parse_string(week_string)
	if week_data:
		return week_data.get("songs")

func load_story_playstate(week_array):

	var data = get_song_data(week_array[0])

	if data != null:
		var play_state = PlayState.new()
		var song_data = data.get("song_data", {})
		play_state.chart_path = song_data.get("chart_path", "")
		story_array.clear()
		story_count = 0
		for i in week_array:
			story_array.append(i)

		Main.change_scene(play_state)

func reset_story_data():
	story_array.clear()
	story_count = 0


func change_scene(scene):
	if scene is String:
		get_tree().change_scene_to_file(scene)
		return

	if scene is PackedScene:
		scene = scene.instantiate()
	if scene is Node:
		change_scene_to_node(scene)


func create_popup(scene, title: String = "Popup", borderless: bool = false):
	var popup = PopupPanel.new()

	var node = scene
	if node is PackedScene:
		node = node.instantiate()

	popup.title = title
	popup.borderless = borderless

	popup.theme = MAIN_UI_THEME
	popup.extend_to_title = true

	popup.add_child(node)

	node.tree_exited.connect( func():
		popup.queue_free()
	)

	return popup


func change_scene_transition(scene, prefix: String = "normal"):
	var transition = TRANSITION_SCENE.instantiate()
	transition.prefix = prefix
	add_child(transition)


	await transition.transitioned

	change_scene(scene)


func change_scene_to_node(node: Node):
	get_tree().current_scene.name = "removing"
	get_tree().root.add_child(node, true)

	get_tree().current_scene.queue_free()
	get_tree().current_scene = node
