extends Node2D

var sound_player: = AudioStreamPlayer.new()

var alphabet: Label
var alphabet2: Label
var alphabet3: Label
var alphabet4: Label
var introSkipped: bool = false
var tween
var fake_bg_speed = 0

@onready var introBG: ColorRect = $introBG
@onready var olly_surprise = $olly
@onready var characters = $characters
@onready var castle = $castle
@onready var fake_out_player = $AnimationPlayer
@onready var white_screen = $whiteScreen
@onready var godot_logo = $godotLogo
@onready var title_logo = $TitleLogo
@onready var title_enter = $TitleEnter
@onready var black = $CanvasLayer / black


var old_menu_theme = preload("res://assets/music/oldMenuSnippet.ogg")
var menu_theme = preload("res://assets/music/TitleMenu.ogg")


func _ready():
	Main.game_mode = "menu"

	if SaveData.load_flags().get("title_screen_viewed") == true:
		Conductor.step_changed.connect(_on_beat)
		$black.modulate.a = 0
		$fake_out_bg.modulate.a = 0
		$fake_out_logo.modulate.a = 0
		$fake_out_characters.modulate.a = 0
	else:
		Conductor.song_position_updated.connect(_on_song_position_update)
		Conductor.step_changed.connect(_on_step)
		$black.modulate.a = 1
		$fake_out_bg.modulate.a = 1
		$fake_out_logo.modulate.a = 1
		$fake_out_characters.modulate.a = 1

	$fake_out_characters.position.x = -640


	add_child(sound_player)

	godot_logo.self_modulate.a = 0

	if SaveData.load_flags().get("title_screen_viewed") == false:
		Conductor.beat_changed.connect(_on_step)
		white_screen.visible = false
		introBG.visible = true
		Conductor.play_song(old_menu_theme, 100, null, null, 3)
		Conductor.cur_song = "old_menu_theme"
	else:
		white_screen.visible = true
		introBG.visible = false
		$characters.play("default")
		Conductor.play_song(menu_theme, 100, null, null, 3)
		Conductor.cur_song = "menu_theme"
		alphabet = Label.new()

		alphabet.add_theme_font_override("font", load("res://assets/resources/fonts/D-DINCondensed.otf"))
		alphabet.add_theme_color_override("font_color", Color.BLACK)
		add_child(alphabet)
		alphabet2 = Label.new()
		alphabet2.add_theme_font_override("font", load("res://assets/resources/fonts/D-DINCondensed.otf"))
		alphabet2.add_theme_color_override("font_color", Color.BLACK)
		add_child(alphabet2)
		alphabet3 = Label.new()
		alphabet3.add_theme_font_override("font", load("res://assets/resources/fonts/D-DINCondensed.otf"))
		alphabet3.add_theme_color_override("font_color", Color.BLACK)
		add_child(alphabet3)
		alphabet4 = Label.new()
		alphabet4.add_theme_font_override("font", load("res://assets/resources/fonts/D-DINCondensed.otf"))
		alphabet4.add_theme_color_override("font_color", Color.BLACK)
		add_child(alphabet4)
		alphabet.size.x = 1280
		alphabet2.size.x = 1280
		alphabet3.size.x = 1280
		alphabet4.size.x = 1280
		alphabet.add_theme_font_size_override("font_size", 80)
		alphabet2.add_theme_font_size_override("font_size", 80)
		alphabet3.add_theme_font_size_override("font_size", 80)
		alphabet4.add_theme_font_size_override("font_size", 80)
		alphabet.horizontal_alignment = 1
		alphabet.vertical_alignment = 1
		alphabet2.horizontal_alignment = 1
		alphabet2.vertical_alignment = 1
		alphabet3.horizontal_alignment = 1
		alphabet3.vertical_alignment = 1
		alphabet4.horizontal_alignment = 1
		alphabet4.vertical_alignment = 1
		alphabet.self_modulate.a = 0
		alphabet2.self_modulate.a = 0
		alphabet3.self_modulate.a = 0
		alphabet4.self_modulate.a = 0

