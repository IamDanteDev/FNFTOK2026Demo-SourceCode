extends CanvasLayer

var play_state

@onready var accuracy_bonus = $Bonuses / AccuracyBonus
@onready var sick_bonus = $Bonuses / SickBonus
@onready var no_damage_bonus = $"Bonuses/No-DamageBonus"
@onready var miss_penalty = $Bonuses / MissPenalty
@onready var total = $Bonuses / Total
@onready var coin_counter = $CoinCounter

@onready var bg_rect = $BackgroundRect
@onready var song_bonus = $SongBonus
@onready var bonuses = $Bonuses

@onready var counter_player = $CounterPlayer
@onready var hit_player = $HitPlayer

var current_label: Label
var current_total: int

var active_bonuses = []

var victory_song = ""
var victory_bpm
var victory_pose_beat

var prev_text
var cur_text

func _ready():
	play_state.stage.player_character.do_bop = false
	play_state.stage.player_character.do_miss = false

	play_state.hud.visible = false
	play_state.stage.do_camera_movement = false
	play_state.stage.offset_amount = 0
	var cam_t = create_tween().set_parallel()
	cam_t.tween_property(Event.camera_target, "position", play_state.stage.player_position - Vector2(0, 400), 2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	cam_t.tween_property(Event.camera_target, "zoom", Vector2(0.8, 0.8), 2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

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


	hit_player.stream = load("res://scenes/game/results_screen/initial.ogg")
	hit_player.play()

	var accuracy_total = round(play_state.notes_hit / play_state.notes_passed) * 100
	var sick_total = round(play_state.sicks / 6)
	var damage_total = 0
	var misses_total = round(play_state.misses / 2)

	var coin_total = int(accuracy_total + sick_total + damage_total - misses_total)

	if coin_total < 0:
		coin_total = 0

	if is_nan(accuracy_total):
		accuracy_total = 0

	if accuracy_total == 0:
		accuracy_bonus.visible = false
	else: active_bonuses.append([accuracy_bonus, accuracy_total])
	if sick_total == 0:
		sick_bonus.visible = false
	else: active_bonuses.append([sick_bonus, sick_total])
	if damage_total == 0:
		no_damage_bonus.visible = false
	else: active_bonuses.append([no_damage_bonus, damage_total])
	if misses_total == 0:
		miss_penalty.visible = false
	else: active_bonuses.append([miss_penalty, - misses_total])

	active_bonuses.append([total, coin_total])

	for i in active_bonuses:
		i[0].self_modulate.a = 0
		i[0].get_child(0).self_modulate.a = 0
		i[0].get_child(1).self_modulate.a = 0
		i[0].get_child(2).self_modulate.a = 0

	bg_rect.modulate.a = 0
	bonuses.modulate.a = 0
	coin_counter.modulate.a = 0

	var sbt = create_tween().set_parallel()
	sbt.tween_property(song_bonus, "modulate:v", 1, 0.25).from(10)
	sbt.tween_property(song_bonus, "scale", Vector2(1, 1), 0.25).from(Vector2(1.2, 1.2)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	spawn_coins(coin_total)

	await get_tree().create_timer(0.25).timeout

	coin_counter.get_child(2).text = str(int(SaveData.load_coin_total()))

	var bgt = create_tween().set_parallel()
	bgt.tween_property(bg_rect, "modulate:a", 0.6, 0.25).from(0)
	bgt.tween_property(bonuses, "modulate:a", 1, 0.25).from(0)
	bgt.tween_property(coin_counter, "modulate:a", 1, 0.25).from(0)

	await bgt.finished

	await get_tree().create_timer(0.25).timeout

	var old_total = SaveData.load_coin_total()
	SaveData.add_coin_total(coin_total)
	var ct = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	ct.tween_method(update_coin_counter, old_total, SaveData.load_coin_total(), 1)

	for i in active_bonuses:
		if i[0].name == "MissPenalty":
			counter_player.stream = load("res://scenes/game/results_screen/miss-counter.ogg")
		elif i[0].name == "Total":
			counter_player.stream = load("res://scenes/game/results_screen/counter-total.ogg")
		else:
			counter_player.stream = load("res://scenes/game/results_screen/counter.ogg")

		current_label = i[0].get_child(2)
		prev_text = "0"
		current_label.text = str(0)
		current_label

		i[0].self_modulate.a = 1
		for c in i[0].get_children():
			c.self_modulate.a = 1

		var t = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		t.tween_method(update_total, 0, i[1], 0.8)

		await t.finished
		await get_tree().create_timer(0.25).timeout

	await get_tree().create_timer(1).timeout


func spawn_coins(coin_total: float):







	for i in 15:
		var coin = preload("res://scenes/game/results_screen/coin/coin.tscn")
		coin = coin.instantiate()
		coin.results_scene = self
		coin.position = Vector2(0, -1000)

		play_state.stage.player_character.add_child(coin)

		await get_tree().create_timer(0.05).timeout

func play_coin_sfx():
	$CoinCollect.play(0)

func update_total(new_value: int):
	current_label.text = str(new_value)

func update_coin_counter(new_value: int):
	coin_counter.get_child(2).text = str(new_value)

func _process(delta):
	if current_label:
		cur_text = current_label.text

		if cur_text != prev_text:
			counter_player.play()
			prev_text = cur_text

func load_default_victory():
	victory_song = "res://assets/sounds/victory/missing_victory.ogg"
	victory_bpm = 144
	victory_pose_beat = 4

func _pause():
	get_tree().paused = true

func _unhandled_input(event):
	if event.is_action_pressed("confirm"):
		exit()


func exit():
	if play_state.has_end_cutscene:
		var transition = Main.TRANSITION_SCENE.instantiate()
		add_child(transition)
		await transition.transitioned
		queue_free()
	play_state.end_cutscene_check()

func _on_beat(beat):
	if int(beat) == victory_pose_beat:
		play_state.stage.player_character.play_animation("pose")
		play_state.stage.enemy_character.do_bop = false
		play_state.stage.gf_character.do_bop = false
		hit_player.stream = load("res://scenes/game/results_screen/victory_hit.ogg")
		hit_player.play()
