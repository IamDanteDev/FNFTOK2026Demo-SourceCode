extends CanvasLayer

var play_state

@onready var accuracy_total_label = $AccuracyTotal
@onready var sick_total_label = $SickTotal
@onready var misses_total_label = $MissesTotal
@onready var total_label = $TotalTotal
@onready var save_total_label = $SaveTotal
@onready var victory_audio = $VictoryAudio

var victory_song = ""
var victory_bpm
var victory_pose_beat


func _ready():
	play_state.hud.visible = false
	play_state.stage.do_camera_movement = false
	play_state.stage.camera_zoom = Vector2(0.8, 0.8)
	play_state.stage.camera.position = play_state.stage.player_character.global_position - Vector2(0, 400)
	Conductor.beat_changed.connect(_on_beat)

	if ResourceLoader.exists(play_state.chart.song_path + "data.json"):
		var data = Weeks.load_json_file(play_state.chart.song_path + "data.json")

		if ResourceLoader.exists("res://assets/sounds/victory/" + data.get("victory_song")):
			victory_song = "res://assets/sounds/victory/" + data.get("victory_song")
			victory_bpm = int(data.get("victory_bpm"))
			victory_pose_beat = int(data.get("victory_pose_beat"))
			print(data.get("victory_song") + "found")
		else:
			print(data.get("victory_song") + " not found")
			load_default_victory()
	else:
		print("data file missing")
		load_default_victory()

	var song = load(victory_song)
	Conductor.play_song(song, victory_bpm)
	Conductor.cur_song = "Victory"





	var accuracy_total = round(play_state.notes_hit / play_state.notes_passed) * 100
	var sick_total = round(play_state.sicks / 6)
	var misses_total = round(play_state.misses / 2)
	var coin_total = int(accuracy_total + sick_total - misses_total)

	if coin_total < 0:
		coin_total = 0

	if is_nan(accuracy_total):
		accuracy_total = 0

	accuracy_total_label.text = str(accuracy_total)
	sick_total_label.text = str(sick_total)
	misses_total_label.text = str(misses_total)
	total_label.text = str(coin_total)

	SaveData.add_coin_total(coin_total)
	save_total_label.text = str(SaveData.load_coin_total())

func load_default_victory():
	victory_song = "res://assets/sounds/victory/missing_victory.ogg"
	victory_bpm = 144
	victory_pose_beat = 4

func _pause():
	get_tree().paused = true

func _unhandled_input(event):
	if event.is_action_pressed("confirm"):
		play_state.end_cutscene_check()
		queue_free()


func _process(_delta):
	pass

func _on_beat(beat):
	match int(beat):
		victory_pose_beat:

			play_state.stage.player_character.play_animation("pose")
			play_state.stage.player_character.do_bop = false
