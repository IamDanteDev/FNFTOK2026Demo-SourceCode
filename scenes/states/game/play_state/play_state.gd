class_name PlayState
extends Node2D


const HUD_SCENE = preload("res://scenes/game/hud/hud.tscn")

const PAUSE_MENU = preload("res://scenes/game/pause_menu/pause_menu.tscn")
const RESULTS_SCREEN = preload("res://scenes/game/results_screen/results_screen.tscn")

const MAIN_MENU = preload("res://scenes/states/menus/main_menu/main_menu_new.tscn")

const COVER_SPLASH_SCENE = preload("res://scenes/game/cover_splash/cover_splash.tscn")
const SPLASH_SCENE = preload("res://scenes/game/note_splash/note_splash.tscn")
const RATING_SCENE = preload("res://scenes/game/rating/rating.tscn")
const BF_DEAD = preload("uid://dt6nywb1os5lo")


var chart_path: String

var chart: ChartData
var chart_generator: ChartGenerator

var song_inst: AudioStream
var player_vocals: AudioStream
var enemy_vocals: AudioStream



var health: float = 0.4

var notes_passed: int = 0
var notes_hit: float = 0

var misses: int

var combo: int

var score: int

var sicks: int

var start_automatically: bool = false
var in_cutscene: bool = false
var has_end_cutscene: bool = false
var ending = false
var starting = true
var restarted: bool


var hud
var stage: Stage

var rating_scene

var swap_sides: bool = false

var cutscene_file = null

var is_dead = false
var death_active = false
var death_cam
var death_music

var dead_bf
var start_delay = 5

var can_die = true


func _ready():
	name = "PlayState"

	load_chart()
	load_song()
	hud = _create_hud()
	stage = _create_stage()

	var player_strum = hud.player_strum
	var enemy_strum = hud.enemy_strum

	if swap_sides:
		player_strum.bot = true
		enemy_strum.bot = true

	generate_chart()

	register_strum(player_strum)
	register_strum(enemy_strum)

	stage.setup_from_play_state(self)

	hud.setup_from_play_state(self)

	update_hud_settings()

	_update_hud()

	Conductor.cur_song = chart.song_name
	Main.cur_chart = chart





	if Main.game_mode == "story":

		if ResourceLoader.exists(chart.song_path + "data.json"):
			var data: Dictionary = Weeks.load_json_file(chart.song_path + "data.json")
			var cutscene_path = "res://cutscenes/cutscene_files/" + data.get("cutscene", "null") + ".json"
			print(cutscene_path)
			if ResourceLoader.exists(cutscene_path):
				start_automatically = false
				cutscene_file = Weeks.load_json_file(cutscene_path)

	if ResourceLoader.exists(chart.song_path + "combat-" + Main.difficulty.to_lower() + ".json"):


		stage.setup_combat_node(chart.song_path + "combat-" + Main.difficulty.to_lower() + ".json")

	if Settings.load_camera().camera_style == "fancy" and ResourceLoader.exists(chart.song_path + "camera" + ".json"):
		stage.special_cam = true
		var cam_dict = Weeks.load_json_file(chart.song_path + "camera" + ".json")
		Event.camera_dict = cam_dict
		Event.camera_events = cam_dict.get("cam_events")
		Event._on_song_start(-1)

	if restarted != true:
		if cutscene_file == null:
			start_song()
		else:
			in_cutscene = true
			start_dialog()
	else:
		start_song()

	if ResourceLoader.exists(chart.song_path + "data.json"):
		var data: Dictionary = Weeks.load_json_file(chart.song_path + "data.json")
		start_delay = data.get("start_delay", 5)
		hud.countdown.go_beat = data.get("countdown_beat", -1)
		hud.countdown.do_audio = data.get("countdown_audio", true)


func _process(_delta):

	pass


