extends Node








signal step_changed(step)

signal beat_changed(beat)

signal song_position_updated(song_pos, last_song_pos)



var music_stream_player: AudioStreamPlayer

var player_vocal_stream_player: AudioStreamPlayer
var enemy_vocal_stream_player: AudioStreamPlayer




var song_position: float
var last_song_position

var bpm: float



var crochet: float

var step_crochet: float


var cur_step: float

var cur_beat: float




var start_delay: float = 0

var mute_vocals: bool:
	set = _set_mute_vocals

var rate: float:
	set = _set_rate



var _last_step: float
var _last_beat: float

var cur_song: String

func _ready():
	_create_music_nodes()

func _process(delta):
	if start_delay > 0:
		start_delay -= delta

		if start_delay <= 0:
			play_music()

	_update_song_position()
	_update_step()






func play_song(
	music: AudioStream, new_bpm: float = 102.0, player_vocals: AudioStream = null, 
	enemy_vocals: AudioStream = null, new_start_delay: float = 0.0, 
	new_rate: float = 1.0):

	music_stream_player.stream = music
	player_vocal_stream_player.stream = player_vocals
	enemy_vocal_stream_player.stream = enemy_vocals

	rate = new_rate

	last_song_position = null

	change_bpm(new_bpm)

	start_delay = ((step_crochet * new_start_delay) * new_start_delay) / 1000

	if start_delay <= 0:
		play_music()



func play_music(from: float = 0) -> void :

	music_stream_player.play(from)
	player_vocal_stream_player.play(from)
	enemy_vocal_stream_player.play(from)


func stop_music() -> void :
	start_delay = 0

	music_stream_player.stop()
	player_vocal_stream_player.stop()
	enemy_vocal_stream_player.stop()

func pause_music() -> void :
	start_delay = 0

	music_stream_player.stream_paused = true
	player_vocal_stream_player.stream_paused = true
	enemy_vocal_stream_player.stream_paused = true


func change_bpm(_new_bpm) -> void :
	bpm = _new_bpm

	if bpm == 0:
		return

	var _bpm_rate = bpm * rate

	crochet = (60 / _bpm_rate) * 1000.0
	step_crochet = crochet / 4


func _update_song_position() -> void :

	song_position = music_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency()

	song_position -= start_delay
	song_position -= (Settings.offset / 1000)

	song_position *= 1000.0

	if last_song_position != null:
		emit_signal("song_position_updated", song_position, last_song_position)

	last_song_position = song_position

func _update_step() -> void :
	if step_crochet == 0:
		return

	cur_step = floor(song_position / step_crochet)

	if cur_step > _last_step:
		emit_signal("step_changed", cur_step)

		if fmod(cur_step, 4) == 0:
			cur_beat = cur_step / 4

			if cur_beat > _last_beat:
				emit_signal("beat_changed", cur_beat)

			_last_beat = cur_beat

	_last_step = cur_step


func _create_music_nodes() -> void :
	music_stream_player = AudioStreamPlayer.new()
	music_stream_player.bus = "Music"

	player_vocal_stream_player = AudioStreamPlayer.new()
	player_vocal_stream_player.bus = "Vocals"

	enemy_vocal_stream_player = AudioStreamPlayer.new()
	enemy_vocal_stream_player.bus = "Vocals"

	add_child(music_stream_player)
	add_child(player_vocal_stream_player)
	add_child(enemy_vocal_stream_player)

func transition_track(new_track, duration) -> void :
	var new_player: = music_stream_player.duplicate()
	add_child(new_player)
	new_player.volume_linear = 0
	new_player.play(music_stream_player.get_playback_position())

	var t1 = create_tween().set_parallel()
	t1.tween_property(new_player, "volume_linear", 1.0, 0.05).from(0.0)
	t1.tween_property(music_stream_player, "volume_linear", 0.0, 0.05).from(1.0)
	await t1.finished

	music_stream_player.stream = new_track
	music_stream_player.play(new_player.get_playback_position())

	var t2 = create_tween().set_parallel()
	t2.tween_property(new_player, "volume_linear", 0.0, duration).from(1.0)
	t2.tween_property(music_stream_player, "volume_linear", 1.0, duration).from(0.0)

func _set_mute_vocals(value) -> void :
	mute_vocals = value
	player_vocal_stream_player.volume_db = -80 * int(mute_vocals)

func _set_rate(value) -> void :
	rate = value

	music_stream_player.pitch_scale = rate
	player_vocal_stream_player.pitch_scale = rate
