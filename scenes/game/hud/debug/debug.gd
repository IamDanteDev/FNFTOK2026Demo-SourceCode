extends CanvasLayer

@onready var property_container = %VBoxContainer

var frames_per_second: String

func _ready():
	visible = false


func _input(event):
	if Settings.load_visuals().debug_mode:
		visible = true
	else:
		visible = false













func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
