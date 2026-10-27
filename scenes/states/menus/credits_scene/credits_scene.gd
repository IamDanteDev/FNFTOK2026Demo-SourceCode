extends Node2D

var active = true
@onready var everything: ColorRect = $CanvasLayer / ColorRect

var t = create_tween()

func _ready() -> void :

	t.tween_property(everything, "modulate:a", 1, 0.5).from(0)

func _input(event):

	if event.is_action_pressed("cancel"):
		get_parent().cam_zoom = 0.76

		t.kill()
		var t2 = create_tween()
		t2.tween_property(everything, "modulate:a", 0, 0.5)
		t2.tween_callback(queue_free)
		await get_tree().create_timer(0.025).timeout
		get_parent().active = true
