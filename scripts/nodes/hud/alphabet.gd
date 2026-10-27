@tool
@icon("res://assets/editor/alphabet_icon.png")
class_name Alphabet
extends Control


enum X_Align{
	LEFT, 
	CENTER, 
	RIGHT
}


@export_multiline var text: = "": set = set_text

@export var align: X_Align


var texture: Texture = preload("res://scripts/nodes/hud/alphabet_sheet.png")

var texture_size: Vector2 = Vector2(88, 88)

var font_string = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?&()*+-<>\""

var frames: int = 2

var speed: float = 0.1

var spacing: float = -40

var y_spacing: float = -25


var frame: int

var frame_timer: float


func _process(delta):
	frame_timer += delta

	if frame_timer >= speed:
		frame_timer = 0
		frame += 1

		if frame >= frames:
			frame = 0

		if not Engine.is_editor_hint():
			queue_redraw()

func _draw():
	var _fake_text = text
	var _line_breaks: Array = []

	custom_minimum_size = Vector2(0, 0)

	while _fake_text.find("\n") != -1:
		var _last_pos = 0
		if len(_line_breaks) > 0:
			_last_pos = _line_breaks.front()

		var _pos = _fake_text.find("\n", _last_pos + 1)

		var _split_text = _fake_text.split("\n", true, 1)

		var _new_text = ""
		for _split in _split_text:
			_new_text += _split

		_fake_text = _new_text
		_line_breaks.append(_pos)

	for _char in len(_fake_text):
		var _char_pos = _char

		var _line_break = 0
		var _line_break_pos = 0
		var _next_line_break_pos = 0

		for _compare_line_index in len(_line_breaks):
			var _compare_line_break = _line_breaks[_compare_line_index]

			if _char > _compare_line_break - 1:
				_line_break += 1
				_char_pos = _char - _compare_line_break

				_line_break_pos = _compare_line_break

		if len(_line_breaks) > _line_break:
			_next_line_break_pos = _line_breaks[_line_break]
		else:
			_next_line_break_pos = len(_fake_text)

		var _letter = _fake_text[_char].to_upper()
		var _letter_pos = font_string.find(_letter)

		var _line_text = _fake_text.substr(_line_break_pos, _next_line_break_pos - _line_break_pos)

		if _letter_pos == -1:
			continue

		var _x_pos = _char_pos * (texture_size.x + spacing)
		var _y_pos = _line_break * (texture_size.y + y_spacing)

		match align:
			X_Align.CENTER:
				_x_pos += (size.x / 2) - (((len(_line_text) + 0.9) / 2) * (texture_size.x + spacing))
			X_Align.RIGHT:
				_x_pos += size.x - ((len(_line_text) + 0.9) * (texture_size.x + spacing))

		var _rect = Rect2(Vector2(_x_pos, _y_pos), texture_size)
		var _source_rect = Rect2(Vector2(frame * texture_size.x, _letter_pos * texture_size.y), texture_size)

		draw_texture_rect_region(texture, _rect, _source_rect, Color.WHITE)

		var _possible_size = Vector2((len(_line_text) + 0.9) * (texture_size.x + spacing), texture_size.y)
		if _possible_size.x > custom_minimum_size.x:
			custom_minimum_size = _possible_size


func set_text(value: String):
	text = value
	queue_redraw()