func _unhandled_input(event):
	if Conductor.song_position > 0:
		if event.is_action_pressed("reset"):
			health = 0
			_death_check()

	if event.is_action_pressed("pause"):
		if not event is InputEventKey or not event.alt_pressed:
			if !ending:
				if !starting:
					if !is_dead:
						pause()

	if event.is_action_pressed("confirm"):
		if death_active:
			if is_dead:
				if death_cam:
					var d = 4
					var t = create_tween().set_parallel()
					t.tween_property(death_cam, "zoom", Vector2(0.59, 0.59), d).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
					t.tween_property(dead_bf, "modulate:v", 0, d)
				if death_music:
					death_music.stream = load("res://assets/music/fnftok-gameOverEnd.ogg")
					death_music.play()
					death_active = false
					await death_music.finished

			var state = PlayState.new()
			state.chart_path = chart.file_path
			state.restarted = true
			Main.change_scene_transition(state, "fade")





func update_hud_settings():
	hud.update_hud_visibility(Settings.load_visuals().hide_hud)
	hud.update_downscroll(Settings.load_gameplay().downscroll)
	hud.update_middlescroll(hud.main_strum, Settings.load_gameplay().midscroll)
	hud.update_opponent_notes(hud.main_strum, Settings.load_gameplay().opponent_notes)


func register_strum(strum: StrumLine):
	strum.note_hit.connect(_note_hit)
	strum.held_hit.connect(_held_hit)
	strum.note_missed.connect(_note_missed)


func start_song():
	Conductor.play_song(song_inst, chart.bpm, player_vocals, enemy_vocals, start_delay, 1)
	Conductor.cur_song = chart.song_name
	Conductor.music_stream_player.finished.connect(_on_song_finished)

	chart_generator.register_strum(hud.player_strum, true)
	chart_generator.register_strum(hud.enemy_strum, false)
	await get_tree().create_timer(0.1).timeout
	starting = false

func die():

	if can_die == false:
		return

	if is_dead:
		return

	is_dead = true
	death_active = true

	var death_node = Node2D.new()
	add_child(death_node)

	var dead_bf = BF_DEAD.instantiate()
	dead_bf.global_position = stage.player_character.global_position
	death_node.add_child(dead_bf)

	var death_type = "standard"
	if ResourceLoader.exists(chart.song_path + "data.json"):
		var data: Dictionary = Weeks.load_json_file(chart.song_path + "data.json")
		death_type = data.get("BFDeath", "standard")

	dead_bf.play_animation("death-" + death_type)

	await get_tree().create_timer(0.0909).timeout

	stage.player_character.visible = false
	var cam = Camera2D.new()
	death_node.add_child(cam)
	death_cam = cam
	cam.make_current()

	var deathcam_offset: Vector2
	match death_type:
		"standard": deathcam_offset = Vector2(0, 200)
		"boss": deathcam_offset = Vector2(0, 300)

	var d1 = 0.5
	var t1 = create_tween().set_parallel()
	t1.tween_property(hud, "modulate:a", 0, 0.5)
	t1.tween_property(cam, "global_position", stage.player_character.global_position - deathcam_offset, d1).from(stage.camera.global_position).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t1.tween_property(cam, "zoom", Vector2(0.7, 0.7), d1).from(stage.camera.zoom).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	stage.queue_free()
	Conductor.stop_music()

	var sfx = AudioStreamPlayer.new()
	death_node.add_child(sfx)
	sfx.volume_linear = 0.5
	sfx.stream = load("res://assets/sounds/tok_loss_%s.ogg" % [death_type])
	sfx.play()

	var music = AudioStreamPlayer.new()
	death_node.add_child(music)
	death_music = music
	music.bus = "Music"
	music.volume_linear = 0.8

	match death_type:
		"boss": await get_tree().create_timer(5.1818).timeout
		"standard": await get_tree().create_timer(2).timeout

	if death_active == false:
		return

	music.stream = load("res://assets/music/fnftok-gameOver.ogg")
	music.play()

func start_dialog():
	pass







func pause():
	var pause_scene = PAUSE_MENU.instantiate()
	pause_scene.play_state = self
	add_child(pause_scene)


