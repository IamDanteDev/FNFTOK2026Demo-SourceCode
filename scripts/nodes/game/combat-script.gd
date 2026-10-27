extends Node

@export var stage: Node2D

@onready var cue_players = [Event.hud.cue1_player, Event.hud.cue2_player, Event.hud.cue3_player]

@onready var cue1 = Event.hud.cue1
@onready var cue2 = Event.hud.cue2
@onready var cue3 = Event.hud.cue3

var combat_filepath: String

var attack_windows: Array
var active_attack_windows: Array
var attack_sounds: Array

var next_attack: float = 0.0

var attack_cues: Array
var active_attack_cues: Array
var cue_sounds: Array

var song_pos: float = 0.0
var last_song_pos: float = 0.0

var window_size = 0.15

var can_dodge: bool = true

var dodge_cooldown: int = 0
var dodge_duration: int = 0

var successful_dodges = 0
var failed_dodges = 0

var hole_punched = false

func _ready():
	Conductor.song_position_updated.connect(_on_song_position_update)
	Event.hud.player_strum.three_button_dodge.connect(_dodge)
	Conductor.step_changed.connect(_on_step)
	Event.hud.health_bar.sprite.frame = 2
	_parse_event_file()

func _unhandled_input(event):
	if !Settings.showcase:
		if Input.is_action_just_pressed("dodge"):
			_dodge(false)

func _parse_event_file():
	var combat_file = combat_filepath
	combat_file = Weeks.load_json_file(combat_file)
	combat_file = combat_file.get("song").get("events")

	for i in combat_file:

		match i[1][0][0]:
			"Attack-Window":
				attack_windows.append(i[0] / 1000)
				attack_sounds.append(i[0] / 1000)
			_:
				attack_cues.append(i)
				cue_sounds.append(i)

	Event.attack_array = attack_windows


func _on_song_position_update(pos, last_pos):
	song_pos = pos / 1000
	last_song_pos = last_pos / 1000

	attack_check()
	cue_check()
	if attack_windows.size() > 0:
		Event.next_attack = attack_windows[0]



func _position_check(value: float, offset: float = 0, audio: bool = false):
	if audio:
		offset -= (Settings.offset / 1000)
	if song_pos >= value + offset and last_song_pos <= value + offset:
		return true
	else: return false

func attack_check():

	if attack_sounds.size() > 0:
		if _position_check(attack_sounds[0], 0, true):
			play_sfx("res://assets/sounds/dodge_sfx/combat_hit.ogg")
			attack_sounds.erase(attack_sounds[0])

	if attack_windows.size() > 0:
		if _position_check(attack_windows[0], - window_size / 2):
			active_attack_windows.append(attack_windows[0])
			next_attack = attack_windows[0]
			attack_windows.erase(attack_windows[0])

	if active_attack_windows.size() > 0:

		if _position_check(active_attack_windows[0], window_size / 2):
			failed_dodge()
			active_attack_windows.erase(active_attack_windows[0])

		if Settings.showcase:
			if _position_check(active_attack_windows[0]):
				_dodge(false)

func cue_check():

	if cue_sounds.size() > 0:

		if _position_check(cue_sounds[0][0] / 1000, 0, true):
			match cue_sounds[0][1][0][0]:
				"Three-Tick-Cue":
					play_sfx("res://assets/sounds/dodge_sfx/combat_triple%s.ogg" % [int(cue_sounds[0][1][0][1]) - 1])
					cue_sounds.erase(cue_sounds[0])
				"Double-Up-Cue":
					play_sfx("res://assets/sounds/dodge_sfx/combat_copy.ogg")
					cue_sounds.erase(cue_sounds[0])
				"One-Shot-Cue":
					match cue_sounds[0][1][0][1]:
						"3":
							play_sfx("res://assets/sounds/dodge_sfx/combat_oneshotwhistle1.ogg")
							cue_sounds.erase(cue_sounds[0])
						"2":
							play_sfx("res://assets/sounds/dodge_sfx/combat_oneshotwhistle2.ogg")
							cue_sounds.erase(cue_sounds[0])
						"1":
							play_sfx("res://assets/sounds/dodge_sfx/combat_oneshot.ogg")
							cue_sounds.erase(cue_sounds[0])
	if attack_cues.size() > 0:

		if _position_check(attack_cues[0][0] / 1000):
			match attack_cues[0][1][0][0]:
				"Three-Tick-Cue":
					cue1.modulate = Color.html("eb004e")
					cue2.modulate = Color.html("b00046")
					cue3.modulate = Color.html("8a003c")
					cue_players[int(attack_cues[0][1][0][1]) - 1].play("in")
					active_attack_cues.append(cue_players[int(attack_cues[0][1][0][1]) - 1])
					attack_cues.erase(attack_cues[0])


				"Double-Up-Cue":
					cue1.modulate = Color.html("cd9800")
					cue2.modulate = Color.html("aa7000")
					cue3.modulate = Color.html("825100")
					cue_players[int(attack_cues[0][1][0][1]) - 1].play("in")
					active_attack_cues.append(cue_players[int(attack_cues[0][1][0][1]) - 1])
					attack_cues.erase(attack_cues[0])


				"One-Shot-Cue":
					cue1.modulate = Color.html("1f0099")
					cue2.modulate = Color.html("1f0099")
					cue3.modulate = Color.html("1f0099")
					if attack_cues[0][1][0][1] == "1":
						cue_players[1].play("in")
						active_attack_cues.append(cue_players[1])
						attack_cues.erase(attack_cues[0])
					else:
						attack_cues.erase(attack_cues[0])


