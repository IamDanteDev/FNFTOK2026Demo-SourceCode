extends Node2D

@onready var sound_player = $AudioStreamPlayer

var options_list: Array = ["Controls", "Combos", "Graphics", "Visuals", "Gameplay"]
var curSelected = 0
var optionsText: Array = []
var alphabet: Label

func _ready():
	for n in 5:
		alphabet = Label.new()
		optionsText.append(alphabet)
		$labelHolder.add_child(alphabet)
		alphabet.set_horizontal_alignment(1)
		alphabet.size.x = 1280
		alphabet.text = (options_list[n].to_upper())
		alphabet.position.y = 65 + 125 * n
		alphabet.modulate.a = 0.6

	updateCurSelected(0)

func _input(event):
	if event.is_action_pressed("up"):
		updateCurSelected(1)

	if event.is_action_pressed("down"):
		updateCurSelected(-1)

	if event.is_action_pressed("enter"):
		switchOptionsMenu()
		play_sound("res://assets/sounds/menu/menuConfirm_4.ogg")

	if event.is_action_pressed("cancel"):
		play_sound("res://assets/sounds/menu/menuCancel.ogg")
		Main.game_mode = "menu"
		Main.change_scene_transition("res://scenes/states/menus/main_menu/main_menu_new.tscn")


func updateCurSelected(change):
	optionsText[curSelected].text = (options_list[curSelected].to_upper())
	optionsText[curSelected].modulate.a = 0.6

	play_sound("res://assets/sounds/menu/menuScroll.ogg")

	curSelected -= change
	if (curSelected > options_list.size() - 1):
		curSelected = 0
	elif (curSelected < 0):
		curSelected = options_list.size() - 1

	optionsText[curSelected].text = ("[" + options_list[curSelected].to_upper() + "]")
	optionsText[curSelected].modulate.a = 1

func switchOptionsMenu():
	match options_list[curSelected]:
		"Controls":
			Main.change_scene_transition("res://scenes/states/menus/options_menu/controls_menu.tscn")
		"Graphics":
			Main.change_scene_transition("res://scenes/states/menus/options_menu/graphics_menu.tscn")
		"Visuals":
			Main.change_scene_transition("res://scenes/states/menus/options_menu/visuals_menu.tscn")
		"Gameplay":
			Main.change_scene_transition("res://scenes/states/menus/options_menu/gameplay_menu.tscn")

func play_sound(sound_effect: String):
	var sfx = load(sound_effect)
	sound_player.stream = sfx
	sound_player.play()