func _note_hit(note, button):

	match note.note_value:
		"Hurt Note":
			return ;
		_:
			pass;

	if note.been_hit:
		return

	if Conductor.enemy_vocal_stream_player.stream == null:
		Conductor.mute_vocals = false
	else:
		if not button.bot:
			Conductor.mute_vocals = false

	if not button.bot:

		var rating = note.get_rating()
		var max_rating = note.hit_timings.keys().back()

		var display_combo = null
		var rating_offset = 0



		combo += 1
		health = clampf(health + note.health_on_hit, 0, hud.health_bar.health_cap)

		score += note.hit_timings[rating][1]

		notes_passed += 1
		notes_hit += note.hit_timings[rating][2]


		if display_combo == null:
			display_combo = combo


		if rating == max_rating:
			var splash_scene = SPLASH_SCENE.instantiate()
			splash_scene.note_type = note.note_type

			button.add_child(splash_scene)

			splash_scene.global_scale = Vector2.ONE
			splash_scene.z_index = 1
			sicks += 1

		if rating_scene != null:
			rating_scene.queue_free()
		rating_scene = RATING_SCENE.instantiate()
		rating_scene.rating = rating
		rating_scene.combo = display_combo

		rating_scene.position = Vector2(hud.player_strum.position.x - 147, hud.player_strum.position.y - 5)
		rating_scene.scale = Vector2(0.45, 0.45)
		hud.add_child(rating_scene)

		_update_hud()

func _held_hit(note, button):
	if not button.bot:
		var splash_scene = COVER_SPLASH_SCENE.instantiate()
		splash_scene.note_type = note.note_type
		button.add_child(splash_scene)
		splash_scene.global_scale = Vector2.ONE
		splash_scene.scale.y *= note.scroll_multi
		splash_scene.position.y *= note.scroll_multi
		splash_scene.z_index = 1

func _note_missed(_note, button):
	if not button.bot:

		combo = 0


		health = clampf(health + -0.06, 0, 1)



		score -= 10

		notes_passed += 1
		misses += 1

		if rating_scene != null:
			rating_scene.queue_free()
		rating_scene = RATING_SCENE.instantiate()
		rating_scene.rating = "miss"
		rating_scene.combo = 0
		rating_scene.position = Vector2(-15, -260)
		rating_scene.scale = Vector2(0.45, 0.45)
		hud.add_child(rating_scene)

		_update_hud()

	Conductor.mute_vocals = true

	_death_check()

func load_chart():
	chart = ChartData.new()
	chart.load_json(chart_path)

func load_song():

	song_inst = load(chart.song_path + "Inst.ogg")
	player_vocals = null
	enemy_vocals = null

	if chart.use_voices:
		if ResourceLoader.exists(chart.song_path + "Voices_Player.ogg") and ResourceLoader.exists(chart.song_path + "Voices_Enemy.ogg"):
			player_vocals = load(chart.song_path + "Voices_Player.ogg")
			enemy_vocals = load(chart.song_path + "Voices_Enemy.ogg")
		else:
			player_vocals = load(chart.song_path + "Voices.ogg")

	Conductor.mute_vocals = false

func generate_chart():
	chart_generator = ChartGenerator.new()
	chart_generator.chart = chart
	add_child(chart_generator)

func _create_hud():
	var hud_layer = CanvasLayer.new()
	add_child(hud_layer)

	var hud_scene = HUD_SCENE.instantiate()
	hud_layer.add_child(hud_scene)

	Event.hud = hud_scene

	return hud_scene


func _create_stage():
	var stage_scene
	var cur_stage = chart.stage

	if ResourceLoader.exists("res://scenes/stages/%s/%s.tscn" % [cur_stage, cur_stage]):
		stage_scene = load("res://scenes/stages/%s/%s.tscn" % [cur_stage, cur_stage]).instantiate()
	else:
		print("could not find " + cur_stage + ", loading stage")
		stage_scene = load("res://scenes/stages/%s/%s.tscn" % ["base-stage", "base-stage"]).instantiate()

	add_child(stage_scene)

	return stage_scene


