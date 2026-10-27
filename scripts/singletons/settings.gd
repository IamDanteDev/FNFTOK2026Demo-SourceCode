extends Node






var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"



var camera = {
	"camera_style": "fancy", 
	"camera_dynamic": true
}

var combos = {
	"rating_offset": [0, 0], 
	"numbers_offset": [0, 0], 
	"beat_offset": 0
}

var graphics = {
	"low_quality": false, 
	"anti_aliasing": true, 
	"shaders": true, 
	"framerate": "60", 
	"test_graphics": true
}

var visuals = {
	"hide_hud": false, 
	"time_bar": "disabled", 
	"flashing_lights": true, 
	"debug_mode": false, 
	"discord_rich": true, 
}

var gameplay = {
	"downscroll": false, 
	"midscroll": false, 
	"opponent_notes": false, 
	"ghost_tapping": true, 
	"combat_mechanic": true
}

var controls = {
	"left": ["Left", "A"], 
	"down": ["Down", "S"], 
	"up": ["Up", "W"], 
	"right": ["Right", "D"], 
	"reset": ["R"], 
	"pause": ["Enter"], 
	"left_ui": ["Left"], 
	"down_ui": ["Down"], 
	"up_ui": ["Up"], 
	"right_ui": ["Right"], 
	"confirm": ["Enter", "Space"], 
	"cancel": ["Escape", "Backspace"], 
	"enter": ["Enter"], 
	"vol_up": ["Equal"], 
	"vol_down": ["Minus"], 
	"mute": ["0"]
}

var offset: float = 0

var showcase: bool = false

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):

		set_default_control_values()

		for i in camera:
			config.set_value("camera", i, camera[i])

		for i in combos:
			config.set_value("combos", i, combos[i])

		for g in graphics:
			config.set_value("graphics", g, graphics[g])

		for v in visuals:
			config.set_value("visuals", v, visuals[v])

		for p in gameplay:
			config.set_value("gameplay", p, gameplay[p])

		config.set_value("sound", "sound_level", 5)

		config.save(SETTINGS_FILE_PATH)

	config.load(SETTINGS_FILE_PATH)
	refresh_input_map()

	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		for i in camera:
			if !config.has_section_key("camera", i):
				config.set_value("camera", i, camera[i])
				config.save(SETTINGS_FILE_PATH)
		for i in combos:
			if !config.has_section_key("combos", i):
				config.set_value("combos", i, combos[i])
				config.save(SETTINGS_FILE_PATH)
		for g in graphics:
			if !config.has_section_key("graphics", g):
				config.set_value("graphics", g, graphics[g])
				config.save(SETTINGS_FILE_PATH)
		for v in visuals:
			if !config.has_section_key("visuals", v):
				config.set_value("visuals", v, visuals[v])
				config.save(SETTINGS_FILE_PATH)
		for p in gameplay:
			if !config.has_section_key("gameplay", p):
				config.set_value("gameplay", p, gameplay[p])
				config.save(SETTINGS_FILE_PATH)
		for c in controls:
			if !config.has_section_key("controls", c):
				config.set_value("controls", c, controls[c])
				config.save(SETTINGS_FILE_PATH)

		if !config.has_section_key("sound", "sound_level"):
			config.set_value("sound", "sound_level", 5)
			config.save(SETTINGS_FILE_PATH)

	offset = config.get_value("combos", "beat_offset", 0.0)


func save_controls(action: StringName, event: InputEvent, row):
	var event_str
	var unused_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)

	if row == 0:
		if InputMap.action_get_events(action).size() > 1:
			unused_str = OS.get_keycode_string(InputMap.action_get_events(action)[1].physical_keycode)
			config.set_value("controls", action, [event_str, unused_str])
		else:
			config.set_value("controls", action, [event_str])
	elif row == 1:
		if InputMap.action_get_events(action).size() > 1:
			unused_str = OS.get_keycode_string(InputMap.action_get_events(action)[0].physical_keycode)
			config.set_value("controls", action, [unused_str, event_str])
		else:
			config.set_value("controls", action, [event_str])

	config.save(SETTINGS_FILE_PATH)

func save_camera(key: String, value):
	config.set_value("camera", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_camera():
	var camera_settings = {}
	for key in config.get_section_keys("camera"):
		camera_settings[key] = config.get_value("camera", key)
	return camera_settings

func save_combos(key: String, value):
	config.set_value("combos", key, value)
	config.save(SETTINGS_FILE_PATH)
	offset = config.get_value("combos", "beat_offset", 0.0)

func load_combos():
	var combo_settings = {}
	for key in config.get_section_keys("combos"):
		combo_settings[key] = config.get_value("combos", key)
	return combo_settings

func save_graphics(key: String, value):
	config.set_value("graphics", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_graphics():
	var graphic_settings = {}
	for key in config.get_section_keys("graphics"):
		graphic_settings[key] = config.get_value("graphics", key)
	return graphic_settings

func save_visuals(key: String, value):
	config.set_value("visuals", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_visuals():
	var visual_settings = {}
	for key in config.get_section_keys("visuals"):
		visual_settings[key] = config.get_value("visuals", key)
	return visual_settings

func save_gameplay(key: String, value):
	config.set_value("gameplay", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_gameplay():
	var gameplay_settings = {}
	for key in config.get_section_keys("gameplay"):
		gameplay_settings[key] = config.get_value("gameplay", key)
	return gameplay_settings

func set_default_control_values():
	for i in controls:
		config.set_value("controls", "pause", ["Enter"])

	config.save(SETTINGS_FILE_PATH)

func refresh_input_map():
	for action in config.get_section_keys("controls"):
		InputMap.action_erase_events(action)
		var events = config.get_value("controls", action)
		var first_event = events[0].to_upper()
		var first_input = InputEventKey.new()
		first_input.physical_keycode = OS.find_keycode_from_string(first_event)

		InputMap.action_add_event(action, first_input)
		if events.size() > 1:
			var second_input = InputEventKey.new()
			var second_event = events[1].to_upper()
			second_input.physical_keycode = OS.find_keycode_from_string(second_event)
			InputMap.action_add_event(action, second_input)

		pass
