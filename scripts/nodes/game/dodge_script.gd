extends Node2D

var dodge_sfx: AudioStreamPlayer
@export var stage: Node2D
@export var dodge_cooldown_time: float
@export var dodge_beat_starts: Array
var dodge_window = false
var dodge_cooldown = false
var dodged = false


func _ready():
	Conductor.beat_changed.connect(_on_beat)
	dodge_sfx = AudioStreamPlayer.new()
	add_child(dodge_sfx)

func _unhandled_input(event):
	if event.is_action_pressed("dodge") and Conductor.cur_song != "Eddy River":
		if !dodge_cooldown:
			dodge_cooldown = true
			stage.player_character.animation_player.play("dodge")
			if dodge_window:
				dodged = true
				await get_tree().create_timer(0.75).timeout
				_on_dodged()
			else:
				_failed_dodge()
			await get_tree().create_timer(dodge_cooldown_time).timeout
			dodge_cooldown = false

func _on_beat(cur_beat):
	for n in dodge_beat_starts.size():
		if dodge_beat_starts[n] == int(cur_beat):
			dodge_warning(0)
		elif dodge_beat_starts[n] + 1 == int(cur_beat):
			dodge_warning(1)
		elif dodge_beat_starts[n] + 2 == int(cur_beat):
			dodge_warning(2)
		elif dodge_beat_starts[n] + 3 == int(cur_beat):
			dodge_window = true
			dodge_sfx.stream = load("res://assets/sounds/dodge_sfx/dodge_failure.ogg")
			dodge_sfx.play()
			stage.enemy_character.force_animation = true
			stage.enemy_character.do_bop = false

		elif dodge_beat_starts[n] + 4 == int(cur_beat):
			dodge_window = false
			if dodged != true:
				_failed_dodge()
		elif dodge_beat_starts[n] + 5 == int(cur_beat):
			dodged = false

func dodge_warning(num):
	print("warning emitted")
	if dodge_sfx.is_playing():
		dodge_sfx.stop()

	dodge_sfx.stream = load("res://assets/sounds/dodge_sfx/anticipation_" + str(num) + ".ogg")
	dodge_sfx.play()

func _on_dodged():
	stage.player_character.force_animation = true
	stage.player_character.do_bop = false
	stage.player_character.animation_player.play("pose")
	dodge_sfx.stream = load("res://assets/sounds/dodge_sfx/dodge_success.ogg")
	dodge_sfx.play()

	stage.playstate.combo += 1
	stage.playstate.score += 10
	stage.playstate._update_hud()

func _failed_dodge():
	stage.player_character.miss_stream_player.volume_db = stage.player_character.miss_sound_volume
	stage.player_character.miss_stream_player.stream = stage.player_character.miss_sounds.pick_random()
	stage.player_character.miss_stream_player.play()
	stage.playstate.combo = 0
	stage.playstate.score -= 10
	stage.playstate.misses += 1

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
	stage.player_character.force_animation = true
	stage.player_character.do_bop = false
	stage.player_character.animation_player.play("hurt")
	stage.playstate._death_check()