func _update_hud():
	var accuracy = (notes_hit / notes_passed)
	hud.info_bar.update_info({
		"Score": score, 

		"Rating": "%s [color=darkgray](%s)[/color]" % [
			hud.info_bar.get_rating(accuracy), 
			hud.info_bar.get_accuracy(accuracy, misses)
		], 
		"X": misses
	})

	hud.health_bar.health = health


func _death_check():
	if health <= 0:
		die()

func start_results():
	if ending == false:
		ending = true
		var results_screen = RESULTS_SCREEN.instantiate()
		results_screen.play_state = self
		add_child(results_screen)

func _on_song_finished():
	Event.camera_events.clear()
	if Conductor.cur_song == "Victory":
		return
	start_results()

func end_cutscene_check():
	if has_end_cutscene == true:
		in_cutscene = true
		start_dialog()
	else:
		end_song()


func end_song():

	var file_name = chart.song_path.trim_prefix("res://assets/songs/").trim_suffix("/")

	var old_rating = SaveData.load_rating()[file_name + "-" + Main.difficulty.to_lower()]
	var old_combat = SaveData.load_combats()[file_name + "-" + Main.difficulty.to_lower()]
	var old_total_completion = (old_rating + old_combat) / 2

	var rating = (notes_hit / float(notes_passed)) * 100

	var combat = 100.0
	if stage.combat_node:
		var successful_dodges = stage.combat_node.successful_dodges
		var attack_total = successful_dodges + stage.combat_node.failed_dodges
		if attack_total > 0:
			combat = (float(successful_dodges) / float(attack_total)) * 100

	var total_completion = (rating + combat) / 2

	if total_completion > old_total_completion:
		SaveData.save_misses(file_name, misses)
		SaveData.save_rating(file_name, rating)
		SaveData.save_score(file_name, score)
		SaveData.save_combat(file_name, combat)

	if Main.game_mode == "story":
		if Main.story_count < Main.story_array.size() - 1:
			Main.story_count += 1
			Conductor.cur_song = Main.story_array[Main.story_count]

			if SaveData.load_flags().get(Main.chapter + "_complete") == false:
				if misses > 0:
					SaveData.save_misses(file_name, misses)

			var start_data = Main.get_song_data(Main.story_array[Main.story_count])
			var song_data = start_data.get("song_data", {})
			chart_path = song_data.get("chart_path", "")
			load_chart()


			Main.load_playstate(Main.get_song_data(Main.story_array[Main.story_count]))


		else:

			if SaveData.load_flags().get(Main.chapter + "_complete") == false:
				SaveData.save_flag(Main.chapter + "_complete", true)

			match Main.chapter:
				"ch1":
					SaveData.save_flag("ch2_unlock", true)
				"ch2":
					SaveData.save_flag("ch3_unlock", true)
				"ch3":
					SaveData.save_flag("ch4_unlock", true)
				"ch4":
					SaveData.save_flag("ch5_unlock", true)
				"ch5":
					SaveData.save_flag("ch5.5_unlock", true)
				"ch5.5":
					SaveData.save_flag("ch6_unlock", true)

			Main.reset_story_data()

			Main.change_scene_transition(Main.MAIN_MENU_PATH)

	else:
		Main.change_scene_transition(Main.MAIN_MENU_PATH)

func load_next_song():
	var transition = Main.TRANSITION_SCENE.instantiate()
	add_child(transition)
	await transition.transitioned

	update_assets()
	load_song()
	generate_chart()
	start_song()
	stage.setup_new_song(self)

func update_assets():
	if Main.gf_name != chart.char_gf:
		stage.update_gf(chart.char_gf)
	if Main.enemy_name != chart.char_enemy:
		stage.update_enemy(chart.char_enemy)
	if Main.player_name != chart.char_player:
		stage.update_player(chart.char_player)
