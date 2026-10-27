extends Node2D


@export var note_type: int = 0:
	set = _set_note_type


@export var frame: int = 0:
	set = _set_frame


@onready var _sprite = $Sprite
@onready var _animation_player = $AnimationPlayer

func _ready():
	_sprite.set_frame_coords(Vector2i(0, note_type))
	_animation_player.play(str(note_type))


func _set_note_type(value):
	note_type = value


func _set_frame(value):
	frame = value
