class_name Character
extends Node2D


signal sung_note(note_type, miss)

signal beat_timer_finished




var miss_sounds: = [
	preload("res://assets/sounds/miss/missnote1.ogg"), 
	preload("res://assets/sounds/miss/missnote2.ogg"), 
	preload("res://assets/sounds/miss/missnote3.ogg"), 
]

var sing_animations: = ["sing_left", "sing_down", "sing_up", "sing_right"]
var miss_suffix: = "_miss"
var held_suffix: = "_hold"

@export var icon: Texture2D = preload("res://scenes/game/character/null/icon-null.png")
@export var icon_count: int = 3

@export var healthbar_color: Color = Color("A1A1A1")

@export var flip_x: = false

@export var mood = "normal"

@export_group("Idle Animation", "beat_")
@export var beat_scaled_idle = false
@export var beat_multi_min: float = 0
@export var beat_multi_max: float = 4
@export var beat_duration: float = 1
@export var beat_frequency: int = 2



@export_group("Nodes", "path_")
@export_node_path("AnimationPlayer") var path_animation_player: = NodePath("AnimationPlayer")
@export_node_path("Node2D") var path_sprite: = NodePath("Node2D")
@export_node_path("Marker2D") var path_camera_pos: = NodePath("Camera Position")


var camera_offset: = Vector2.ZERO




var do_bop: = true
var do_notes: = true

var intro_check = false

var idle_timer: = 0.0
var beat_timer: = 0.0
var beat_check = true


var held_buttons: = []


var ignore_hold_release: = true



var do_miss: = true
var miss_sound_volume: = -5

var beat_mod_override = null

var devil_right = false

var miss_stream_player = AudioStreamPlayer.new()

@onready var animation_player: AnimationPlayer = get_node_or_null(path_animation_player)
@onready var sprite: = get_node_or_null(path_sprite)
@onready var camera_pos: = get_node_or_null(path_camera_pos)

func _ready():
	Conductor.beat_changed.connect(_on_beat)
	miss_stream_player.bus = "SFX"
	add_child(miss_stream_player)

	await get_tree().create_timer(0.025).timeout

	if animation_player.has_animation("intro"):
		do_bop = false
		play_animation_over_time("intro", Conductor.start_delay, 1.2, 1.5)
		await get_tree().create_timer(Conductor.start_delay).timeout
		var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(self, "scale", Vector2.ONE, 0.5).from(Vector2(1.03, 0.97))

func _process(delta):

	if idle_timer > 0:
		idle_timer -= delta

	if beat_timer <= 0:
		if beat_check == false:
			beat_timer_finished.emit()
			beat_check = true
	else:
		beat_timer -= delta
		beat_check = false




func register_strum(strum_line: StrumLine):
	strum_line.note_hit.connect(_on_note_hit)
	strum_line.note_missed.connect(_on_note_missed)

func disconnect_strum(strum_line: StrumLine):
	if strum_line.note_hit.is_connected(_on_note_hit):
		strum_line.note_hit.disconnect(_on_note_hit)

	if strum_line.note_missed.is_connected(_on_note_missed):
		strum_line.note_missed.disconnect(_on_note_missed)

func _play_note_animation(note_type, miss = false, held = false):
	sung_note.emit(note_type, miss)





	if flip_x:
		if note_type == 0:
			note_type = 3
		elif note_type == 3:
			note_type = 0


	var sing_anim = sing_animations[note_type]
	var suffix = ""
	if miss:
		if animation_player != null and animation_player.has_animation(sing_anim + miss_suffix):
			suffix = miss_suffix
		else:
			pass

	if held:
		if animation_player != null and animation_player.has_animation(sing_anim + held_suffix):
			suffix = held_suffix
		else:
			pass

	var full_anim = sing_anim + suffix
	if animation_player != null and animation_player.has_animation(full_anim + "_" + mood):
		animation_player.stop(true)
		animation_player.play(sing_anim + suffix + "_" + mood)
	elif animation_player != null and animation_player.has_animation(full_anim):
		animation_player.stop(true)
		animation_player.play(sing_anim + suffix)

	idle_timer = (Conductor.step_crochet * 4) / 1000

