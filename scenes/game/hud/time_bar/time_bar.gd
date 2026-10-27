extends Node2D

@onready var progress_bar: = $ProgressBar
@onready var time_label: = $TimeLabel

var song_started = true

func _ready():
	progress_bar.modulate.a = 0
	time_label.modulate.a = 0
	if (Settings.load_visuals().time_bar == "song_name"):
		time_label.text = Conductor.cur_song

func on_song_started():
	if (Settings.load_visuals().time_bar == "time_left" || Settings.load_visuals().time_bar == "time_elapsed" || Settings.load_visuals().time_bar == "song_name"):
		var t = create_tween().set_parallel()
		t.tween_property(time_label, "modulate:a", 1, 0.5)
		t.tween_property(progress_bar, "modulate:a", 1, 0.5)

func _process(_delta):
	if Conductor.music_stream_player.playing:
		progress_bar.value = (Conductor.song_position / 10) / Conductor.music_stream_player.stream.get_length()
		song_started = true
		if song_started:
			on_song_started()
			song_started = false

	if (Settings.load_visuals().time_bar == "time_left"):
		time_label.text = time_to_minutes_secs_mili(roundi(Conductor.music_stream_player.stream.get_length() - Conductor.music_stream_player.get_playback_position()))

	if (Settings.load_visuals().time_bar == "time_elapsed"):
		time_label.text = time_to_minutes_secs_mili(roundi(Conductor.music_stream_player.get_playback_position()))


func time_to_minutes_secs_mili(time: float):
	var mins = int(time) / 60
	time -= mins * 60
	var secs = int(time)
	return str("%0*d" % [2, mins]) + ":" + str("%0*d" % [2, secs])
