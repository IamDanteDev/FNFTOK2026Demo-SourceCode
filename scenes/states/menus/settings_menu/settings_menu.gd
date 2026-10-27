extends CanvasLayer

@onready var control = $Control
@onready var margin_container = $Control / MarginContainer
@onready var category_preset = $Control / MarginContainer / OptionContainer / category
@onready var option_container = $Control / MarginContainer / OptionContainer
@onready var scanlines: Sprite2D = $scanlines

var optionslist: Array = []
var curSelected
var active: bool = false
var deleting_data: bool = false;

@onready var settingslist: Dictionary = Weeks.load_json_file("res://scenes/states/menus/settings_menu/options_dict.json")
var KEYBINDS_MENU = preload("res://scenes/states/menus/options_menu/new_controls_menu.tscn")
var OFFSET_MENU = preload("res://scenes/states/menus/settings_menu/offset_menu.tscn")
var CAMERA_MENU = preload("res://scenes/states/menus/settings_menu/camera_menu.tscn")

var darkness

func _process(delta: float) -> void :
	scanlines.position.y += delta * 5

	if scanlines.position.y >= 1080.0:
		scanlines.position.y = 360.0

func _ready():
	var visual_settings = Settings.load_visuals()
	var graphic_settings = Settings.load_graphics()
	var gameplay_settings = Settings.load_gameplay()
	for category in settingslist:
		var new_category = category_preset.duplicate()
		option_container.add_child(new_category)
		new_category.get_child(0).text = "- - - " + category + " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
		new_category.get_child(1).queue_free()
		for option in settingslist.get(category):
			var new_option = category_preset.find_child("option").duplicate()
			new_category.add_child(new_option)
			new_option.description = option.get("description")
			new_option.get_child(0).text = option.get("name")

			match option.get("type"):
				"bool":
					if category == "Graphics":
						if graphic_settings.get(option.get("key")) == true:
							new_option.get_child(1).text = "[ON]"
						else:
							new_option.get_child(1).text = "[OFF]"
					elif category == "Visuals & UI":
						if visual_settings.get(option.get("key")) == true:
							new_option.get_child(1).text = "[ON]"
						else:
							new_option.get_child(1).text = "[OFF]"
					elif category == "Gameplay":
						if gameplay_settings.get(option.get("key")) == true:
							new_option.get_child(1).text = "[ON]"
						else:
							new_option.get_child(1).text = "[OFF]"
				"select":
					if category == "Graphics":
						new_option.get_child(1).text = "[" + str(graphic_settings.get(option.get("key"))).capitalize().to_upper() + "]"
					if category == "Visuals & UI":
						new_option.get_child(1).text = "[" + str(visual_settings.get(option.get("key"))).capitalize().to_upper() + "]"
					if category == "Gameplay":
						new_option.get_child(1).text = "[" + str(gameplay_settings.get(option.get("key"))).capitalize().to_upper() + "]"
				"menu":
					new_option.get_child(1).text = ""


			new_option.type = option.get("type")
			new_option.key = option.get("key")
			new_option.modulate.a = 0.5
			optionslist.append(new_option)
		new_category.visible = true
	category_preset.queue_free()
	updateCurSelected(0)
	enter()

