extends CanvasLayer

var active = false
var can_swap = true
var can_quit = false

@export var tab_holder: Node2D
@export var storytab: AnimatedSprite2D
@export var extratab: AnimatedSprite2D
@export var bg_holder: Node2D
@export var stage: Sprite2D
@export var portrait_holder: Node2D
@export var portrait: Sprite2D
@export var portrait_shadow: Sprite2D
var portrait_offsets: Dictionary
var current_portrait: String

var active_tab: AnimatedSprite2D
var inactive_tab: AnimatedSprite2D
var inactive_clone

var difficulties = ["normal", "hard", "harder"]
var difficulty = 1

var swap_tween
var bookmark_tween

var time = 0.0
var darkness

func _ready() -> void :
	visible = false
	storytab.menu = self
	extratab.menu = self

	portrait_holder.modulate.a = 0

	var path = "res://cutscenes/portait_offsets.json"
	portrait_offsets = Weeks.load_json_file(path)

	active_tab = tab_holder.find_child(Main.Active_Freeplay_Tab)
	active_tab.z_index = 10
	active_tab.active = false
	active_tab.position.x = 0

	inactive_tab = tab_holder.find_child(Main.Inactive_Freeplay_Tab)
	inactive_tab.z_index = 1
	inactive_tab.active = false
	inactive_tab.position.x = 30

	for tab in [inactive_tab, active_tab]:
		match tab:
			storytab:
				tab.updateCurSelected(0, Main.Last_Story_Freeplay_Option)
			extratab:
				tab.updateCurSelected(0, Main.Last_Extra_Freeplay_Option)

