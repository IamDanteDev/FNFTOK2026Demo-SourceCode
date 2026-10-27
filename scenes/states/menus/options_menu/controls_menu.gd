extends Control



@onready var InputNode = preload("res://scenes/states/menus/options_menu/elements/input_node.tscn")
@onready var HeaderNode = preload("res://scenes/states/menus/options_menu/elements/input_header.tscn")
@onready var InputList = $ControlsGUI / MarginContainer / InputList
@onready var rebindingGUI = $CanvasLayer2 / RebindingGUI
@onready var camera = $Camera2D
@onready var sound_player = $AudioStreamPlayer

var is_remapping: bool = false
var action_to_change = null
var selected_input = null
var curSelected: int = 0
var curRow: int = 0

var inputs = {
	"NOTES": "HEADER", 
	"left": "LEFT", 
	"down": "DOWN", 
	"up": "UP", 
	"right": "RIGHT", 
	"reset": "RESET", 
	"pause": "PAUSE", 
	"UI": "HEADER", 
	"left_ui": "LEFT UI", 
	"down_ui": "DOWN UI", 
	"up_ui": "UP UI", 
	"right_ui": "RIGHT UI", 
	"GAMEPLAY": "HEADER", 
	"dodge": "DODGE", 
	"confirm": "CONFIRM", 
	"cancel": "CANCEL", 
	"enter": "ENTER", 
	"VOLUME": "HEADER", 
	"vol_up": "VOL UP", 
	"vol_down": "VOL DOWN", 
	"mute": "Mute", 
	"RESET TO DEFAULT KEYS": "CLICK_HEADER"
}

var input_node_list = []
var input_text_list = []
var second_input_text_list = []
var action_list = []


func _ready():
	rebindingGUI.visible = false
	createInputList()
	updateCurSelected(0)

func createInputList():

	for i in InputList.get_children():
		i.queue_free()

	for action in inputs:
		if inputs[action] == "HEADER" || inputs[action] == "CLICK_HEADER":
			var header_node = HeaderNode.instantiate()
			header_node.text = action
			InputList.add_child(header_node)
			if inputs[action] == "CLICK_HEADER":
				header_node.modulate.a = 0.6
				input_node_list.append(header_node)
				action_list.append(action)

		else:
			var input_node = InputNode.instantiate()
			var action_label = input_node.find_child("InputName")
			var input_label = input_node.find_child("Input")
			var input_label2 = input_node.find_child("Input2")

			action_label.text = inputs[action]

			var events = InputMap.action_get_events(action)

			if events.size() > 1:
				input_label.text = events[0].as_text().trim_suffix(" (Physical)")
				input_label2.text = events[1].as_text().trim_suffix(" (Physical)")
			elif events.size() > 0:
				input_label.text = events[0].as_text().trim_suffix(" (Physical)")
				input_label2.text = ""
			else:
				input_label.text = ""

			input_node.modulate.a = 0.6

			reviewInputText(input_label)
			reviewInputText(input_label2)
			InputList.add_child(input_node)
			input_node_list.append(input_node)
			input_text_list.append(input_label)
			second_input_text_list.append(input_label2)
			action_list.append(action)