func enter():
	for i in [$bg, $bottomcover, $topcover, $ShaderRect, $Filter, $scanlines]:
		i.modulate.a = 0
	for i in [$Settings, $Control, $description_box]:
		i.modulate.a = 0

	if Conductor.cur_song == "menu_theme":
		var settings_theme = load("res://assets/music/ShopMenu.ogg")
		Conductor.transition_track(settings_theme, 1.5)

	var t1 = create_tween().set_parallel()
	t1.tween_property($sprites, "position:x", 168.0, 0.4).from(-217.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	if darkness:
		t1.tween_property(darkness, "modulate:a", 0.5, 0.5)

	await get_tree().create_timer(0.1).timeout

	var t2 = create_tween().set_parallel()
	for i in [$ShaderRect, $bg]:
		t2.tween_property(i, "modulate:a", 1, 0.2).from(0)
	t2.tween_property($Filter, "modulate:a", 0.6, 0.2).from(0)
	t2.tween_property($scanlines, "modulate:a", 0.25, 0.2).from(0)

	await t2.finished

	for i in [$bottomcover, $topcover]:
		i.modulate.a = 1

	active = true

	var t3 = create_tween()
	t3.tween_property($Settings, "modulate:a", 1, 0.05).from(0)
	t3.tween_property($Settings, "modulate:a", 0, 0.05).from(1)
	t3.tween_property($Settings, "modulate:a", 1, 0.05).from(0)

	var t4 = create_tween()
	t4.tween_property($Control, "modulate:a", 1, 0.05).from(0)
	t4.tween_property($Control, "modulate:a", 0, 0.05).from(1)
	t4.tween_property($Control, "modulate:a", 1, 0.05).from(0)

	var t5 = create_tween()
	t5.tween_property($description_box, "modulate:a", 1, 0.05).from(0)
	t5.tween_property($description_box, "modulate:a", 0, 0.05).from(1)
	t5.tween_property($description_box, "modulate:a", 1, 0.05).from(0)



func updateCurSelected(amt):
	if curSelected == null:
		curSelected = optionslist[0]
	var curInt: int = optionslist.find(curSelected)

	if curInt + amt > optionslist.size() - 1:
		return
	if curInt + amt < 0:
		return

	if amt != 0:
		play_sfx("res://assets/sounds/menu/optionScroll.ogg")
	curSelected.modulate.a = 0.5
	curSelected = optionslist[curInt + amt]
	curSelected.modulate.a = 1
	control.position.y = - curSelected.get_parent().position.y - curSelected.position.y + (45 * 4)
	control.position.y = clamp(control.position.y, -830, 31)
	$description_box / MarginContainer / Description.text = curSelected.description

func _input(event):
	if deleting_data:
		if event.is_action_pressed("confirm"):
			const SETTINGS_FILE_PATH = "user://settings.ini"
			const SAVE_DATA = "user://save_data.save"
			if FileAccess.file_exists(SETTINGS_FILE_PATH):
				DirAccess.remove_absolute(SETTINGS_FILE_PATH)

			if FileAccess.file_exists(SAVE_DATA):
				DirAccess.remove_absolute(SAVE_DATA)

			get_tree().quit()

	if active and !deleting_data:

		if event.is_action_pressed("up_ui"):
			updateCurSelected(-1)
		if event.is_action_pressed("down_ui"):
			updateCurSelected(1)
		if event.is_action_pressed("confirm"):
			play_sfx("res://assets/sounds/menu/optionEnable.ogg")
			update_option(curSelected, 1)
		if event.is_action_pressed("cancel"):
			active = false
			play_sfx("res://assets/sounds/menu/menuCancel.ogg")
			exit()
		if curSelected.get("type") != "menu":
			if event.is_action_pressed("left_ui"):
				play_sfx("res://assets/sounds/menu/optionEnable.ogg")
				update_option(curSelected, -1)
			if event.is_action_pressed("right_ui"):
				play_sfx("res://assets/sounds/menu/optionEnable.ogg")
				update_option(curSelected, 1)

	if deleting_data:
		if event.is_action_pressed("cancel"):
			deleting_data = false;
			updateCurSelected(0)

func play_sfx(path: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	get_parent().add_child(player)
	player.play()
	await player.finished
	player.queue_free()

func update_option(option, change):
	var visual_settings = Settings.load_visuals()
	var graphic_settings = Settings.load_graphics()
	var gameplay_settings = Settings.load_gameplay()
	match option.get("type"):
		"bool":
			show_apply()
			for category in settingslist:
				if category == "Graphics":
					if graphic_settings.get(option.get("key")) == true:
						option.get_child(1).text = "[OFF]"
						Settings.save_graphics(option.get("key"), false)
					elif graphic_settings.get(option.get("key")) == false:
						option.get_child(1).text = "[ON]"
						Settings.save_graphics(option.get("key"), true)
				elif category == "Visuals & UI":
					if visual_settings.get(option.get("key")) == true:
						option.get_child(1).text = "[OFF]"
						Settings.save_visuals(option.get("key"), false)
					elif visual_settings.get(option.get("key")) == false:
						option.get_child(1).text = "[ON]"
						Settings.save_visuals(option.get("key"), true)
				elif category == "Gameplay":
					if gameplay_settings.get(option.get("key")) == true:
						option.get_child(1).text = "[OFF]"
						Settings.save_gameplay(option.get("key"), false)
					elif gameplay_settings.get(option.get("key")) == false:
						option.get_child(1).text = "[ON]"
						Settings.save_gameplay(option.get("key"), true)
		"select":
			show_apply()
			for category in settingslist:
				if category == "Graphics":
					if option.get("key") == "framerate":
						var select_values: Array = ["30", "60", "120", "240"]
						var current_value
						var new_value
						for n in select_values.size():
							if select_values[n] == Settings.config.get_value("graphics", "framerate"):
								current_value = select_values.find(Settings.config.get_value("graphics", "framerate"))
						new_value = current_value + change
						if new_value > select_values.size() - 1:
							new_value = 0
						elif new_value < 0:
							new_value = select_values.size() - 1
						Engine.max_fps = int(select_values[new_value])
						option.get_child(1).text = "[" + str(select_values[new_value]) + "]"
						Settings.save_graphics("framerate", select_values[new_value])
				if category == "Visuals & UI":
					if option.get("key") == "time_bar":
						var select_values: Array = ["disabled", "song_name", "time_left", "time_elapsed"]
						var current_value
						var new_value
						for n in select_values.size():
							if select_values[n] == Settings.config.get_value("visuals", "time_bar"):
								current_value = select_values.find(Settings.config.get_value("visuals", "time_bar"))
						new_value = current_value + change
						if new_value > select_values.size() - 1:
							new_value = 0
						elif new_value < 0:
							new_value = select_values.size() - 1
						Engine.max_fps = int(select_values[new_value])
						option.get_child(1).text = "[" + str(select_values[new_value]).capitalize().to_upper() + "]"
						Settings.save_visuals("time_bar", select_values[new_value])
		"menu":
			match option.get("key"):
				"KEYBINDS":
					active = false
					var menu
					menu = KEYBINDS_MENU.instantiate()
					add_child(menu)
					$ApplyLabel.reparent(menu)

				"OFFSET":
					active = false
					var menu
					menu = OFFSET_MENU.instantiate()
					add_child(menu)
					$ApplyLabel.reparent(menu)
				"CAMERA":
					active = false
					var menu
					menu = CAMERA_MENU.instantiate()
					add_child(menu)
					$ApplyLabel.reparent(menu)
				"LANGUAGE":
					print("transitioning to language menu!")
				"DELETE":
					deleting_data = true;
					$description_box / MarginContainer / Description.text = "WARNING! You are deleting your save data. This cannot be undone. CANCEL if you would like to go back. If you continue, the game will close and your save data will be deleted."
					print("transitioning to delete menu!")

func show_apply():
	if !$ApplyLabel.visible and get_parent().get_parent() is PlayState:
		$ApplyLabel.visible = true
		$ApplyLabel / ApplyPlayer.play("pulse")

func exit():

	var t1 = create_tween().set_parallel()
	t1.tween_property($sprites, "position:x", -217.0, 0.5).from(168.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)


	var t3 = create_tween()
	t3.tween_property($Settings, "modulate:a", 0, 0.05).from(1)
	t3.tween_property($Settings, "modulate:a", 1, 0.05).from(0)

	$ApplyLabel / ApplyPlayer.stop()
	var t4 = create_tween()
	t4.tween_property($ApplyLabel, "modulate:a", 0, 0.05).from(1)
	t4.tween_property($ApplyLabel, "modulate:a", 1, 0.05).from(0)

	var t5 = create_tween()
	t5.tween_property($Control, "modulate:a", 0, 0.05).from(1)
	t5.tween_property($Control, "modulate:a", 1, 0.05).from(0)

	var t6 = create_tween()
	t6.tween_property($description_box, "modulate:a", 0, 0.05).from(1)
	t6.tween_property($description_box, "modulate:a", 1, 0.05).from(0)

	await t6.finished



	for i in [$bottomcover, $topcover, $Settings, $ApplyLabel, $Control, $description_box]:
		i.modulate.a = 0

	var t2 = create_tween().set_parallel()
	t2.tween_property($ShaderRect, "modulate:a", 0, 0.1)
	t2.tween_property($bg, "modulate:a", 0, 0.2)
	t2.tween_property($Filter, "modulate:a", 0, 0.2)
	t2.tween_property($scanlines, "modulate:a", 0, 0.2)

	if darkness:
		t2.tween_property(darkness, "modulate:a", 0, 0.5)

	if Conductor.cur_song == "menu_theme":
		get_parent().cam_zoom = 0.76
		var main_theme = load("res://assets/music/MainMenu.ogg")
		Conductor.transition_track(main_theme, 1.5)

	await t1.finished
	get_parent().active = true
	queue_free()
