extends Control
class_name ChoiceMenu

signal option_selected(index)
signal option_changed(index)


@export var choices: PackedStringArray: set = set_choices

@export var spacing: = Vector2(0, 100)

@export var unselected_color: = Color.GRAY

var font = preload("res://assets/resources/fonts/New Super Mario Font U.ttf")

@export var choice_node: Label


var allow_input: bool = true


var selected: int

var alphabet_node: Node


var scroll_stream: AudioStream = preload("res://assets/sounds/menu/menuScroll.ogg")

var scroll_player: AudioStreamPlayer


var last_selected: int


@onready var spawn_position: Vector2 = position


func _ready():
	alphabet_node = Node2D.new()
	add_child(alphabet_node)




	create_choices()

	scroll_player = AudioStreamPlayer.new()
	scroll_player.bus = "SFX"
	scroll_player.stream = scroll_stream
	add_child(scroll_player)


func _process(_delta):
	var _i = 0

	for _choice in alphabet_node.get_children():
		if _i == selected:
			_choice.modulate = Color.WHITE
		else:
			_choice.modulate = unselected_color



		if _i == 0:
			_choice.position.y = 0

		_choice.position = lerp(_choice.position, _i * spacing, _delta * 10)

		_i += 1




func _unhandled_input(event):
	if !allow_input:
		return

	if !get_parent().active:
		return

	if event.is_pressed():
		if event.is_action("up_ui"):
			selected -= 1

		if event.is_action("down_ui"):
			selected += 1

	if event.is_action_pressed("confirm"):
		do_option_selected()

	if selected < 0:
		selected = len(choices) - 1
	if selected > len(choices) - 1:
		selected = 0

	if last_selected != selected:
		do_option_changed()

	last_selected = selected


func create_choices() -> void :
	if alphabet_node == null:
		return

	for _existing_choice in alphabet_node.get_children():
		_existing_choice.queue_free()

	var _i = 0
	for _choice in choices:
		var _scene = choice_node.duplicate()

		_scene.text = _choice
		_scene.name = str(_i)
		_scene.mouse_filter = MOUSE_FILTER_IGNORE
		_scene.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_scene.add_theme_font_override("a", font)

		alphabet_node.add_child(_scene)

		_i += 1


func do_option_selected():
	emit_signal("option_selected", selected)


func do_option_changed():
	emit_signal("option_changed", selected)

	scroll_player.play()



func set_choices(_value):
	choices = _value
	create_choices()
