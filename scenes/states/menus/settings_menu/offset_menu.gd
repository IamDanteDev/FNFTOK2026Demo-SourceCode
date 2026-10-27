extends Control

@onready var control = $Control
@onready var margin_container = $Control / MarginContainer
@onready var category_preset = $Control / MarginContainer / OptionContainer / category
@onready var option_container = $Control / MarginContainer / OptionContainer

@onready var preview_node = $Preview
@onready var rating_node = $Preview / HUD / Rating / Sprite
@onready var numbers_node = $Preview / HUD / Rating / Numbers
@onready var scanlines: Sprite2D = $scanlines

var HOLD_TIMER_LENGTH = 0.5
var HOLD_DELAY_LENGTH = 0.1

var optionslist: Array = []
var curSelected
var inPreview = false

var holdTimer = HOLD_TIMER_LENGTH
var holdDelay = HOLD_DELAY_LENGTH

@onready var settingslist: Dictionary = Weeks.load_json_file("res://scenes/states/menus/settings_menu/offset_dict.json")

func _ready():
	var combo_settings = Settings.load_combos()

	var new_category = category_preset.duplicate()
	option_container.add_child(new_category)
	new_category.get_child(0).text = "- - - Offset - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	new_category.get_child(1).queue_free()
	new_category.get_child(2).queue_free()
	new_category.visible = true

	for option in settingslist.get("Offset"):
		if option.get("type") == "preview":
			var new_preview = category_preset.find_child("preview").duplicate()
			new_category.add_child(new_preview)
			new_preview.text = option.get("name")
			new_preview.description = option.get("description")
			new_preview.type = option.get("type")
			new_preview.modulate.a = 0.5
			optionslist.append(new_preview)
		else:
			var new_option = category_preset.find_child("option").duplicate()
			new_category.add_child(new_option)
			new_option.description = option.get("description")
			new_option.get_child(0).text = option.get("name")

			match option.get("type"):
				"int":
					new_option.get_child(1).text = "[" + str(combo_settings.get(option.get("key"))) + "]"
				"intX":
					new_option.get_child(1).text = "[" + str(combo_settings.get(option.get("key"))[0]) + "]"
				"intY":
					new_option.get_child(1).text = "[" + str(combo_settings.get(option.get("key"))[1]) + "]"

			new_option.type = option.get("type")
			new_option.key = option.get("key")
			new_option.modulate.a = 0.5
			optionslist.append(new_option)

	preview_node.modulate.a = 0.0

	category_preset.queue_free()
	updateCurSelected(0)


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

func _process(delta):
	if !inPreview:
		if Input.is_action_pressed("right_ui") or Input.is_action_pressed("left_ui"):
			holdTimer -= delta
			holdDelay -= delta
		else:
			holdTimer = HOLD_TIMER_LENGTH
			holdDelay = HOLD_DELAY_LENGTH

		var shouldUpdateOption = (holdTimer <= 0 and holdDelay <= 0) or (Input.is_action_just_pressed("left_ui") or Input.is_action_just_pressed("right_ui"))

		if Input.is_action_just_pressed("up_ui"):
			updateCurSelected(-1)
		if Input.is_action_just_pressed("down_ui"):
			updateCurSelected(1)
		if curSelected.type == "preview":
			if Input.is_action_just_pressed("confirm"):
				play_sfx("res://assets/sounds/menu/menuConfirm_4.ogg")
				show_preview()
		else:
			var multiplier = 10 if Input.is_action_pressed("shift") else 1
			multiplier *= -1 if Input.is_action_pressed("left_ui") else 1

			if shouldUpdateOption:
				play_sfx("res://assets/sounds/menu/optionScroll.ogg")
				update_option(curSelected, 1 * multiplier)
				holdDelay = HOLD_DELAY_LENGTH

		scanlines.position.y += delta * 5

		if scanlines.position.y >= 1080.0:
			scanlines.position.y = 360.0

	if Input.is_action_just_pressed("cancel"):
		play_sfx("res://assets/sounds/menu/menuCancel.ogg")
		if inPreview:
			exit_preview()
		else:
			exit()

func play_sfx(path: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	get_parent().add_child(player)
	player.play()
	await player.finished
	player.queue_free()

func update_option(option, change):
	var combo_settings = Settings.load_combos()
	match option.get("type"):
		"int":
			show_apply()
			var key = option.get("key")
			var value = combo_settings.get(key)
			value += change
			option.get_child(1).text = "[" + str(value) + "]"
			Settings.save_combos(key, value)
		"intX":
			show_apply()
			var key = option.get("key")
			var value = combo_settings.get(key)
			value[0] += change
			option.get_child(1).text = "[" + str(value[0]) + "]"
			Settings.save_combos(key, value)
		"intY":
			show_apply()
			var key = option.get("key")
			var value = combo_settings.get(key)
			value[1] += change
			option.get_child(1).text = "[" + str(value[1]) + "]"
			Settings.save_combos(key, value)

func show_preview():
	var combo_settings = Settings.load_combos()

	var rating_offset = combo_settings.get("rating_offset")
	var numbers_offset = combo_settings.get("numbers_offset")

	inPreview = true
	rating_node.position = Vector2(0 + rating_offset[0], 0 + rating_offset[1])
	numbers_node.position = Vector2(105.0 + numbers_offset[0], 0 + numbers_offset[1])

	var tween = create_tween()
	tween.tween_property(preview_node, "modulate:a", 1.0, 0.2)

func exit_preview():
	inPreview = false
	var tween = create_tween()
	tween.tween_property(preview_node, "modulate:a", 0.0, 0.2)

func show_apply():
	if !$ApplyLabel.visible and get_parent().get_parent().get_parent() is PlayState:
		$ApplyLabel.visible = true
		$ApplyLabel / ApplyPlayer.play("pulse")

func exit():
	await get_tree().create_timer(0.1).timeout
	$ApplyLabel.reparent(get_parent())
	get_parent().active = true
	queue_free()
