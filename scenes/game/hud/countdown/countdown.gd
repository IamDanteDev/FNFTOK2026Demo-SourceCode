extends Sprite2D


var sounds = [
	preload("res://assets/sounds/intro/intro_3.ogg"), 
	preload("res://assets/sounds/intro/intro_2.ogg"), 
	preload("res://assets/sounds/intro/intro_1.ogg"), 
	preload("res://assets/sounds/intro/intro_go.ogg")
]

var stream_player: = AudioStreamPlayer.new()
var tween: Tween

@onready var beats_in_mil = (Conductor.step_crochet / 1000) * 4

var song_pos
var last_song_pos

var go_beat = -1
var do_audio = true

func _ready():
	visible = false

	stream_player.bus = "SFX"
	add_child(stream_player)

	Conductor.song_position_updated.connect(_on_song_position_update)

func _process(_delta):
	pass

func _on_song_position_update(pos, last_pos):
	song_pos = pos / Conductor.crochet
	last_song_pos = last_pos / Conductor.crochet


	if _position_check(go_beat - 3):
		countdown_visual(0)

	if _position_check(go_beat - 2):
		countdown_visual(1)

	if _position_check(go_beat - 1):
		countdown_visual(2)

	if _position_check(go_beat):
		countdown_visual(3)

	if do_audio == false: return


	if _position_check(go_beat - 3, 0, true):
		countdown_audio(0)

	if _position_check(go_beat - 2, 0, true):
		countdown_audio(1)

	if _position_check(go_beat - 1, 0, true):
		countdown_audio(2)

	if _position_check(go_beat, 0, true):
		countdown_audio(3)

func countdown_visual(val):
	visible = true
	modulate.a = 1
	scale = Vector2.ONE * 0.4
	frame = val

	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 0, Conductor.crochet / 1000).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)

func countdown_audio(val):
	stream_player.stream = sounds[val]
	stream_player.play()

func _position_check(value: float, offset: float = 0, audio: bool = false):
	if audio:
		offset -= (Settings.offset / 1000)
	if song_pos >= value + offset and last_song_pos <= value + offset:
		return true
	else: return false
