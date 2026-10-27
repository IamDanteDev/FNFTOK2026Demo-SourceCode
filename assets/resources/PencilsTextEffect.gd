@tool
extends RichTextEffect

class_name PencilsEffect

var bbcode: = "pencils"

func _process_custom_fx(char_fx):
	var red = Color.html("c83a26")
	var blue = Color.html("196abc")
	var green = Color.html("427733")
	var purple = Color.html("6e4b8f")
	var pink = Color.html("c464bd")
	var orange = Color.html("d4743a")
	var brown = Color.html("d4743a")
	var cyan = Color.html("61a3a2")
	var lime = Color.html("7a963f")
	var black = Color.html("333333")

	var colors = [red, blue, green, purple, pink, orange, brown, cyan, lime, black]

	char_fx.set_color(colors[char_fx.range.x % len(colors)])

	return true