func enter():
	can_swap = false
	tab_holder.modulate.a = 0
	bg_holder.modulate.a = 0

	visible = true


	var t = create_tween().set_parallel()
	var d = 0.8

	t.tween_property(tab_holder, "modulate:a", 1, 0).from(0)
	t.tween_property(portrait_holder, "modulate:a", 1, 0).from(0)
	t.tween_property(darkness, "modulate:a", 0.5, d).from(0)

	t.tween_property(active_tab, "position:x", 0, d).from(-1030.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(inactive_tab, "position:x", 30, d * 1.1).from(-1030.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(portrait_holder, "position:x", 1144.0, d).from(1744.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(active_tab.panel, "position:y", -500.0, d * 1.2).from(-800).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(active_tab.skin_panel, "position:y", 551.0, d * 1.2).from(800).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(active_tab.skin_selection, "position:y", 556.864, d * 1.2).from(800).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


	await get_tree().create_timer(0.1).timeout

	create_tween().tween_property(bg_holder, "modulate:a", 1, d / 1.5).from(0)

	if bookmark_tween: bookmark_tween.kill()
	$tabs / bookmark2.z_index = 3
	var bt2 = create_tween()
	bt2.tween_property($tabs / bookmark2, "position:x", 600, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	bookmark_tween = bt2

	await get_tree().create_timer(0.35).timeout

	active = true
	can_swap = true
	can_quit = true



	active_tab.active = true

func force():
	visible = true
	active = true
	can_quit = true
	storytab.menu = self
	extratab.menu = self
	portrait_holder.modulate.a = 1

	$tabs / bookmark2.position.x = 600

	active_tab = tab_holder.find_child(Main.Active_Freeplay_Tab)
	active_tab.z_index = 10
	active_tab.active = true
	active_tab.position.x = 0

	inactive_tab = tab_holder.find_child(Main.Inactive_Freeplay_Tab)
	inactive_tab.z_index = 1
	inactive_tab.active = false
	inactive_tab.position.x = 30

	for tab in [inactive_tab, active_tab]:
		match tab:
			storytab:
				tab.updateCurSelected(0, Main.Last_Story_Freeplay_Option)
			extratab:
				tab.updateCurSelected(0, Main.Last_Extra_Freeplay_Option)

	for i in [active_tab, inactive_tab]:
		i.option_container.position.y = i.target_y

func _input(event):
	if active:
		if active_tab.selecting_skin == false:
			if can_swap:
				if event.is_action_pressed("tab"):
					return
					var sfx = load("res://assets/sounds/menu/menuPageDown.ogg")
					play_sound(sfx)
					swap_tabs()
			if can_quit:
				if event.is_action_pressed("cancel"):
					var sfx = load("res://assets/sounds/menu/menuCancel.ogg")
					play_sound(sfx)
					exit()

			if event.is_action_pressed("ui_left"):
				update_difficulty(-1)
			if event.is_action_pressed("ui_right"):
				update_difficulty(1)
		else:
			if event.is_action_pressed("ui_left"):

				pass
			if event.is_action_pressed("ui_right"):

				pass

func update_difficulty(amt):
	difficulty += amt
	if difficulty >= 3: difficulty = 0
	if difficulty <= -1: difficulty = 3
	difficulty = clamp(difficulty, 0, 2)

	for tab in [active_tab, inactive_tab]:
		tab.update_difficulty_sprites(difficulty)
		tab.update_stats(difficulties[difficulty])


	var sfx1 = load("res://assets/sounds/menu/menuClick.ogg")
	play_sound(sfx1)

	match difficulty:
		0:
			var sfx2 = load("res://assets/sounds/menu/stomp.ogg")
			play_sound(sfx2, 0.02, -5)
		1:
			var sfx2 = load("res://assets/sounds/menu/kick.ogg")
			play_sound(sfx2, 0.02, -5)
		2:
			var sfx2 = load("res://assets/sounds/menu/bump.ogg")
			play_sound(sfx2, 0.02, -5)

	var diff_sprite = active_tab.difficulty_sprites[difficulty]
	var t = create_tween().set_parallel()
	t.tween_property(diff_sprite, "scale", Vector2(0.9, 0.9), 0.2).from(Vector2(1, 0.8)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(diff_sprite, "modulate:v", 1, 0.1).from(1.5)



func _process(delta: float) -> void :
	time += delta
	bg_holder.position.x -= cos(time) * 0.03
	portrait_holder.position.x -= cos(time) * 0.075

func swap_tabs():

	can_swap = false
	active = false
	can_quit = false

	$tabs / bookmark2.z_index = 1
	if bookmark_tween: bookmark_tween.kill()
	var bt = create_tween()
	bt.tween_property($tabs / bookmark2, "position:x", 350.0, 0.5).from(600).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	bookmark_tween = bt

	if inactive_clone != null:
		inactive_clone.queue_free()
	inactive_clone = Sprite2D.new()
	inactive_clone.texture = inactive_tab.sprite_frames.get_frame_texture(inactive_tab.id, 0)
	inactive_clone.transform = inactive_tab.transform
	inactive_clone.z_index = 0
	var frame_clone = Sprite2D.new()
	frame_clone.texture = inactive_tab.tabframe.sprite_frames.get_frame_texture(inactive_tab.id, 0)
	frame_clone.transform = inactive_tab.tabframe.transform

	tab_holder.add_child(inactive_clone)
	inactive_clone.add_child(frame_clone)

	if active_tab == storytab:
		active_tab = extratab
		inactive_tab = storytab
	elif active_tab == extratab:
		active_tab = storytab
		inactive_tab = extratab

	active_tab.z_index = 3
	active_tab.active = true
	active_tab.position.x = 0
	active_tab.option_array[active_tab.cur_selected].selected = true
	active_tab.option_array[active_tab.cur_selected].anim.play("1")
	inactive_tab.z_index = 1
	inactive_tab.active = false
	inactive_tab.position.x = 30
	inactive_tab.option_array[inactive_tab.cur_selected].selected = false
	inactive_tab.option_array[inactive_tab.cur_selected].anim.play("0")

	Main.Active_Freeplay_Tab = active_tab.name
	Main.Inactive_Freeplay_Tab = inactive_tab.name

	_update_stage(active_tab.option_array[active_tab.cur_selected].bg_sprite, false)
	_update_portrait(active_tab.option_array[active_tab.cur_selected].chart.char_enemy, false)

	var duration = 0.6

	if swap_tween != null: swap_tween.kill()
	var t = create_tween().set_parallel()
	swap_tween = t
	t.tween_property(active_tab, "position:x", 0, duration).from(-1020.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(inactive_tab, "position:x", 30, duration).from(0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(inactive_clone, "modulate:a", 0, duration)
	if inactive_clone != null:
		t.chain().tween_callback(inactive_clone.queue_free)

	await get_tree().create_timer(0.3).timeout
	active = true
	await get_tree().create_timer(0.3).timeout


	$tabs / bookmark2.animation = active_tab.name.trim_suffix("tab")

	if bookmark_tween: bookmark_tween.kill()
	$tabs / bookmark2.z_index = 3
	var bt2 = create_tween()
	bt2.tween_property($tabs / bookmark2, "position:x", 600, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	bookmark_tween = bt2

	can_quit = true
	can_swap = true

func _update_stage(stage_bg, forced: bool):
	if stage.texture != stage_bg:

		var newstage = stage.duplicate()
		newstage.z_index = 0
		bg_holder.add_child(newstage)
		bg_holder.move_child(newstage, 0)

		stage.texture = stage_bg
		stage.scale = Vector2.ONE / (stage.texture.get_height() / 720.0)
		stage.position.x = (stage.texture.get_width() * stage.scale.x) / 2

		var duration = 1
		if forced: duration = 0

		var ta = create_tween()
		ta.tween_property(newstage, "modulate:a", 0, duration).from(1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		await ta.finished
		newstage.queue_free()

	else: print("Woah that works")

func _update_portrait(character, forced: bool):

	if character != current_portrait:

		var fake_portrait = portrait_holder.duplicate()
		portrait_holder.add_sibling(fake_portrait)
		portrait_holder.move_to_front()





		current_portrait = character
		var path = "res://scenes/game/character/" + str(character) + "/portrait.png"
		portrait.texture = load(path)
		portrait_shadow.texture = load(path)

		var values: Dictionary = portrait_offsets.get(character, portrait_offsets.get("null"))
		var pos = Vector2(values.get("pos")[0], values.get("pos")[1])
		portrait.position = pos
		portrait.rotation_degrees = values.get("rot")
		portrait.scale = Vector2.ONE * values.get("size")

		var d = 0.5
		if forced: d = 0
		var t = create_tween().set_parallel()
		t.tween_property(portrait_holder, "position:x", 1144.0, d).from(500).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		t.tween_property(portrait_holder, "rotation_degrees", 0, d).from(50).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		t.tween_property(portrait_holder, "position:y", 360.0, d).from(500).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		t.tween_property(portrait_holder, "scale", Vector2.ONE, d).from(Vector2.ONE * 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

		t.tween_property(fake_portrait, "position:x", 1700, d).from(1144).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		t.tween_property(fake_portrait, "scale", Vector2.ONE * 0.75, d).from(Vector2.ONE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		t.tween_property(fake_portrait, "rotation_degrees", -20, d).from(0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

		await t.finished
		fake_portrait.queue_free()


func exit():
	active = false
	active_tab.active = false

	var t = create_tween().set_parallel()
	var d = 0.4

	if bookmark_tween: bookmark_tween.kill()
	t.tween_property(active_tab, "position:x", -1030, d).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(inactive_tab, "position:x", -1030, d).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property($tabs / bookmark2, "position:x", -670, d * 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(portrait_holder, "position:x", 1744.0, d).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(active_tab.panel, "position:y", -800.0, d * 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(darkness, "modulate:a", 0, 0.8)
	t.tween_property(bg_holder, "modulate:a", 0, d / 4)
	get_parent().cam_zoom = 0.76
	await get_tree().create_timer(0.3).timeout

	get_parent().active = true


func play_sound(sfx, variance: float = 0.0, volume = 0.0):
	var player = AudioStreamPlayer.new()
	player.stream = sfx
	player.pitch_scale = randf_range(1 - variance, 1 + variance)
	player.volume_db = volume
	add_child(player)
	player.play()
	await player.finished

	player.queue_free()
