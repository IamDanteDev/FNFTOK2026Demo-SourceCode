extends Node2D

const BROKEN_PENCIL = preload("res://scenes/stages/missle-stage/sprites/missile/broken_pencil.tscn")

@onready var balloon1 = $Balloon1
@onready var balloon2 = $Balloon2
@onready var balloon3 = $Balloon3
@onready var balloon4 = $Balloon4
@onready var balloon5 = $Balloon5

@onready var stage = $".."



@onready var pre_boo = preload("res://scenes/stages/missle-stage/boo.tscn")

var move_a = 0.35
var move_b = 0.55

var time = 0
var attack_duration = 0

var move_1 = randf_range(move_a, move_b)
var move_2 = randf_range(move_a, move_b)
var move_3 = randf_range(move_a, move_b)
var move_4 = randf_range(move_a, move_b)
var move_5 = randf_range(move_a, move_b)

var movement = 0.3

var attack_tween: Tween

var attack_que: Array
var attack_int: int = 0
var attack_sound_int: int = 0

var player_strum
var enemy_strum
var health_bar
var time_bar
var info_bar

var hud_elements = []

func _ready():
	Conductor.step_changed.connect(_on_step)
	if Main.game_mode != "editor":
		Conductor.song_position_updated.connect(_on_song_position_update)
		$Reticle.visible = false

		player_strum = Event.hud.player_strum
		enemy_strum = Event.hud.enemy_strum
		health_bar = Event.hud.health_bar
		time_bar = Event.hud.time_bar
		info_bar = Event.hud.info_bar_container

		hud_elements = [player_strum, enemy_strum, health_bar, time_bar, info_bar]

		player_strum.modulate.a = 0
		enemy_strum.modulate.a = 0
		health_bar.modulate.a = 0
		time_bar.modulate.a = 0
		info_bar.modulate.a = 0

func _process(delta):

	time += delta

	if attack_duration > 0:
		attack_duration -= 0.01

	stage.enemy_character.position.y -= cos(time * 2) / 2
	stage.enemy_character.rotation += deg_to_rad(cos(time * 4) / 20)
	stage.enemy_character.position.x += cos(time * 4 + 2) / 2
	stage.enemy_character.position.x += ((sin(time * 50) * 5) * attack_duration)

	balloon1.global_position.x -= move_1
	balloon2.global_position.x -= move_2
	balloon3.global_position.x -= move_3
	balloon4.global_position.x -= move_4
	balloon5.global_position.x -= move_5

	check_balloons()

func check_balloons():
	if balloon1.global_position.x < -1719:
		balloon1.global_position.x = randi_range(1605, 1620)
		balloon1.global_position.y = randi_range(-274, -596)
		move_1 = randf_range(move_a, move_b)

	if balloon2.global_position.x < -1719:
		balloon2.global_position.x = randi_range(1605, 1620)
		balloon2.global_position.y = randi_range(-274, -596)
		move_2 = randf_range(move_a, move_b)

	if balloon3.global_position.x < -1719:
		balloon3.global_position.x = randi_range(1605, 1620)
		balloon3.global_position.y = randi_range(-274, -596)
		move_3 = randf_range(move_a, move_b)

	if balloon4.global_position.x < -1719:
		balloon4.global_position.x = randi_range(1605, 1620)
		balloon4.global_position.y = randi_range(-274, -596)
		move_4 = randf_range(move_a, move_b)

	if balloon5.global_position.x < -1719:
		balloon5.global_position.x = randi_range(1605, 1620)
		balloon5.global_position.y = randi_range(-274, -596)
		move_5 = randf_range(move_a, move_b)

func _on_song_position_update(_pos, _last_pos):
	var beatTime = (Conductor.step_crochet / 1000) * 4
	if song_pos_check(0.0):
		for i in stage.combat_node.attack_windows:
			attack_que.append(i)
			attack_que.sort()

	if song_pos_check(1.71):
		for i in [enemy_strum, player_strum]:
			var t = create_tween()
			t.tween_property(i, "modulate:a", 1, beatTime * 4)

	if song_pos_check(15.43):
		for i in hud_elements:
			i.modulate.a = 1

	if attack_que.size() > 0:

		if song_pos_check(attack_que[attack_sound_int] - beatTime * 2, true):
			play_sfx("res://scenes/stages/missle-stage/sprites/missile/sfx/pencils_explosion.ogg", 0.5)
			if attack_sound_int + 1 < attack_que.size():
				attack_sound_int += 1


		if song_pos_check(attack_que[attack_int] - (beatTime * 3)):
			if attack_int + 1 < attack_que.size():
				attack_int += 1
			$Reticle.visible = true
			var new_pencil = $pencils.duplicate()
			add_child(new_pencil)
			new_pencil.position.x = randf_range(-1831.0, 500.0)
			new_pencil.look_at($Reticle.global_position)
			var t = create_tween()
			t.tween_property(new_pencil, "position", $Reticle.position, beatTime * 3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
			await t.finished
			new_pencil.queue_free()
			$Reticle.visible = false




			var new_explosion: AnimatedSprite2D = $explosion.duplicate()
			add_child(new_explosion)
			new_explosion.play("default")
			Event.screen_shake(30, 0.2)
			await new_explosion.animation_finished
			new_explosion.queue_free()


func _on_step(step):
	if Conductor.cur_song == "Missile Maestro":
		match int(step):

			0:
				pencil_mechanic()
			256:
				pencil_mechanic()
			428:
				pencil_mechanic()
			592:
				pencil_mechanic()
			684:
				pencil_mechanic()
			792:
				pencil_mechanic()
			944:
				pencil_mechanic()

func pencil_mechanic():
	if Main.game_mode == "freeplay" or Main.game_mode == "story":
		attack_duration = 2
		stage.enemy_character.play_animation("attack")
		$AudioStreamPlayer.play()


		Event.screen_shake(10, 0.2)

		await get_tree().create_timer(0.3333).timeout

		Event.screen_shake(8, 1)

		for b in randi_range(10, 9):
			var boo = pre_boo.instantiate()
			Event.hud.add_child(boo)
			boo.position = Vector2(-750, 0)
			boo.z_index = 1
			boo.scale = Vector2(0.8, 0.8)
			boo.speed = randi_range(4, 8)
			boo.delay = randi_range(50, 400)
			boo.global_position.y += randi_range(-250, -150)

		for b in randi_range(8, 10):
			var boo = pre_boo.instantiate()
			Event.hud.add_child(boo)
			boo.position = Vector2(-750, 0)
			boo.z_index = -1
			boo.modulate = Color8(225, 225, 255)
			boo.scale = Vector2(0.65, 0.65)
			boo.speed = randi_range(4, 8)
			boo.delay = randi_range(50, 400)
			boo.global_position.y += randi_range(-250, -150)

func song_pos_check(time: float, audio: bool = false):
	var pos = Conductor.song_position / 1000
	var last_pos = Conductor.last_song_position / 1000
	var offset = 0.0

	if audio:
		offset -= (Settings.offset / 1000)
	if pos >= time + offset and last_pos <= time + offset:
		return true
	else: return false

func play_sfx(path: String, volume: float = 0):
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	add_child(player)
	player.volume_linear = volume
	player.play()
	await player.finished
	player.queue_free()