func play_animation(anim):
	animation_player.stop(true)
	animation_player.play(anim)
	idle_timer = animation_player.get_current_animation_length()

func _on_beat(beat):

	if int(beat) == - Conductor.start_delay:
		if animation_player.has_animation("intro"):
			do_bop = false
			play_animation_over_time("intro", Conductor.start_delay, 1.2, 1.5)
			await get_tree().create_timer(Conductor.start_delay).timeout
			var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			t.tween_property(self, "scale", Vector2.ONE, 0.5).from(Vector2(1.03, 0.97))


	if int(beat) == 0:
		if animation_player.has_animation("intro"):
			do_bop = true

	if do_bop == false:
		return

	var beat_mod = 2
	var dancer = (
		animation_player.has_animation("danceLeft") and 
		animation_player.has_animation("danceRight")
	)

	var devil = (
		animation_player.has_animation("devilLeft") and 
		animation_player.has_animation("devilRight")
	)

	beat_mod = beat_frequency

	if dancer:
		beat_mod = 1

	if beat_mod_override != null:
		beat_mod = beat_mod_override



	var funny = false
	if funny:
		if int(beat) % 2 == 0:
			scale = Vector2(1.2, 0.8)
		else:
			scale = Vector2(0.8, 1.2)



	if int(beat) % beat_mod == 0:

		if idle_timer <= 0 and held_buttons.is_empty():

			var anim = "idle"
			if dancer:
				if abs(int(beat)) % (beat_mod * 2) == 0:
					anim = "danceRight"
				else:
					anim = "danceLeft"



			if devil:
				if abs(int(beat)) % (2) == 0:
					devil_right = !devil_right

				if devil_right: anim = "devilRight"
				else: anim = "devilLeft"




			if beat_scaled_idle:
				play_animation_over_time(anim, Conductor.step_crochet / 1000 * 4 * beat_duration, beat_multi_min, beat_multi_max)
			elif animation_player.has_animation(anim):
				animation_player.stop(true)
				animation_player.play(anim)

func play_animation_over_beat(anim):
	play_animation_over_time(anim, Conductor.step_crochet / 1000 * 4)

func play_animation_over_time(anim, t, min = 0, max = 4):
	if animation_player.has_animation(anim):

		animation_player.current_animation = anim
		animation_player.pause()

		var time = t
		var anim_length = animation_player.current_animation_length
		var mult = (anim_length - time) / time + 1
		var skip = 0

		if animation_player.has_animation("intro"):

			if mult < min:

				beat_timer = abs(time - (anim_length / min))
				beat_check = false
				mult = min

			elif mult > max:

				skip = (anim_length / max) - time
				mult = max

		if beat_check == false:
			await beat_timer_finished

		animation_player.stop(true)
		animation_player.play(anim, -1, mult)

		if skip > 0:
			animation_player.advance(skip)

func _on_note_hit(note, button):

	if do_notes == false:
		return

	if str(note.note_value) == "Hey!":
		play_animation("pose")

	elif str(note.note_value) == "Hurt Note":
		play_animation("hurt")

	elif str(note.note_value) == "No Animation":
		pass
	else:
		_play_note_animation(note.note_type)


	if not note.note_held.is_connected(_on_note_held):
		note.note_held.connect(_on_note_held.bind(note))

	if not button.bot and not ignore_hold_release:
		if not button.released.is_connected(_on_button_released):
			button.released.connect(_on_button_released.bind(button))

		if button not in held_buttons:
			held_buttons.append(button)

func _on_note_held(note):
	if animation_player == null:
		return

	if animation_player.current_animation == "":
		return

	if do_notes == false:
		return

	if str(note.note_value) == "No Animation":
		return

	if animation_player.current_animation_position >= Conductor.step_crochet / 1000:
		_play_note_animation(note.note_type, false, true)

func _on_note_missed(note, button):
	if not do_miss:
		return

	var note_type = button.note_type
	if note != null:
		note_type = note.note_type

	_play_note_animation(note_type, true)
	do_notes = true
	miss_stream_player.volume_db = miss_sound_volume
	miss_stream_player.stream = miss_sounds.pick_random()
	miss_stream_player.play()

func _on_button_released(button):
	held_buttons.erase(button)
