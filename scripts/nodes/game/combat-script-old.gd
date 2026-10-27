extends Node

@export var stage: Node2D
@export var dodge_cooldown_time: float
@export var attack_windows: Array

var cur_dodge_start

@onready var success_player = AudioStreamPlayer.new()

var a: AnimationPlayer

var dodge_dur = 0
var dodge_cooldown = 0
var can_dodge = true
var can_note_dodge = false

var dodge_window = false
var dodged = false

var song_pos: float = 0.0
var last_song_pos: float = 0.0

var window = 0.1


func _ready():
	Conductor.song_position_updated.connect(_on_song_position_update)
	Event.hud.health_bar.sprite.frame = 2
	Event.hud.player_strum.three_button_dodge.connect(_dodge)

	add_child(success_player)
	success_player.stream = load("res://assets/sounds/dodge_sfx/dodge_success_1.ogg")

func _unhandled_input(event):
	if Input.is_action_just_pressed("dodge"):
		_dodge(false)

func _on_song_position_update(pos, last_pos):

	if _position_check(0):
		stage.chart_generator.section_changed.connect(_on_section_changed)
		_parse_event_file()

	song_pos = pos / 1000
	last_song_pos = last_pos / 1000

	if dodge_dur - 1 == 0:
		stage.player_character.play_animation("idle")
		stage.player_character.do_notes = true


		dodge_dur -= 1
	elif dodge_dur > 0:
		dodge_dur -= 1








	if _position_check(cur_dodge_start, true, -12):
		play_sfx("res://assets/sounds/dodge_sfx/anticipation_0.ogg")
		Event.hud.cue_player.play("0")
	if _position_check(cur_dodge_start, true, -8):
		play_sfx("res://assets/sounds/dodge_sfx/anticipation_1.ogg")
		Event.hud.cue_player.play("1")
	if _position_check(cur_dodge_start, true, -4):
		play_sfx("res://assets/sounds/dodge_sfx/anticipation_2.ogg")
		Event.hud.cue_player.play("2")
		stage.find_child("sprites").on_attack(window)

	if _position_check(cur_dodge_start, false, 0, - window):
		dodge_window = true
		can_note_dodge = true
		dodged = false
	if _position_check(cur_dodge_start, false, 0, window):
		dodge_window = false
		can_note_dodge = false
		if !dodged:
			failed_dodge()
		_get_next_dodge()
		Event.hud.cue_player.play("out")

func _position_check(value: float, audio: bool = false, step_offset: float = 0, pos_offset: float = 0):
	step_offset = (Conductor.step_crochet / 1000) * step_offset
	var offset = 0
	if audio:
		offset = (Settings.offset / 1000)
	if song_pos >= value + step_offset + pos_offset - offset and last_song_pos <= value + step_offset + pos_offset - offset:
		return true
	else: return false

func _parse_event_file():
	var event_file = stage.playstate.chart.song_path + "events.json"
	event_file = Weeks.load_json_file(event_file)
	event_file = event_file.get("song").get("events")

	for i in event_file:

		if i[1][0][0] == "Attack-Window":
			attack_windows.append(i[0] / 1000)



	cur_dodge_start = attack_windows[0]

func _get_next_dodge():
	if cur_dodge_start:
		attack_windows.erase(cur_dodge_start)
	if attack_windows.size() > 0:
		cur_dodge_start = attack_windows[0]


func successful_dodge():
	dodged = true
	stage.player_character.play_animation("dodge")
	stage.enemy_character.play_animation("attack")
	stage.player_character.do_notes = false
	if success_player.is_playing():
		success_player.stop()
	success_player.play()

func failed_dodge():
	can_dodge = false
	stage.find_child("sprites").on_attack_miss()
	stage.enemy_character.play_animation("attack")




	play_sfx("res://assets/sounds/dodge_sfx/dodge_failure.ogg")

	if stage.playstate.health > 0.8:
		stage.playstate.health = 0.82
	elif stage.playstate.health > 0.6:
		stage.playstate.health = 0.61
	elif stage.playstate.health > 0.4:
		stage.playstate.health = 0.4
	elif stage.playstate.health > 0.2:
		stage.playstate.health = 0.2

	stage.playstate._update_hud()

	Conductor.mute_vocals = true

	stage.player_character.play_animation("hurt")
	stage.player_character.do_notes = false
	stage.playstate._death_check()
	dodge_cooldown = 40

func _dodge(note_flash = true):

	if note_flash == true:
		if can_note_dodge == false:
			return

	if can_dodge:
		stage.player_character.play_animation("dodge")
		stage.player_character.animation_player.animation_finished.connect(on_animation_finish)
		stage.player_character.do_notes = false
		can_dodge = true
		dodge_dur = 80

		if note_flash:
			var t = create_tween()
			t.tween_property(Event.hud.player_strum, "modulate:v", 1, 0.2).from(2)

	if dodge_window:
		dodge_window = false
		successful_dodge()

func on_animation_finish(anim):
	if anim == "attack":
		stage.enemy_character.do_notes = true
		stage.enemy_character.play_animation("attack_return")

	if anim == "dodge":
		stage.player_character.do_notes = true

	if anim == "hurt":
		stage.player_character.do_notes = true

func _on_section_changed(section):
	var a: Array

	can_note_dodge = true

	if section[3].size() > 0:
		for i in section[3]:
			if i[1] < 4:
				can_note_dodge = false
				break

func play_sfx(path: String, pitch = 0):
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.pitch_scale = pitch
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()
