extends AnimatedSprite2D

@export var option_container: VBoxContainer
@export var id: String
@export var path: AnimatedSprite2D
@export var map: AnimatedSprite2D
@export var fakepath: AnimatedSprite2D
@export var fakemap: AnimatedSprite2D

@export var bg: AnimatedSprite2D


@export var outline: Sprite2D
@export var fake_outline: Sprite2D
@export var cliff: Sprite2D
@export var cloud: Sprite2D
@export var sky: Sprite2D

@export var difficulty_sprites: Array[AnimatedSprite2D]

@export_category("Color Changing")
@export var tab: AnimatedSprite2D
@export var panel: AnimatedSprite2D
@export var tabframe: AnimatedSprite2D
@export var skin_panel: AnimatedSprite2D
@export var skin_selection: Node2D

var volume_tween

var selecting_skin = false

var menu

var tempath
var maptween: Tween
const FREEPLAY_OPTION = preload("res://scenes/states/menus/freeplay_menu/freeplay_option.tscn")
var bg_base_tex = preload("res://scenes/states/menus/menuDark.png")

var active = true

var option_array: Array
var cur_selected: int = -1

var target_y: float

var scrolling = []

var leaptween

var story_map_dicts = [
	{"value": 1, "range": [0, 5], "xy": [0, 0]}, 
	{"value": 2, "range": [6, 10], "xy": [1, 0]}, 
	{"value": 3, "range": [11, 15], "xy": [2, 0]}, 
	{"value": 4, "range": [16, 20], "xy": [3, 0]}, 
	{"value": 5, "range": [21, 25], "xy": [3, 1]}, 
	{"value": 6, "range": [26, 31], "xy": [3, 2]}
]
var extra_map_dicts = [
	{"value": 1, "range": [0, 2], "xy": [0, 0]}, 
	{"value": 2, "range": [3, 7], "xy": [1, 0]}, 
	{"value": 3, "range": [8, 11], "xy": [2, 0]}, 
	{"value": 4, "range": [12, 15], "xy": [3, 0]}, 
	{"value": 5, "range": [16, 19], "xy": [3, 1]}, 
	{"value": 7, "range": [20, 28], "xy": [3, 3]}
]


var cur_map_dict: Dictionary = story_map_dicts[0]


func _ready():

	load_songs()
	update_difficulty_sprites(1)
	update_stats("hard")
	tab.animation = id
	panel.animation = id
	tabframe.animation = id
	path.animation = id
	fakepath.animation = id
	skin_panel.animation = id
	await get_tree().create_timer(0.025).timeout
	updateCurSelected(0)


func load_songs():
	for song in Weeks.freeplay_json.songs:
		load_option(song.get("name"), song.get("color"), song.get("map_value"), "story")
	for song in Weeks.unlocks_json.songs:
		load_option(song.get("name"), song.get("color"), song.get("map_value"), "extra")

func load_option(option_name: String = "null", color: int = 0, map_value: int = 0, type: String = "story"):
	if type == id:
		var chart: = ChartData.new()
		chart.load_json("res://assets/songs/%s/%s-hard.json" % [option_name, option_name])

		var option = FREEPLAY_OPTION.instantiate()

		option.custom_minimum_size.x = option.min_x
		option.custom_minimum_size.y = option.min_y
		option.title.text = chart.song_name
		option.sprite.animation = type
		option.map_value = map_value
		option.ribbon.frame = color
		option.chart = chart


		var bgpath = "res://scenes/states/menus/freeplay_menu/sprites/Bgs/%s/%s.png" % [id, map_value]
		if ResourceLoader.exists(bgpath):
			option.bg_sprite = load(bgpath)
		else:
			option.bg_sprite = bg_base_tex

		var icon_path = "res://cutscenes/images/icons/icon-%s.png" % [str(chart.char_enemy)]
		if ResourceLoader.exists(icon_path):
			option.icon.texture = load(icon_path)

		option_array.append(option)
		option_container.add_child(option)

		if type == "extra":
			option.visible = false

