class_name StrumLine
extends Node2D








signal note_hit(note, button)

signal note_held(note, button)
signal held_hit(note, button)

signal note_missed(note, button)

signal button_whiffed(button)

signal button_released(button)

signal three_button_dodge


const STRUM_BUTTON_SCENE = preload("res://scenes/game/strum_button/strum_button.tscn")



@export var button_count: int = 4


@export var button_actions: PackedStringArray = [
	"left", "down", "up", "right"
]:
	set = _set_button_actions


@export var bot: bool = false:
	set = _set_bot



var offset: float = 0.0:
	set = _set_offset


var offset_lerp: float = 0.0:
	set = _set_offset_lerp


var scroll_multi: float = 1.0:
	set = _set_scroll_multi



var seperation: float = 160.0

var held_buttons = []


var buttons: Array

@onready var ghost_tapping = Settings.load_gameplay().ghost_tapping


func _ready():
	_create_buttons()

func _process(delta):
	if is_equal_approx(offset_lerp, offset):
		offset_lerp = offset
	else:
		offset_lerp = lerp(offset_lerp, offset, delta * 5)

func _create_buttons():
	var tween = create_tween().set_parallel(true)

	for i in button_count:
		var button: = STRUM_BUTTON_SCENE.instantiate()
		button.note_type = i

		button.bot = bot

		if i < len(button_actions):
			button.action = button_actions[i]

		button.position.x = i * seperation

		button.held_hit.connect(_on_held_hit.bind(button))
		button.note_hit.connect(_on_note_hit.bind(button))
		button.note_missed.connect(_on_note_missed.bind(button))
		button.note_held.connect(_on_note_held.bind(button))

		button.pressed.connect(_on_button_pressed.bind(button))
		button.released.connect(_on_button_released.bind(button))

		add_child(button)
		buttons.append(button)


		var ease_tween = Tween.EASE_OUT
		var trans_tween = Tween.TRANS_CIRC
		var delay_tween = 0.5 + (0.2 * i)

		button.position.y -= 10
		button.modulate.a = 0

		tween.tween_property(button, "position:y", button.position.y + 10, 1).set_ease(ease_tween).set_trans(trans_tween).set_delay(delay_tween)
		tween.tween_property(button, "modulate:a", 1, 1).set_ease(ease_tween).set_trans(trans_tween).set_delay(delay_tween)

func _on_held_hit(note, button):
	held_hit.emit(note, button)

func _on_note_hit(note, button):
	note_hit.emit(note, button)

func _on_note_held(note, button):
	note_held.emit(note, button)

func _on_note_missed(note, button):
	note_missed.emit(note, button)

func _on_button_pressed(whiffed, button):
	if whiffed:
		if not ghost_tapping:
			_on_note_missed(null, button)

		button_whiffed.emit(button)

	held_buttons.append(button)
	if held_buttons.size() > 2:
		pass


func _on_button_released(button):
	button_released.emit(button)

	held_buttons.erase(button)



func _set_bot(value):
	bot = value

	for button in buttons:
		button.bot = bot

func _set_button_actions(value):
	button_actions = value

	var i = 0
	for button in buttons:
		if i < len(button_actions):
			button.action = button_actions[i]
		else:
			button.action = ""

		i += 1

func _set_offset(value):
	offset = value

	for button in buttons:
		button.offset = offset

func _set_offset_lerp(value):
	offset_lerp = value

	for button in buttons:
		button.offset_lerp = offset_lerp

func _set_scroll_multi(value):
	scroll_multi = value

	for button in buttons:
		button.scroll_multi = scroll_multi
