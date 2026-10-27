extends Control

@onready var control = $Control
@onready var margin_container = $Control / MarginContainer
@onready var category_preset = $Control / MarginContainer / OptionContainer / category
@onready var option_container = $Control / MarginContainer / OptionContainer
@onready var scanlines: Sprite2D = $scanlines

var optionslist: Array = []
var curSelected

@onready var settingslist: Dictionary = Weeks.load_json_file("res://scenes/states/menus/settings_menu/camera_dict.json")

func _ready():
	var camera_settings = Settings.load_camera()

	var new_category = category_preset.duplicate()
	option_container.add_child(new_category)
	new_category.get_child(0).text = "- - - Camera - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	new_category.get_child(1).queue_free()
	new_category.visible = true

	for option in settingslist.get("Camera"):
		var new_option = category_preset.find_child("option").duplicate()
		new_category.add_child(new_option)
		new_option.description = option.get("description")
		new_option.get_child(0).text = option.get("name")

		match option.get("type"):
			"bool":
				if camera_settings.get(option.get("key")) == true:
					new_option.get_child(1).text = "[ON]"
				else:
					new_option.get_child(1).text = "[OFF]"
			"select":
				new_option.get_child(1).text = "[" + str(camera_settings.get(option.get("key"))).capitalize().to_upper() + "]"

		new_option.type = option.get("type")
		new_option.key = option.get("key")
		new_option.modulate.a = 0.5
		optionslist.append(new_option)

	category_preset.queue_free()
	updateCurSelected(0)

func _process(delta: float) -> void :
	scanlines.position.y += delta * 5

	if scanlines.position.y >= 1080.0:
		scanlines.position.y = 360.0

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
	control.position.y = clamp(control.position.y, 0, 0)
	$NinePatchRect / MarginContainer / Description.text = curSelected.description

func _input(event):
	if event.is_action_pressed("up_ui"):
		updateCurSelected(-1)
	if event.is_action_pressed("down_ui"):
		updateCurSelected(1)
	if event.is_action_pressed("confirm"):
		play_sfx("res://assets/sounds/menu/optionEnable.ogg")
		update_option(curSelected, 1)
	if event.is_action_pressed("left_ui"):
		play_sfx("res://assets/sounds/menu/optionEnable.ogg")
		update_option(curSelected, -1)
	if event.is_action_pressed("right_ui"):
		play_sfx("res://assets/sounds/menu/optionEnable.ogg")
		update_option(curSelected, 1)
	if event.is_action_pressed("cancel"):
		play_sfx("res://assets/sounds/menu/menuCancel.ogg")
		exit()

func play_sfx(path: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	get_parent().add_child(player)
	player.play()
	await player.finished
	player.queue_free()

func update_option(option, change):
	var camera_settings = Settings.load_camera()
	match option.get("type"):
		"bool":
			show_apply()
			if camera_settings.get(option.get("key")) == true:
				option.get_child(1).text = "[OFF]"
				Settings.save_camera(option.get("key"), false)
			elif camera_settings.get(option.get("key")) == false:
				option.get_child(1).text = "[ON]"
				Settings.save_camera(option.get("key"), true)
		"select":
			show_apply()
			if option.get("key") == "camera_style":
				var select_values: Array = ["fancy", "simple", "static"]
				var current_value
				var new_value
				for n in select_values.size():
					if select_values[n] == camera_settings.get("camera_style"):
						current_value = select_values.find(camera_settings.get("camera_style"))
				new_value = current_value + change
				if new_value > select_values.size() - 1:
					new_value = 0
				elif new_value < 0:
					new_value = select_values.size() - 1
				option.get_child(1).text = "[" + str(select_values[new_value]).capitalize().to_upper() + "]"
				Settings.save_camera("camera_style", select_values[new_value])

func show_apply():
	if !$ApplyLabel.visible and get_parent().get_parent().get_parent() is PlayState:
		$ApplyLabel.visible = true
		$ApplyLabel / ApplyPlayer.play("pulse")

func exit():
	await get_tree().create_timer(0.1).timeout
	$ApplyLabel.reparent(get_parent())
	get_parent().active = true
	queue_free()