func _process(delta):
	option_container.position.y = lerp(option_container.position.y, target_y, delta * 15)

	bg.position.x -= 0.25
	if bg.position.x <= -1185:
		bg.position.x += 1185

	for i in scrolling:
		i.position.x -= 0.25
		if i.position.x <= -1185:
			i.position.x += 1185

	if selecting_skin:
		if !Input.is_action_pressed("shift"):
			selecting_skin = false
			var t = create_tween().set_parallel()
			t.tween_property(skin_panel, "position:x", -1200.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			t.tween_property( %arrows, "modulate:a", 0, 0.25)
			t.tween_property($SkinSelection, "position:x", -800.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			var sfx = load("res://assets/sounds/menu/menuClickDown.ogg")
			play_sound(sfx)

func _input(event):
	if active:
		if event.is_action_pressed("ui_down"):
			updateCurSelected(1)
		if event.is_action_pressed("ui_up"):
			updateCurSelected(-1)
		if selecting_skin == false:
			if event.is_action_pressed("confirm"):
				active = false
				option_array[cur_selected].anim.stop()
				option_array[cur_selected].anim.play("2")
				Main.game_mode = "freeplay"
				Main.load_playstate(Main.get_song_data(option_array[cur_selected].chart.file_name, menu.difficulties[menu.difficulty]))
				Conductor.cur_song = option_array[cur_selected].chart.song_name
				var sfx = load("res://assets/sounds/menu/menuConfirm_1.ogg")
				play_sound(sfx)


				var t = create_tween()
				t.tween_property(Conductor.music_stream_player, "volume_db", -80, 0.5)
				t.chain().tween_callback(reset_music_volume)

		if Input.is_action_just_pressed("shift"):
			selecting_skin = true
			var t = create_tween().set_parallel()
			t.tween_property(skin_panel, "position:x", -360.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			t.tween_property( %arrows, "modulate:a", 0.5, 0.25)
			t.tween_property($SkinSelection, "position:x", -375.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			var sfx = load("res://assets/sounds/menu/menuClickUp.ogg")
			play_sound(sfx)
		if Input.is_action_just_released("shift"):
			selecting_skin = false
			var t = create_tween().set_parallel()
			t.tween_property(skin_panel, "position:x", -1200.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			t.tween_property( %arrows, "modulate:a", 0, 0.25)
			t.tween_property($SkinSelection, "position:x", -800.0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			var sfx = load("res://assets/sounds/menu/menuClickDown.ogg")
			play_sound(sfx)

func reset_music_volume():
	Conductor.stop_music()
	Conductor.music_stream_player.volume_db = 0


func updateCurSelected(change: int = 0, jump_to: int = -1):



	if jump_to == -1:
		if cur_selected + change > option_array.size() - 1: return


		if cur_selected + change < 0: return



		option_array[cur_selected].selected = false
		option_array[cur_selected].anim.play("0")

		cur_selected += change
	else:
		cur_selected = jump_to
		option_container.position.y = ( - cur_selected * option_array[cur_selected].min_y) - 15


	target_y = ( - cur_selected * option_array[cur_selected].min_y) - 15

	option_array[cur_selected].selected = true
	option_array[cur_selected].anim.play("1")



	update_map(option_array[cur_selected].map_value, change == 0)
	menu._update_stage(option_array[cur_selected].bg_sprite, change == 0)
	menu._update_portrait(option_array[cur_selected].chart.char_enemy, change == 0)


	if change != 0:
		var sfx = load("res://assets/sounds/menu/menuScroll.ogg")
		play_sound(sfx)



	match id:
		"story":
			Main.Last_Story_Freeplay_Option = cur_selected
		"extra":
			Main.Last_Extra_Freeplay_Option = cur_selected

func update_difficulty_sprites(index):
	for i in difficulty_sprites:
		i.frame = 0
	difficulty_sprites[index].frame = 1

func update_stats(difficulty):
	var scores = SaveData.load_scores()
	var accuracies = SaveData.load_rating()
	var combats = SaveData.load_combats()
	for option in option_array:
		var score = scores[option.chart.file_name + "-" + difficulty]
		option.score.text = str(int(score))

		var accuracy = accuracies[option.chart.file_name + "-" + difficulty]
		option.accuracy.text = ("%.2f" % accuracy) + "%"

		var combat = combats[option.chart.file_name + "-" + difficulty]
		option.combat.get_child(0).modulate = Color("0000004d")
		option.combat.get_child(1).modulate = Color("0000004d")
		option.combat.get_child(2).modulate = Color("0000004d")
		if combat > 0:
			option.combat.get_child(0).modulate = Color("#ffffffff")
		if combat > 66:
			option.combat.get_child(1).modulate = Color("#ffffffff")
		if combat == 100:
			option.combat.get_child(2).modulate = Color("#ffffffff")

		var total_completion = (accuracy + combat) / 2
		option.total_completion.text = ("%.2f" % total_completion) + "%"

func update_map(map_value, force: bool = false):

	var old_path_frame = path.frame
	path.frame = map_value

	var new_map_dict: Dictionary

	if id == "story":
		for i in story_map_dicts:
			if map_value > i.get("range")[0] and map_value < i.get("range")[1]:
				new_map_dict = i

	if id == "extra":
		for i in extra_map_dicts:
			if map_value > i.get("range")[0] and map_value < i.get("range")[1]:
				new_map_dict = i

	if new_map_dict.get("value") != cur_map_dict.get("value"):

		var leap = false
		var x_diff = new_map_dict.get("xy")[0] - cur_map_dict.get("xy")[0]
		var y_diff = new_map_dict.get("xy")[1] - cur_map_dict.get("xy")[1]


		if abs(x_diff) > 1 or abs(y_diff) > 1:
			leap = true

		fakemap.frame = map.frame

		var tween_dir: Vector2

		if new_map_dict.get("xy")[1] > cur_map_dict.get("xy")[1]:
			tween_dir = Vector2(0, -1)
			fakepath.frame = path.frame - 2
		elif new_map_dict.get("xy")[1] < cur_map_dict.get("xy")[1]:
			tween_dir = Vector2(0, 1)
			fakepath.frame = path.frame + 2
		elif new_map_dict.get("xy")[0] > cur_map_dict.get("xy")[0]:
			tween_dir = Vector2(1, 0)
			fakepath.frame = path.frame - 2
		elif new_map_dict.get("xy")[0] < cur_map_dict.get("xy")[0]:
			tween_dir = Vector2(-1, 0)
			fakepath.frame = path.frame + 2

		if leap:
			fakepath.frame = old_path_frame

		if force == false:
			var sfx = load("res://assets/sounds/menu/menuOut.ogg")
			play_sound(sfx, 0.05)

		var duration = 1.0
		if force: duration = 0

		var t = create_tween().set_parallel()
		t.tween_property(map, "position", Vector2(0, 0), duration).from(Vector2(1242, 1001) * tween_dir).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		t.tween_property(fakemap, "position", Vector2(1242, 1001) * - tween_dir, duration).from(Vector2(0, 0)).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		map.frame = new_map_dict.get("value")
		cur_map_dict = new_map_dict

		var leap_duration = 0.2
		if force: leap_duration = 0

		if leap == true:
			path.modulate.a = 0
			fakepath.modulate.a = 1

			if leaptween is Tween:
				leaptween.kill()
			var tp = create_tween()
			leaptween = tp
			tp.tween_property(fakepath, "modulate:a", 0, leap_duration)
			tp.tween_interval(0.15)
			tp.tween_property(path, "modulate:a", 1, leap_duration)
			tp.parallel().tween_property(path, "scale", Vector2.ONE, duration).from(Vector2(1.025, 1.025)).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

		else:
			path.modulate.a = 1
			fakepath.modulate.a = 1

		var cliff_pos
		var cloud_pos
		var sky_pos

		if map.frame == 6:
			outline.visible = true
			cliff_pos = 0
			cloud_pos = 0
		else:
			outline.visible = false
			cliff_pos = 1036.0 / 2.0
			cloud_pos = -1036.0 / 4.0

		if map.frame == 4:
			sky_pos = 0
		else:
			sky_pos = -1036.0 / 3.0

		var tc = create_tween().set_parallel()
		tc.tween_property(cliff, "position:y", cliff_pos, duration * 1.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tc.tween_property(cloud, "position:y", cloud_pos, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tc.tween_property(sky, "position:y", sky_pos, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


		if fakemap.frame == 6:
			fake_outline.visible = true
		else:
			fake_outline.visible = false

		var newbg = bg.duplicate()
		$mask / bg_fade.add_child(newbg)
		$mask / bg_fade.move_child(newbg, 0)
		scrolling.append(newbg)

		bg.frame = new_map_dict.get("value")

		var ta = create_tween()
		ta.tween_property(newbg, "modulate:a", 0, duration).from(1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		await ta.finished
		scrolling.erase(newbg)
		newbg.queue_free()



func play_sound(sfx, variance: float = 0.0):
	var player = AudioStreamPlayer.new()
	player.stream = sfx
	player.pitch_scale = randf_range(1 - variance, 1 + variance)
	add_sibling(player)
	player.play()
	await player.finished

	player.queue_free()
