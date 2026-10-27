class_name Stage
extends Node2D


@export var camera_zoom: = Vector2.ONE

@export var player_position: Vector2
@export var player_cam_override: Marker2D
@export var enemy_position: Vector2
@export var gf_position: Vector2
@export var rating_position: Vector2
@export var center_position: Vector2

@export var gf_distance: float = 0
@export var gf_size: float = 1.0
@export var gf_z: int = 0

@export var enemy_z: int = 0

@export var offset_amount: float = 20

@export var sprites_node: Node2D

@export_node_path("Node") var path_characters_node = NodePath("Characters")
@export_node_path("Node") var path_positions_node = NodePath("Positions")
@export_node_path("Marker2D") var stage_center

var player_node
var enemy_node
var gf_node

var player_character: Character
var enemy_character: Character
var gf_character: Character

var camera: Camera2D
var camera_target: Camera2D
var do_camera_movement: bool = true
var special_cam: bool = false
var cam_check = false
var zoom_offset: float = 0.0

var chart_generator: ChartGenerator

var combat_node: Node

var camera_offset: = Vector2.ZERO
var must_hit: = true

var playstate: PlayState

var bump_int: int = 0

@onready var characters_node = get_node_or_null(path_characters_node)
@onready var positions_node = get_node_or_null(path_positions_node)

func _ready():
	Conductor.beat_changed.connect(_on_beat)
	Conductor.step_changed.connect(_on_step)
	Event.stage = self

	for i in positions_node.get_children():
		for c in i.get_children():
			if c is Character:
				c.queue_free()

	await get_tree().create_timer(0.05).timeout

	if player_character != null:
		var mood = "happy"
		if playstate != null and ResourceLoader.exists(playstate.chart.song_path + "data.json"):
			var data: Dictionary = Weeks.load_json_file(playstate.chart.song_path + "data.json")
			mood = data.get("BFMood", "happy")
		player_character.sprite.set_mood(mood)

func _process(delta):
	if camera != null:

		if !cam_check:
			camera.position = camera_offset
			cam_check = true

		var offset_scale = 100 - (Event.camera_scale - 100)
		camera.position = lerp(camera.position, (camera_offset), delta * 10)
		camera.offset = Event.shake_offset

		if zoom_offset != 0:
			zoom_offset = lerp(zoom_offset, 0.0, delta * 5)
		camera.zoom = camera_target.zoom + Vector2(zoom_offset, zoom_offset)
		camera.rotation_degrees = camera_target.rotation_degrees
		Event.screen_pos = camera.get_screen_center_position()
		if gf_distance > 0:
			gf_character.sprite.offset = Vector2(camera.get_screen_center_position()) * gf_distance
		gf_node.scale = Vector2.ONE * gf_size
		_update_camera()


func setup_from_play_state(play_state):
	register_chart_generator(play_state.chart_generator)
	setup_from_chart()

	player_character.register_strum(play_state.hud.player_strum)
	enemy_character.register_strum(play_state.hud.enemy_strum)
	Main.stage_name = play_state.chart.stage
	Main.player_name = play_state.chart.char_player
	Main.enemy_name = play_state.chart.char_enemy
	Main.gf_name = play_state.chart.char_gf
	playstate = play_state

func setup_combat_node(path):
	var node = load("res://scenes/game/combat_node.tscn")
	var node_instance = node.instantiate()
	node_instance.combat_filepath = path
	node_instance.stage = self
	combat_node = node_instance
	add_child(combat_node)

func setup_new_song(play_state):
	register_chart_generator(play_state.chart_generator)


func setup_from_chart(chart = null):
	if chart == null:
		if chart_generator != null:
			chart = chart_generator.chart

	if chart == null:
		return

	if camera_target == null:
		camera_target = Camera2D.new()
		add_child(camera_target)
		camera_target.enabled = false
		camera_target.zoom = camera_zoom
		camera_target.global_position = Vector2(0, 0)
		Event.camera_target = camera_target


	if camera == null:
		camera = Camera2D.new()

		camera.ignore_rotation = false

		camera.zoom = camera_zoom

		camera_target.add_child(camera)
		camera.global_position = camera_target.global_position

		Event.camera = camera

	if characters_node == null:
		characters_node = self

	if positions_node != null:
		player_position = _get_position_from_node("PlayerPosition")
		enemy_position = _get_position_from_node("EnemyPosition")
		gf_position = _get_position_from_node("GFPosition")
		center_position = _get_position_from_node("StageCenter")

		rating_position = _get_position_from_node("RatingPosition")

	create_char_nodes()

	gf_character = _setup_character_godot(chart.char_gf, "gf")
	gf_node.add_child(gf_character)
	if gf_character.flip_x:
		gf_character.sprite.scale.x = - gf_character.sprite.scale.x
	gf_character.sung_note.connect(_update_camera_offset.bind(gf_character))
	gf_character.z_index = gf_z

	if ResourceLoader.exists(chart.song_path + "data.json"):
		var data = Weeks.load_json_file(chart.song_path + "data.json")
		if data.get("gf_mod", null) != null:
			gf_character.beat_mod_override = int(data.get("gf_mod"))

	player_character = _setup_character_godot(chart.char_player, "bf")

	player_node.add_child(player_character)
	if player_character.flip_x:
		player_node.scale.x = - player_node.scale.x
	player_character.sung_note.connect(_update_camera_offset.bind(player_character))
	if player_cam_override:
		player_character.camera_pos.global_position = player_cam_override.global_position


	enemy_character = _setup_character_godot(chart.char_enemy, "bf")
	enemy_character.flip_x = !enemy_character.flip_x

	enemy_node.add_child(enemy_character)
	if enemy_character.flip_x:
		enemy_character.sprite.scale.x = - enemy_character.sprite.scale.x
	enemy_character.sung_note.connect(_update_camera_offset.bind(enemy_character))
	enemy_character.z_index = enemy_z

	if camera != null:
		camera_target.global_position = to_global(_get_position_from_node("StageCenter"))
		camera.global_position = to_global(_get_position_from_node("StageCenter"))