func _dodge(note_flash = true):

	if !can_dodge:
		return

	stage.player_character.play_animation("dodge")

	if active_attack_windows.size() > 0:
		active_attack_windows.erase(active_attack_windows[0])
		var t = create_tween()
		t.tween_property(stage.player_character, "modulate:v", 1, 0.5).from(2)
		dodge_duration = 8
		play_sfx("res://assets/sounds/dodge_sfx/dodge_success_1.ogg")

		successful_dodges += 1
		combat_rating_spirte(1)

		for i in active_attack_cues.size():
			active_attack_cues[0].play("out")
			active_attack_cues.erase(active_attack_cues[0])
			await get_tree().create_timer(0.05).timeout
	else:
		dodge_cooldown = 4

	if note_flash:
		var t = create_tween()
		t.tween_property(Event.hud.player_strum, "modulate:v", 1, 0.2).from(2)


func failed_dodge():

	dodge_cooldown = 4

	stage.player_character.play_animation("hurt")
	stage.player_character.do_notes = false
	play_sfx("res://assets/sounds/dodge_sfx/dodge_failure.ogg")
	Conductor.mute_vocals = true
	Event.screen_shake(30, 0.2)

	stage.playstate.hud.health_bar.health_cap -= 0.1

	if hole_punched:
		if stage.playstate.hud.health_bar.health_cap > 0.5:
			stage.playstate.hud.health_bar.health_cap = 0.5
		if stage.playstate.hud.health_bar.health_cap > 0.25:
			stage.playstate.hud.health_bar.health_cap = 0.25
		if stage.playstate.hud.health_bar.health_cap < 0.25:
			stage.playstate.hud.health_bar.health_cap = 0.0
	else:
		if stage.playstate.hud.health_bar.health_cap > 0.8:
			stage.playstate.hud.health_bar.health_cap = 0.82
		elif stage.playstate.hud.health_bar.health_cap > 0.6:
			stage.playstate.hud.health_bar.health_cap = 0.61
		elif stage.playstate.hud.health_bar.health_cap > 0.4:
			stage.playstate.hud.health_bar.health_cap = 0.4
		elif stage.playstate.hud.health_bar.health_cap > 0.2:
			stage.playstate.hud.health_bar.health_cap = 0.2
		elif stage.playstate.hud.health_bar.health_cap < 0.2:
			stage.playstate.hud.health_bar.health_cap = 0.0
	stage.playstate._update_hud()
	stage.playstate.health = stage.playstate.hud.health_bar.health


	failed_dodges += 1
	combat_rating_spirte(0)


	stage.playstate._death_check()


	for i in active_attack_cues.size():
		active_attack_cues[0].play("out")
		active_attack_cues.erase(active_attack_cues[0])
		await get_tree().create_timer(0.05).timeout

func play_sfx(path: String, volume: float = 0):
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	add_child(player)
	player.volume_db = volume
	player.play()
	await player.finished
	player.queue_free()

func handle_cooldown():
	if dodge_cooldown > 0:
		dodge_cooldown -= 1
		if can_dodge == true:
			stage.player_character.sprite.modulate.v = 0.7
			can_dodge = false
	elif dodge_cooldown <= 0:
		if can_dodge == false:
			stage.player_character.sprite.modulate.v = 1
			stage.player_character.do_notes = true
			can_dodge = true
			stage.player_character.play_animation("idle")

func _on_step(_step):
	handle_cooldown()

	if dodge_duration > 0:
		if dodge_duration - 1 == 0:
			if stage.player_character.animation_player.current_animation == "dodge":
				stage.player_character.play_animation("idle")
		dodge_duration -= 1

func combat_rating_spirte(type = 1):
	var rating: AnimatedSprite2D = Event.hud.combat_rating
	rating.animation = str(type)

	var t = create_tween()
	t.tween_property(rating, "scale", Vector2.ONE * 0.2, 0.2).from(Vector2.ONE * 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	rating.visible = true
	rating.stop()
	rating.play()