func _input(event):
	if SaveData.load_flags().get("title_screen_viewed") == true:
		if event.is_action_pressed("confirm"):
			if introSkipped:
				set_process_input(false)
				$CanvasLayer / Filter.modulate.a = 0
				var new_white_screen = white_screen.duplicate()
				add_child(new_white_screen)

				var white_tween = get_tree().create_tween().set_parallel()
				white_tween.tween_property(new_white_screen, "self_modulate:a", 0, 2).from(0.5)

				var text_tween = get_tree().create_tween().set_loops(12)
				text_tween.tween_property($TitleEnter, "modulate:a", 0, 0.1).from(1)
				text_tween.tween_property($TitleEnter, "modulate:a", 1, 0.1).from(0)

				var sound_effect = load("res://assets/sounds/menu/title_screen/titleConfirm.ogg")
				sound_player.stream = sound_effect
				sound_player.play()






				await get_tree().create_timer(2).timeout
				SaveData.save_flag("title_screen_viewed", true)
				Main.change_scene_transition("res://scenes/states/menus/main_menu/main_menu_new.tscn", "fade")
			else:
				skipIntro()

func fakeOutText(step):
	if SaveData.load_flags().get("title_screen_viewed") == false:
		match int(step):
			7:
				fake_out_player.play("fake_out_sequence")
			12:
				sound_player.stream = load("res://assets/sounds/menu/title_screen/run_and_throw.ogg")
				sound_player.play()
			16:
				SaveData.save_flag("title_screen_viewed", true)
				Conductor.stop_music()
				white_screen.visible = true
				await get_tree().create_timer(1).timeout
				_ready()

func introText(step):
	if SaveData.load_flags().get("title_screen_viewed") == true:


		match int(step):
			0:
				createText("top", "TEAM INCREASE", -40)
			8:
				createText("bottom", "PRESENTS", 40)
			14:
				fadeOutText("top")
				fadeOutText("bottom")
			16:
				createText("top", "POWERED BY", -40)
			24:
				createText("bottom", "GODOT ENGINE", 40)
				godot_logo.position.y = 460
				var tween = get_tree().create_tween()
				tween.parallel().tween_property(godot_logo, "self_modulate:a", 1, 0.5)
				tween.parallel().tween_property(godot_logo, "position:y", 440, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			30:
				var tween = get_tree().create_tween()
				tween.parallel().tween_property(godot_logo, "self_modulate:a", 0, 0.2)
				fadeOutText("top")
				fadeOutText("bottom")
			32:
				createText("top", "FOR EVERY MOUNTAIN FOLD,", -40)
			40:
				createText("middle", "THERE IS A VALLEY FOLD.", 40)
			48:
				createText("bottom", "-OLIVIA ", 120)
			56:
				fadeOutText("top")
				fadeOutText("middle")
				fadeOutText("bottom")
			64:
				createText("top", "PROJECT", -40)
			68:
				createText("middle", "FUNKY", 40)
			72:
				createText("bottom", "PAPER", 120)
			76:
				createText("bottomer", "V3", 200)
			80:
				fadeOutText("top")
			81:
				fadeOutText("middle")
			82:
				fadeOutText("bottom")
			83:
				fadeOutText("bottomer")
			96:
				skipIntro()

func createText(pos, text, offset):
	if pos == "top":
		alphabet.text = (text + "")
		alphabet.position.y = 200 + offset + 20
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet, "self_modulate:a", 1, 0.5)
		tween.parallel().tween_property(alphabet, "position:y", 200 + offset, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	elif pos == "middle":
		alphabet2.text = (text + "")
		alphabet2.position.y = 200 + offset + 20
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet2, "self_modulate:a", 1, 0.5)
		tween.parallel().tween_property(alphabet2, "position:y", 200 + offset, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	elif pos == "bottom":
		alphabet3.text = (text + "")
		alphabet3.position.y = 200 + offset + 20
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet3, "self_modulate:a", 1, 0.5)
		tween.parallel().tween_property(alphabet3, "position:y", 200 + offset, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	elif pos == "bottomer":
		alphabet4.text = (text + "")
		alphabet4.position.y = 200 + offset + 20
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet4, "self_modulate:a", 1, 0.5)
		tween.parallel().tween_property(alphabet4, "position:y", 200 + offset, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
func deleteText(pos):
	if pos == "top":
		alphabet.self_modulate.a = 0
	elif pos == "middle":
		alphabet2.self_modulate.a = 0
	elif pos == "bottom":
		alphabet3.self_modulate.a = 0
	elif pos == "bottomer":
		alphabet4.self_modulate.a = 0
func fadeOutText(pos):
	if pos == "top":
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet, "self_modulate:a", 0, 0.2)
	elif pos == "middle":
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet2, "self_modulate:a", 0, 0.2)
	elif pos == "bottom":
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet3, "self_modulate:a", 0, 0.2)
	elif pos == "bottomer":
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(alphabet4, "self_modulate:a", 0, 0.2)

