extends Node2D

@onready var sound_player = $AudioStreamPlayer

var options_dict: Dictionary = {
	"Hide HUD": "bool", 
	"Time Bar": "select", 
	"Flashing Lights": "bool", 
	"Camera Zooms": "bool", 
	"FPS Counter": "bool"
}
var curSelected = 0

var optionsText: Array = []
var checkboxes: Array = []
var multi_selects: Array = []
var alphabet: Label
var multi_select
var checkbox

func _ready():
	var visual_settings = Settings.load_visuals()

	for n in options_dict.size():
		alphabet = Label.new()
		optionsText.append(alphabet)
		$label_holder.add_child(alphabet)
		alphabet.set_horizontal_alignment(1)
		alphabet.size.x = 1280
		alphabet.text = (options_dict.keys()[n].to_upper())
		alphabet.position.y = 65 + 125 * n
		alphabet.modulate.a = 0.6

	for n in options_dict.size():
		if options_dict[options_dict.keys()[n]] == "bool":
			checkbox = load("res://scenes/states/menus/options_menu/elements/checkbox.tscn")
			checkbox = checkbox.instantiate()
			checkboxes.append(checkbox)
			add_child(checkbox)
			checkbox.section = "visuals"
			checkbox.key = options_dict.keys()[n].to_snake_case()
			checkbox.position = Vector2(optionsText[n].position.x + 200, optionsText[n].position.y + 45)
		elif options_dict[options_dict.keys()[n]] == "select":
			multi_select = load("res://scenes/states/menus/options_menu/elements/multi_select.tscn")
			multi_select = multi_select.instantiate()
			multi_selects.append(multi_select)
			add_child(multi_select)
			multi_select.section = "visuals"
			multi_select.key = options_dict.keys()[n].to_snake_case()
			multi_select.position = Vector2(optionsText[n].position.x + 25, optionsText[n].position.y + 12)

	updateCurSelected(0)

func _input(event):
	if event.is_action_pressed("up"):
		updateCurSelected(1)

	if event.is_action_pressed("down"):
		updateCurSelected(-1)

	if options_dict[options_dict.keys()[curSelected]] == "select":
		if event.is_action_pressed("right"):
			updateSelectOptions(1)
		elif event.is_action_pressed("left"):
			updateSelectOptions(-1)

	if options_dict[options_dict.keys()[curSelected]] == "bool":
		if event.is_action_pressed("enter"):
			switchOptionsMenu()

	if event.is_action_pressed("cancel"):
		Main.change_scene_transition("res://scenes/states/menus/options_menu/options_menu.tscn")

func updateCurSelected(change):
	optionsText[curSelected].text = (options_dict.keys()[curSelected].to_upper())
	optionsText[curSelected].modulate.a = 0.6

	curSelected -= change

	play_sound("res://assets/sounds/menu/menuScroll.ogg")


	if (curSelected > options_dict.size() - 1):
		curSelected = 0
	elif (curSelected < 0):
		curSelected = options_dict.size() - 1

	optionsText[curSelected].text = ("[" + options_dict.keys()[curSelected].to_upper() + "]")
	optionsText[curSelected].modulate.a = 1

func switchOptionsMenu():
	var visual_settings = Settings.load_visuals()
	match options_dict.keys()[curSelected]:
		"Hide HUD":
			if !visual_settings.hide_hud:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_visuals("hide_hud", !visual_settings.hide_hud)

		"Flashing Lights":
			if !visual_settings.flashing_lights:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_visuals("flashing_lights", !visual_settings.flashing_lights)

		"Camera Zooms":
			if !visual_settings.camera_zooms:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_visuals("camera_zooms", !visual_settings.camera_zooms)

		"Debug Mode":
			if !visual_settings.debug_mode:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_visuals("debug_mode", !visual_settings.debug_mode)

func updateSelectOptions(change: int):
	var visual_settings = Settings.load_visuals()

	match options_dict.keys()[curSelected]:
		"Time Bar":
			play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			var select_values: Array = ["time_left", "time_elapsed", "song_name", "disabled"]
			var current_value
			var new_value
			for n in select_values.size():
				if select_values[n] == Settings.config.get_value("visuals", "time_bar"):
					current_value = select_values.find(Settings.config.get_value("visuals", "time_bar"))
				else:
					pass

			new_value = current_value + change
			if new_value > select_values.size() - 1:
				new_value = 0
			elif new_value < 0:
				new_value = select_values.size() - 1

			Settings.save_visuals("time_bar", select_values[new_value])


func play_sound(sound_effect: String):
	var sfx = load(sound_effect)
	sound_player.stream = sfx
	sound_player.play()