func _input(event):
	if is_remapping:
		if event is InputEventKey && event.pressed:
			if event.as_text().trim_suffix(" (Physical)") == "Tab":
				play_sound("res://assets/sounds/menu/menuOut.ogg")
				rebindingGUI.visible = false
				is_remapping = false
				return
			elif action_list[curSelected] == "RESET TO DEFAULT KEYS":
				play_sound("res://assets/sounds/menu/menuCancel.ogg")
				input_node_list.clear()
				input_text_list.clear()
				second_input_text_list.clear()
				action_list.clear()
				Settings.set_default_control_values()
				InputMap.load_from_project_settings()
				createInputList()
				updateCurSelected(0)
				rebindingGUI.visible = false
				is_remapping = false
				return

			var unused_event = null
			if InputMap.action_get_events(action_to_change).size() > 1 or InputMap.action_get_events(action_to_change).size() == 1 && curRow == 1:
				if curRow == 0:
					unused_event = InputMap.action_get_events(action_to_change)[1]
				else:
					unused_event = InputMap.action_get_events(action_to_change)[0]

			if unused_event != null:
				if event.as_text().trim_suffix(" (Physical)") == unused_event.as_text().trim_suffix(" (Physical)"):
					play_sound("res://assets/sounds/menu/menuError.ogg")
					return

			InputMap.action_erase_events(action_to_change)

			print(unused_event)
			if unused_event != null:
				if curRow == 0:
					print("this is writing")
					InputMap.action_add_event(action_to_change, event)
					InputMap.action_add_event(action_to_change, unused_event)
				else:
					InputMap.action_add_event(action_to_change, unused_event)
					InputMap.action_add_event(action_to_change, event)
			else:
				InputMap.action_add_event(action_to_change, event)

			print(InputMap.action_get_events(action_to_change))

			Settings.save_controls(action_to_change, event, curRow)

			if curRow == 0:
				updateInputText(input_text_list[curSelected], event)
			else:
				updateInputText(second_input_text_list[curSelected], event)

			play_sound("res://assets/sounds/menu/menuConfirm_1.ogg")
			rebindingGUI.visible = false

			is_remapping = false
			action_to_change = null
			return

	if !is_remapping:
		if event.is_action_pressed("cancel"):
			play_sound("res://assets/sounds/menu/menuCancel.ogg")
			Main.change_scene_transition("res://scenes/states/menus/options_menu/options_menu.tscn")
		if event.is_action_pressed("up_ui"):
			updateCurSelected(-1)
		if event.is_action_pressed("down_ui"):
			updateCurSelected(1)
		if event.is_action_pressed("right_ui"):
			updateCurRow(1)
		if event.is_action_pressed("left_ui"):
			updateCurRow(-1)
		if event.is_action_pressed("enter"):
			play_sound("res://assets/sounds/menu/menuConfirm_4.ogg")
			beginRemapping(action_list[curSelected])
			accept_event()

func updateCurSelected(change):

	curSelected += change

	if curSelected < 0:
		curSelected = 0
		return
	if curSelected > input_node_list.size() - 1:
		curSelected = input_node_list.size() - 1
		return

	if change > 0:
		play_sound("res://assets/sounds/menu/menuClickDown.ogg")
	else:
		play_sound("res://assets/sounds/menu/menuClickUp.ogg")

	for i in input_node_list:
		i.modulate.a = 0.6
	input_node_list[curSelected].modulate.a = 1
	updateCurRow(0)

	camera.position = Vector2(0, (curSelected * inputs.size() * 5))

func updateCurRow(change):
	curRow += change

	if curRow < 0:
		curRow = 0
		return
	elif curRow > 1:
		curRow = 1
		return

	if change > 0:
		play_sound("res://assets/sounds/menu/menuPageDown.ogg")
	else:
		play_sound("res://assets/sounds/menu/menuPageUp.ogg")

	if input_node_list[curSelected].get_child_count() > 0:
		if curRow == 0:
			input_node_list[curSelected].find_child("InputBG").modulate.a = 1
			input_node_list[curSelected].find_child("InputBG2").modulate.a = 0.6
		elif curRow == 1:
			input_node_list[curSelected].find_child("InputBG2").modulate.a = 1
			input_node_list[curSelected].find_child("InputBG").modulate.a = 0.6



func beginRemapping(action):
	rebindingGUI.modulate.a = 0

	if action == "RESET TO DEFAULT KEYS":
		rebindingGUI.find_child("KeyText").text = "Reset to default keys?\nThis action cannot be undone."
	else:
		rebindingGUI.find_child("KeyText").text = "Rebinding Key " + action.capitalize().to_upper()

	rebindingGUI.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(rebindingGUI, "modulate:a", 1, 0.5).from_current()
	if action != "RESET TO DEFAULT KEYS":
		action_to_change = action
	is_remapping = true

func updateInputText(current_node, event):
	current_node.text = event.as_text().trim_suffix(" (Physical)")
	reviewInputText(current_node)

func play_sound(sound_effect: String):
	var sfx = load(sound_effect)
	sound_player.stream = sfx
	sound_player.play()

func reviewInputText(input_text):
	match input_text.text:
		"Escape":
			input_text.text = "Esc"
		"Backspace":
			input_text.text = "Bkspc"
		"Equal":
			input_text.text = "+"
		"Minus":
			input_text.text = "-"
