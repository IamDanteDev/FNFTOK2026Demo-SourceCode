extends Node2D



@export var note_type: int = 0:
	set = _set_note_type


@export var frame: int = 0:
	set = _set_frame


@onready var _sprite = $Sprite
@onready var _animation_player = $AnimationPlayer


func _ready():
	_update_sprite()

	var animation = "0"

	var extra_speed = randi_range(-2, 2) * 0.1

	_animation_player.play(animation, -1, 1 + extra_speed)
	_animation_player.animation_finished.connect(_animation_finished)

func _animation_finished(_animation):

	queue_free()



func _update_sprite():



	if _sprite == null:
		return


	var frame_offset = _sprite.hframes * note_type


	var max_frames = _sprite.hframes * _sprite.vframes
	if frame + frame_offset >= max_frames:
		return


	_sprite.frame = frame + frame_offset


func _set_note_type(value):
	note_type = value
	_update_sprite()

func _set_frame(value):
	frame = value
	_update_sprite()
