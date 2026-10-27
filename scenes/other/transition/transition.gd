extends CanvasLayer


signal transitioned

var prefix: String

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$AnimationPlayer.play(prefix + "_in")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == prefix + "_in":
		transitioned.emit()
		$AnimationPlayer.play(prefix + "_out")
	if anim_name == prefix + "_out":
		queue_free()
