extends Node2D

const demo: bool = false

@export var camera: Camera2D
@export var sfx_player: AudioStreamPlayer
@export var options_node: Node

var story_node: CanvasLayer
@export var freeplay_node: CanvasLayer

var cam_zoom = 0.76



var FREEPLAY_MENU = preload("res://scenes/states/menus/freeplay_menu/freeplay_menu.tscn")

var SETTINGS_MENU = preload("res://scenes/states/menus/settings_menu/settings_menu.tscn")

const CREDITS_SCENE = preload("uid://w83x05n0l8hg")

var cur_selected = 0

var active: bool = false


var freeplay_active

func _ready():
	active = true
	update_selection(0)
	create_freeplay()

	var menu_theme = "res://assets/music/MainMenu.ogg"

	if Main.game_mode == "freeplay":
		freeplay_node.force()
		active = false

	if Main.game_mode == "story":
		if story_node == null:
			create_story()
		menu_theme = "res://assets/music/StoryMenu.ogg"
		story_node.force()
		active = false

	if Conductor.cur_song != "menu_theme":
		var menu_stream = load(menu_theme)
		Conductor.play_song(menu_stream, 100)
		Conductor.cur_song = "menu_theme"
	else:
		var menu_stream = load(menu_theme)
		Conductor.transition_track(menu_stream, 1.5)


	Main.game_mode = "menu"

func _physics_process(delta):
	for i in options_node.get_child_count(false):
		camera.zoom = lerp(camera.zoom, Vector2(cam_zoom, cam_zoom), delta)
		var option = options_node.get_child(i)
		option.scale = lerp(option.scale, Vector2.ONE, delta * 4)
		var dissolve_value
		var alpha_value
		if i == cur_selected:
			dissolve_value = 1.0
			alpha_value = 0.0
		else:
			dissolve_value = 0.0
			alpha_value = 1.0

		var cur_mat = option.get_child(1).material
		cur_mat.set_shader_parameter("dissolve_value", lerp(cur_mat.get_shader_parameter("dissolve_value"), dissolve_value, 0.1))
		var shadow_mat = option.get_child(1).get_child(0).material
		shadow_mat.set_shader_parameter("dissolve_value", lerp(shadow_mat.get_shader_parameter("dissolve_value"), dissolve_value, 0.1))

		option.get_child(0).modulate.a = lerp(option.get_child(0).modulate.a, alpha_value, 0.1)

func _input(event):

	if active:

		if event.is_action_pressed("ui_left"):
			update_selection(-1)

		if event.is_action_pressed("ui_right"):
			update_selection(1)

		if event.is_action_pressed("confirm"):
			confirmSelection()

		if event.is_action_pressed("cancel"):
			active = false
			var sound_effect = load("res://assets/sounds/menu/menuCancel.ogg")
			sfx_player.stream = sound_effect
			sfx_player.play()
			Main.change_scene_transition("res://scenes/states/menus/title_screen/title_screen.tscn")


func update_selection(amt):


	if cur_selected + amt > options_node.get_child_count() - 1:
		return
	if cur_selected + amt < 0:
		return

	cur_selected += amt
	options_node.get_child(cur_selected).scale -= Vector2(0.1, 0.1)
	camera.global_position = options_node.get_child(cur_selected).global_position

	var sfx
	match amt:
		-1:
			sfx = load("res://assets/sounds/menu/menuClickUp.ogg")
		1:
			sfx = load("res://assets/sounds/menu/menuClickDown.ogg")
		0:
			return
	sfx_player.stream = sfx
	sfx_player.play()

func confirmSelection():

	match options_node.get_child(cur_selected).name:
		"freeplay":
			if freeplay_node == null:
				create_freeplay()
			freeplay_node.enter()
			cam_zoom = 0.7
			active = false

			var sfx = load("res://assets/sounds/menu/menuConfirm_4.ogg")
			sfx_player.stream = sfx
			sfx_player.play()

		"settings":
			create_settings()
			cam_zoom = 0.7
			active = false

			var sfx = load("res://assets/sounds/menu/menuConfirm_4.ogg")
			sfx_player.stream = sfx
			sfx_player.play()

		"credits":
			create_credits()
			cam_zoom = 0.9
			active = false

			var sfx = load("res://assets/sounds/menu/menuConfirm_4.ogg")
			sfx_player.stream = sfx
			sfx_player.play()
		_:
			var err = load("res://assets/sounds/menu/menuError.ogg")
			sfx_player.stream = err
			sfx_player.play()


	var t = create_tween()
	t.tween_property(options_node.get_child(cur_selected), "scale", Vector2(1.1, 0.9), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(options_node.get_child(cur_selected), "scale", Vector2(0.95, 1.05), 0.05).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(options_node.get_child(cur_selected), "scale", Vector2(1, 1), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func create_story():
	pass








func create_settings():
	var menu
	menu = SETTINGS_MENU.instantiate()
	menu.darkness = $darkness
	add_child(menu)

func create_credits():
	var menu
	menu = CREDITS_SCENE.instantiate()

	add_child(menu)

func create_freeplay():
	var menu
	menu = FREEPLAY_MENU.instantiate()
	menu.darkness = $darkness
	add_child(menu)
	freeplay_node = menu
