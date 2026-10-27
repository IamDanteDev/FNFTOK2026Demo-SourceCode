class_name SubMenu
extends Control


func _ready():
	var bg_rect: = ColorRect.new()
	bg_rect.color = Color(Color.BLACK, 0.3)
	add_child(bg_rect)

	move_child(bg_rect, 0)

	bg_rect.set_anchors_preset(PRESET_FULL_RECT, true)

func _process(_delta):
	if get_viewport().gui_get_focus_owner() == null:
		return

	var path = str(get_path_to(get_viewport().gui_get_focus_owner()))
	if path.begins_with("."):
		get_viewport().gui_get_focus_owner().release_focus()

func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		queue_free()
