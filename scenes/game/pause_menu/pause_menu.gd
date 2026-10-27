extends CanvasLayer


const FONT = preload("res://assets/resources/fonts/vcr.ttf")


var play_state

var play_music = false

var active = true
var SETTINGS_MENU = preload("res://scenes/states/menus/settings_menu/settings_menu.tscn")

@onready var enemy_portait: Sprite2D = $Node2D / enemy / EnemyPortait / Portrait
@onready var enemy_portait_s: Sprite2D = $Node2D / enemy / EnemyPortait / Portrait / Portrait2


func _ready():
	_pause()
	$BGRect.color.a = 0

	var tween = create_tween()
	tween.tween_property($BGRect, "color:a", 0.6, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)

	_create_info()
	$ChoiceMenu.choices = _get_choices()
	$ChoiceMenu.option_selected.connect(_on_option_selected)
	update_portraits()

	if play_music:
		$MusicStreamPlayer.volume_db = -80
		$MusicStreamPlayer.play(randi_range(0, $MusicStreamPlayer.stream.get_length() / 2))

	_toggle_all_input(false)

func _process(delta):
	if $MusicStreamPlayer.volume_db < -20:
		$MusicStreamPlayer.volume_db += delta * 5

func _unhandled_input(event):
	if !active:
		return

	if event.is_action_pressed("cancel"):
		queue_free()

func _exit_tree():
	get_tree().paused = false
	_toggle_all_input(true)


func _toggle_all_input(input):
	if play_state != null:
		play_state.set_process_unhandled_input(input)

		if play_state.hud != null:
			_toggle_input_strum(play_state.hud.player_strum, input)
			_toggle_input_strum(play_state.hud.enemy_strum, input)

func _toggle_input_strum(strum, input):
	for button in strum.buttons:
		button.set_process_unhandled_input(input)


func _pause():
	get_tree().paused = true
	$AnimationPlayer.play("in")

func _get_choices():
	return ["Resume", "Restart", "Settings", "Exit to menu"]


func _create_info():
	if play_state == null:
		return

	var info_data = [play_state.chart.song_name, Main.difficulty]
	var tween = create_tween().set_parallel(true)

	var i = 0
	for info in info_data:
		var prefix = "[right]"
		if i > 0:
			prefix += "[color=gray]"

		var label = RichTextLabel.new()
		label.text = prefix + info
		label.add_theme_font_override("normal_font", FONT)
		label.add_theme_font_size_override("normal_font_size", 32)

		label.bbcode_enabled = true
		label.fit_content = true

		label.position = Vector2(-20, 15 + (32 * i))
		label.modulate.a = 0
		label.size.x = $InfoControl.size.x

		$InfoControl.add_child(label)

		var delay = 0.3 + (i * 0.2)
		tween.tween_property(label, "modulate:a", 1, 0.4).set_delay(delay).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_property(label, "position", label.position + Vector2(0, 5), 0.4).set_delay(delay).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)

		i += 1

func update_portraits():
	var portait_dict = Weeks.load_json_file("res://scenes/game/pause_menu/pause_portait_offsets.json")
	var enemy_name = Main.enemy_name
	var enemy_texture = load("res://scenes/game/character/%s/portrait.png" % [enemy_name])

	if portait_dict.get(str(enemy_name), {}) == {}:
		return

	enemy_portait.texture = enemy_texture
	enemy_portait_s.texture = enemy_texture

	var offsets = portait_dict.get(str(enemy_name), "null")

	enemy_portait.position.x = offsets.get("pos")[0]
	enemy_portait.position.y = offsets.get("pos")[1]
	enemy_portait.rotation_degrees = offsets.get("rot")
	enemy_portait.scale = Vector2.ONE * offsets.get("size")

	enemy_portait_s.position = Vector2(20, 20) / enemy_portait.scale

func _on_option_selected(index):
	match index:
		0:
			queue_free()
		1:
			Conductor.stop_music()



			var state = PlayState.new()
			state.chart_path = play_state.chart.file_path
			state.restarted = true
			var sfx = load("res://assets/sounds/menu/menuConfirm_4.ogg")

			play_sound(sfx)

			Main.change_scene_transition(state, "fade")
		2:
			active = false
			create_settings()
			var sfx = load("res://assets/sounds/menu/menuConfirm_3.ogg")
			play_sound(sfx)
		3:
			Conductor.stop_music()
			Event.camera_events.clear()
			Main.reset_story_data()
			if Main.game_mode == "freeplay":
				Main.change_scene_transition(Main.MAIN_MENU_PATH)
			elif Main.game_mode == "story":
				Main.change_scene_transition(Main.MAIN_MENU_PATH)
			else:
				Main.change_scene_transition(Main.MAIN_MENU_PATH)

			var sfx = load("res://assets/sounds/menu/menuCancel.ogg")
			play_sound(sfx)

func create_settings():
	var menu
	menu = SETTINGS_MENU.instantiate()
	add_child(menu)

func play_sound(sfx, variance: float = 0.0):
	var player = AudioStreamPlayer.new()
	player.stream = sfx
	player.pitch_scale = randf_range(1 - variance, 1 + variance)
	add_sibling(player)
	player.play()
	await player.finished

	player.queue_free()
