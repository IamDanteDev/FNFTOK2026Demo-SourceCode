extends Node2D

@onready var sound_player = $AudioStreamPlayer

var options_list: Array = ["Downscroll", "Midscroll", "Opponent Notes", "Ghost Tapping"]
var curSelected = 0

var optionsText: Array = []
var checkboxes: Array = []
var alphabet: Label
var checkbox

func _ready():
	var gameplay_settings = Settings.load_gameplay()



	for n in options_list.size():
		alphabet = Label.new()
		optionsText.append(alphabet)
		$label_holder.add_child(alphabet)
		alphabet.set_horizontal_alignment(1)
		alphabet.size.x = 1280
		alphabet.text = (options_list[n].to_upper())
		alphabet.position.y = 65 + 125 * n
		alphabet.modulate.a = 0.6

	for f in options_list.size():
		checkbox = load("res://scenes/states/menus/options_menu/elements/checkbox.tscn")
		checkbox = checkbox.instantiate()
		checkboxes.append(checkbox)
		add_child(checkbox)
		checkbox.section = "gameplay"
		checkbox.key = options_list[f].to_snake_case()
		checkbox.position = Vector2(optionsText[f].position.x + 200, optionsText[f].position.y + 45)

	updateCurSelected(0)

func _input(event):
	if event.is_action_pressed("up"):
		updateCurSelected(1)

	if event.is_action_pressed("down"):
		updateCurSelected(-1)

	if event.is_action_pressed("enter"):
		switchOptionsMenu()

	if event.is_action_pressed("cancel"):
		Main.change_scene_transition("res://scenes/states/menus/options_menu/options_menu.tscn")

func updateCurSelected(change):
	optionsText[curSelected].text = (options_list[curSelected].to_upper())
	optionsText[curSelected].modulate.a = 0.6

	curSelected -= change

	play_sound("res://assets/sounds/menu/menuScroll.ogg")


	if (curSelected > options_list.size() - 1):
		curSelected = 0
	elif (curSelected < 0):
		curSelected = options_list.size() - 1

	optionsText[curSelected].text = ("[" + options_list[curSelected].to_upper() + "]")
	optionsText[curSelected].modulate.a = 1

func switchOptionsMenu():
	var gameplay_settings = Settings.load_gameplay()
	match options_list[curSelected]:
		"Downscroll":
			if !gameplay_settings.downscroll:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_gameplay("downscroll", !gameplay_settings.downscroll)

		"Midscroll":
			if !gameplay_settings.midscroll:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_gameplay("midscroll", !gameplay_settings.midscroll)

		"Opponent Notes":
			if !gameplay_settings.opponent_notes:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_gameplay("opponent_notes", !gameplay_settings.opponent_notes)

		"Ghost Tapping":
			if !gameplay_settings.ghost_tapping:
				play_sound("res://assets/sounds/menu/menuClickUp.ogg")
			else:
				play_sound("res://assets/sounds/menu/menuClickDown.ogg")

			Settings.save_gameplay("ghost_tapping", !gameplay_settings.ghost_tapping)

func play_sound(sound_effect: String):
	var sfx = load(sound_effect)
	sound_player.stream = sfx
	sound_player.play()
