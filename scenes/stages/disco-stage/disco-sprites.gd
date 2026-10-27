extends Node2D
@onready var stage: Stage = $".."

@onready var lights = $DiscoLight
@onready var dark = $darkness
@export var black: ColorRect
@onready var dark2: ColorRect = $darkness2

var lightAlpha
var do_bop = true
var do_bump = false
var do_flash = true

var attack_que: Array
var attack_int: int = 0

func _ready():

	Conductor.beat_changed.connect(_on_beat)

	if Main.game_mode != "editor":
		Conductor.song_position_updated.connect(_on_song_position_update)

	if Conductor.cur_song == "Disco Devil":
		for i in $toads.get_children():
			i.visible = false
			do_bop = false
		$bgcharacters.play("shock")

	if Conductor.cur_song == "Thrills at Night":

		$bgcharacters.visible = false
		black.visible = false
		dark2.visible = false


	if Main.game_mode == "editor":
		$"../CanvasLayer/black".visible = false
	await get_tree().create_timer(0.025).timeout
	stage.player_node.position.x += 100
	stage.gf_node.position.x += 100

func _process(delta):

	var song_pos = Conductor.song_position / 1000

	lights.rotation += 0.0005
	lights.modulate.a = lerp(lights.modulate.a, 0.1, 0.01)
	dark.modulate.a = lerp(dark.modulate.a, 0.4, 0.01)

func _on_song_position_update(pos, last_pos):




	if Conductor.cur_song == "MAX Power":
		if song_pos_check(3.0):
			var black_out = create_tween()
			black_out.tween_property(black, "modulate:a", 0, 2.5)
			await black_out.finished
			black.visible = false

		if song_pos_check(102.0):
			black.visible = true
			var black_in = create_tween()
			black_in.tween_property(black, "modulate:a", 1, 3.19)

		if song_pos_check(108.0):
			var black_out = create_tween()
			black_out.tween_property(black, "modulate:a", 0.2, 4.5)

		if song_pos_check(112.5):
			var black_out = create_tween()
			black_out.tween_property(black, "modulate:a", 0, 0.1)
			await black_out.finished
			black.visible = false

		if song_pos_check(152.0):
			var light_tween = create_tween()
			light_tween.tween_property(lights, "self_modulate:a", 0, 8)
			await light_tween.finished
			lights.visible = false
			do_flash = false




	if Conductor.cur_song == "Thrills at Night":

		if song_pos_check(0.0):
			var black_out = create_tween()
			black_out.tween_property(black, "modulate:a", 0, 2)
			await black_out.finished
			black.visible = false



	if Conductor.cur_song == "Disco Devil":
		var devil: Character = stage.enemy_character
		var beatTime = (Conductor.step_crochet / 1000) * 4

		if song_pos_check(0.0):
			for i in stage.combat_node.attack_windows:
				attack_que.append(i)
				attack_que.sort()


		if song_pos_check(0.0):
			var black_out = create_tween()
			black_out.tween_property(black, "modulate:a", 0, 0)
			await black_out.finished
			black.visible = false

		if song_pos_check(40.5):
			stage.enemy_character.do_bop = false
			stage.enemy_character.do_notes = false
			stage.enemy_character.play_animation("punch_in")
			await stage.enemy_character.animation_player.animation_finished
			stage.enemy_character.play_animation("punch_loop")
			var t1 = create_tween().set_parallel()
			t1.tween_property(dark2, "modulate:a", 0.4, beatTime / 1.5).from(0)
			t1.tween_property(stage.enemy_character.sprite, "position:x", 850.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			await get_tree().create_timer(0.5).timeout
			var t2 = create_tween().set_parallel()
			t2.tween_property(stage.player_character, "position:y", -200, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			t2.tween_property(stage.player_character, "rotation_degrees", -20, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

		if song_pos_check(41.74):
			stage.player_character.sprite.set_hole_punch(true)
			stage.player_character.play_animation("hurt")
			stage.enemy_character.play_animation("punch_impact")
			$Face.play()
			Event.screen_shake(30, 0.2)
			stage.playstate.hud.health_bar.set_holepunch(true)
			stage.playstate.stage.combat_node.hole_punched = true
			stage.playstate.health = 0.4
			await stage.enemy_character.animation_player.animation_finished
			stage.enemy_character.play_animation("punch_loop")
			var t = create_tween().set_parallel()
			t.tween_property(stage.enemy_character.sprite, "position:x", -215.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			t.tween_property(stage.player_character, "position:y", 0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
			t.tween_property(stage.player_character, "rotation_degrees", 0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)

		if song_pos_check(43.0):
			stage.enemy_character.play_animation("punch_out")
			stage.enemy_character.do_bop = true
			stage.enemy_character.do_notes = true

		if song_pos_check(43.48):
			var t1 = create_tween().set_parallel()
			t1.tween_property(dark2, "modulate:a", 0.0, beatTime / 1.5)



		if attack_que.size() > 0:

			if song_pos_check(attack_que[attack_int] - (beatTime), true):
				play_sfx("res://scenes/stages/disco-stage/sfx/atk_1.ogg", 0.75)

			if song_pos_check(attack_que[attack_int] - (beatTime)):
				devil.do_notes = false
				devil.do_bop = false
				devil.play_animation_over_time("attack_1", beatTime)
				var t1 = create_tween()
				t1.tween_property(dark2, "modulate:a", 0.4, beatTime / 1.5).from(0)



			if song_pos_check(attack_que[attack_int], true):
				play_sfx("res://scenes/stages/disco-stage/sfx/atk_2.ogg", 0.75)

			if song_pos_check(attack_que[attack_int]):
				if attack_int + 1 < attack_que.size() - 1:
					attack_int += 1

				devil.play_animation("attack_2")
				var t2 = create_tween()
				t2.tween_property(dark2, "modulate:a", 0, beatTime / 2)
				await devil.animation_player.animation_finished

				devil.do_notes = true
				devil.do_bop = true

func song_pos_check(time: float, audio: bool = false):
	var pos = Conductor.song_position / 1000
	var last_pos = Conductor.last_song_position / 1000
	var offset = 0.0

	if audio:
		offset -= (Settings.offset / 1000)
	if pos >= time + offset and last_pos <= time + offset:
		return true
	else: return false

func _on_beat(beat):
	if int(beat) % 2 != 0:
		if do_flash == true:
			lights.modulate.a += 0.2
			dark.modulate.a -= 0.1
		for i in $toads.get_children():
			if i is AnimatedSprite2D:
				i.play("DanceLeft")
	if do_bump == true:
		Event.camera_bump(0.03)

	if int(beat) % 2 == 0:
		if do_bop == true:
			$bgcharacters.play("idle")

		for i in $toads.get_children():
			if i is AnimatedSprite2D:
				i.play("DanceRight")

		$"DiscoFrontBop-1/AnimationPlayer".play("idle")


func play_sfx(path: String, volume: float = 0):
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	add_child(player)
	player.volume_linear = volume
	player.play()
	await player.finished
	player.queue_free()

func _on_bgcharacters_animation_finished():
	do_bop = true