func register_chart_generator(new_chart_generator: ChartGenerator):
	chart_generator = new_chart_generator
	new_chart_generator.section_changed.connect(_on_section_changed)




func _update_camera(section_data = null):

	if section_data != null and len(section_data) >= 1:
		must_hit = section_data[1]

	if camera == null:
		return

	if camera_target == null:
		return

	var character = player_character
	var characterNode = player_node
	if not must_hit:
		character = enemy_character
		characterNode = enemy_node


	var x_multi = 1
	if character.flip_x:
		x_multi = -1

	var default_pos = characterNode.global_position + Vector2(character.camera_pos.position.x * x_multi, character.camera_pos.position.y)

	if Settings.load_camera().camera_style == "static":
		return

	if !special_cam:

		var t = create_tween()
		t.tween_property(camera, "position", default_pos + camera_offset, 2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _setup_character_godot(char_name: String, default_name = null):
	var character = Character.new()
	if ResourceLoader.exists("res://scenes/game/character/%s/%s.tscn" % [char_name, char_name]) or default_name == null:
		character = load("res://scenes/game/character/%s/%s.tscn" % [char_name, char_name])
		return character.instantiate()
	else:
		print("could not find " + char_name + ", loading " + default_name)
		return _setup_character_godot(default_name)

func _setup_character(char_name: String, default_name = null):
	var character = CharacterPsych.new()
	character.psych_character = "res://assets/characters/%s/%s.json" % [char_name, char_name]
	character.sung_note.connect(_update_camera_offset.bind(character))
	character.load_character()
	if not character.json_data.is_empty() or default_name == null:
		return character
	else:
		return _setup_character(default_name)

func _get_sprite_rect(character):
	var sprite_rect = character.sprite.texture.get_size() / Vector2(
	character.sprite.hframes, 
	character.sprite.vframes)

	return sprite_rect


func _get_position_from_node(path: NodePath):
	var got_position = Vector2.ZERO

	var position_node = positions_node.get_node_or_null(path)
	if position_node != null:
		got_position = position_node.position

	return got_position

func _update_camera_offset(note_type, miss, character = null):
	if not Settings.load_camera().camera_dynamic:
		return

	if Main.game_mode != "editor":
		if miss:

			return

		if must_hit and character != player_character:
			return

		if not must_hit and character != enemy_character:
			return

	match note_type:
		0:
			camera_offset = Vector2(-1, 0)
		1:
			camera_offset = Vector2(0, 1)
		2:
			camera_offset = Vector2(0, -1)
		3:
			camera_offset = Vector2(1, 0)

	camera_offset *= offset_amount

	_update_camera()

func _on_section_changed(section_data):
	_update_camera(section_data)

func _on_beat(beat):
	if int(beat) < 0:
		return

func _on_step(step):
	if int(step) <= 0:
		return

	if Event.bump_step_rate == -1:
		return

	if Event.bump_sequence.size() == 0:
		return

	if int(step) % Event.bump_step_rate == 0:
		Event.camera_bump(Event.bump_sequence[bump_int])
		bump_int += 1
		if bump_int > Event.bump_sequence.size() - 1:
			bump_int = 0

		print(step / Event.bump_step_rate)

func song_pos_check(time: float):
	var pos = Conductor.song_position / 1000
	var last_pos = Conductor.last_song_position / 1000

	if pos >= time and last_pos <= time:
		return true
	else: return false

func update_player(new_char: String):
	player_character.queue_free()

	player_character = _setup_character_godot(new_char, "bf")
	player_character.position = player_position
	characters_node.add_child(player_character)
	if player_character.flip_x:
		player_character.sprite.scale.x = - player_character.sprite.scale.x
	player_character.sung_note.connect(_update_camera_offset.bind(player_character))
	player_character.register_strum(playstate.hud.player_strum)

func update_enemy(new_char: String):
	enemy_character.queue_free()

	enemy_character = _setup_character_godot(new_char, "bf")
	enemy_character.flip_x = !enemy_character.flip_x
	enemy_character.position = enemy_position
	characters_node.add_child(enemy_character)
	if enemy_character.flip_x:
		enemy_character.sprite.scale.x = - enemy_character.sprite.scale.x
	enemy_character.sung_note.connect(_update_camera_offset.bind(enemy_character))
	enemy_character.register_strum(playstate.hud.enemy_strum)

func update_gf(new_char: String):
	gf_character.queue_free()

	gf_character = _setup_character_godot(new_char, "gf")
	gf_character.position = gf_position
	characters_node.add_child(gf_character)
	if gf_character.flip_x:
		gf_character.sprite.scale.x = - gf_character.sprite.scale.x
	gf_character.sung_note.connect(_update_camera_offset.bind(gf_character))

func create_char_nodes():

	var gn = Node2D.new()
	characters_node.add_child(gn)
	gn.global_position = gf_position
	gf_node = gn

	var pn = Node2D.new()
	characters_node.add_child(pn)
	pn.global_position = player_position
	player_node = pn

	var en = Node2D.new()
	characters_node.add_child(en)
	en.global_position = enemy_position
	enemy_node = en