func skipIntro():
	introSkipped = true

	var white_tween = get_tree().create_tween()
	white_tween.tween_property(white_screen, "self_modulate:a", 0, 4)

	var text_tween = get_tree().create_tween().set_loops(12)
	text_tween.tween_property($TitleEnter, "modulate:a", 0, 0.5).from(1)
	text_tween.tween_property($TitleEnter, "modulate:a", 1, 1.5).from(0)

	remove_child(alphabet)
	remove_child(alphabet2)
	remove_child(alphabet3)
	remove_child(alphabet4)
	godot_logo.modulate.a = 0

	_cut_in()

func _cut_in():
	await get_tree().create_timer(randf_range(5, 20)).timeout
	sound_player.stream = load("res://assets/sounds/menu/title_screen/ollie_surprise.ogg")
	sound_player.play()
	olly_surprise.play("emerge")
	await olly_surprise.animation_finished
	olly_surprise.play("present")
	await get_tree().create_timer(randf_range(3, 6)).timeout
	await olly_surprise.frame == 5
	olly_surprise.play("vanish")
	sound_player.stream = load("res://assets/sounds/menu/title_screen/ollie_reverse.ogg")
	sound_player.play()
	await get_tree().create_timer(1).timeout
	_cut_in()

func _on_beat(step):
	if SaveData.load_flags().get("title_screen_viewed") == true:
		if !introSkipped:
			introText(step)

func _on_step(step):
	if SaveData.load_flags().get("title_screen_viewed") == false:
		if int(step) % 8 == 0:
			$fake_out_logo.scale += Vector2(0.05, 0.05)

func _on_song_position_update(pos, last_pos):
	if SaveData.load_flags().get("title_screen_viewed") == false:

		if song_pos_check(2.94):
			fake_bg_speed = 120
			var t = create_tween()
			t.tween_property($black, "modulate:a", 0, 4)

		if song_pos_check(4.11):
			var t = create_tween()
			t.tween_property($fake_out_characters, "position:x", 640, 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


		if song_pos_check(8.67 - 0.33):
			$fake_out_characters.play("halt")

			await get_tree().create_timer(0.33).timeout
			var t = create_tween()
			t.tween_property(self, "fake_bg_speed", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

			sound_player.stream = load("res://assets/sounds/menu/title_screen/halt.ogg")
			sound_player.play()

		if song_pos_check(9.41 - 0.33):
			$fake_out_characters.play("throw")
			await get_tree().create_timer(0.33).timeout
			sound_player.stream = load("res://assets/sounds/menu/title_screen/throw.ogg")
			sound_player.play()

		if song_pos_check(11.17):
			SaveData.save_flag("title_screen_viewed", true)
			Conductor.stop_music()
			white_screen.visible = true
			await get_tree().create_timer(1).timeout
			_ready()

func _process(delta):
	if SaveData.load_flags().get("title_screen_viewed") == false:
		$fake_out_bg.position.x -= fake_bg_speed * delta
		$fake_out_logo.scale = lerp($fake_out_logo.scale, Vector2(0.667, 0.667), delta * 5)


func song_pos_check(time: float):
	var pos = Conductor.song_position / 1000
	var last_pos = Conductor.last_song_position / 1000

	if pos >= time and last_pos <= time:
		return true
	else: return false
