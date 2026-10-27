extends Node

var cam_pos: Vector2
var screen_pos: Vector2

var hud
var tween_array: Array
var active_zoom_tween: Tween
var active_x_tween: Tween
var active_y_tween: Tween
var active_angle_tween: Tween
var camera_target
var camera_scale = 100
var zoom_offset = 0
var base_zoom = 4
var camera
var stage
var camera_dict: Dictionary
var camera_events: Array

var randomStrength = 30.0
var shakeFade = 1.0
@onready var rng = RandomNumberGenerator.new()
var shake_strength = 0.0
var shake_offset = Vector2(0, 0)
var shake_tween

var bump_sequence: Array = []
var bump_step_rate: int = 0
var bump_tween

var next_attack: float
var attack_array = []


func _ready():
	Conductor.song_position_updated.connect(_on_song_position_update)

func _on_song_position_update(pos, last_pos):
	pos /= 1000
	last_pos /= 1000
	camera_check(pos, last_pos)

func screen_shake(strength, duration):
	if shake_tween is Tween:
		shake_tween.kill()
	shake_strength = strength
	var t = create_tween()
	t.tween_property(self, "shake_strength", 0, duration)
	shake_tween = t

func camera_bump(strength):
	if Main.game_mode != "menu" or Main.game_mode != "editor":
		if bump_tween is Tween:
			bump_tween.kill()
		var t = create_tween()
		t.tween_property(stage, "zoom_offset", strength, 0.025)

		bump_tween = t

func random_offset() -> Vector2:
	return Vector2(rng.randf_range( - shake_strength, shake_strength), rng.randf_range( - shake_strength, shake_strength))

func _physics_process(delta):

	if shake_strength > 0:
		shake_offset = Vector2(rng.randf_range( - shake_strength, shake_strength), rng.randf_range( - shake_strength, shake_strength))

func camera_pulse():
	zoom_offset += 0.05


func _on_song_start(pos):

	if active_angle_tween:
		active_angle_tween.kill()
	if active_x_tween:
		active_x_tween.kill()
	if active_y_tween:
		active_y_tween.kill()
	if active_zoom_tween:
		active_zoom_tween.kill()

	var base_dict = camera_dict.get("base_values", {})
	if base_dict.get("pos_x", "null") is not String:
		camera_target.position.x = base_dict.get("pos_x")
		camera.position.x = base_dict.get("pos_x")
	if base_dict.get("pos_y", "null") is not String:
		camera_target.position.y = base_dict.get("pos_y")
		camera.position.y = base_dict.get("pos_y")
	if base_dict.get("zoom", "null") is not String:
		var zoom = Vector2.ONE * (stage.camera_zoom.x * (base_dict.get("zoom") / 100))
		camera_target.zoom = zoom
		camera.zoom = zoom
		base_zoom = zoom

	if base_dict.get("angle", "null") is not String:
		camera_target.rotation_degrees = base_dict.get("angle")
		camera.rotation_degrees = base_dict.get("angle")

	var events_skipped = 0
	for i in camera_events:
		if i.get("time") <= pos:
			tween_camera(i, true)
			events_skipped += 1
		else:
			for n in events_skipped:
				camera_events.erase(camera_events[0])
			break

func camera_check(pos, last_pos):
	if camera_events.size() > 0:
		var time = camera_events[0].get("time")
		if pos >= time and last_pos <= time:
			tween_camera(camera_events[0])
			camera_events.erase(camera_events[0])

func tween_camera(event: Dictionary, instant = false):

	if Conductor.cur_song != "menu_theme":
		var pos_x = event.get("pos_x")
		var pos_y = event.get("pos_y")

		var from_pos_x = event.get("from_pos_x", "null")
		var from_pos_y = event.get("from_pos_y", "null")
		if from_pos_x is not String:
			stage.camera_target.position.x = from_pos_x

		if from_pos_y is not String:
			stage.camera_target.position.y = from_pos_y


		var zoom = event.get("zoom")
		if zoom is not String:
			camera_scale = zoom
			zoom = Vector2.ONE * (stage.camera_zoom.x * (zoom / 100))

		var from_zoom = event.get("from_zoom", "null")
		if from_zoom is not String:
			from_zoom = Vector2.ONE * (stage.camera_zoom.x * (from_zoom / 100))
			stage.camera_target.zoom = from_zoom

		var angle = event.get("angle")

		var from_angle = event.get("from_angle", "null")
		if from_angle is not String:
			stage.camera_target.rotation_degrees = from_angle

		var duration: float = (Conductor.step_crochet / 1000 * 4) * event.get("dur", 1)
		if instant: duration = 0.0

		var tweenease: Tween.EaseType = get_ease_type(event.get("ease"))
		var transition: Tween.TransitionType = get_transition_type(event.get("trans"))

		if zoom is not String:
			if active_zoom_tween:
				active_zoom_tween.pause()
				active_zoom_tween.kill()
			var tz = create_tween().set_parallel()
			if from_zoom is not String:
				tz.tween_property(stage.camera_target, "zoom", zoom, duration).set_ease(tweenease).set_trans(transition).from(from_zoom)
			else: tz.tween_property(stage.camera_target, "zoom", zoom, duration).set_ease(tweenease).set_trans(transition)
			active_zoom_tween = tz

		if pos_x is not String:
			if active_x_tween:
				active_x_tween.pause()
				active_x_tween.kill()
			var tx = create_tween().set_parallel()
			if from_pos_x is not String:
				tx.tween_property(stage.camera_target, "position:x", pos_x, duration).set_ease(tweenease).set_trans(transition).from(from_pos_x)
			else: tx.tween_property(stage.camera_target, "position:x", pos_x, duration).set_ease(tweenease).set_trans(transition)
			active_x_tween = tx

		if pos_y is not String:
			if active_y_tween:
				active_y_tween.pause()
				active_y_tween.kill()
			var ty = create_tween().set_parallel()
			if from_pos_y is not String:
				ty.tween_property(stage.camera_target, "position:y", pos_y, duration).set_ease(tweenease).set_trans(transition).from(from_pos_y)
			else: ty.tween_property(stage.camera_target, "position:y", pos_y, duration).set_ease(tweenease).set_trans(transition)
			active_y_tween = ty

		if angle is not String:
			if active_angle_tween:
				active_angle_tween.pause()
				active_angle_tween.kill()
			var ta = create_tween().set_parallel()
			if from_angle is not String:
				ta.tween_property(stage.camera_target, "rotation_degrees", angle, duration).set_ease(tweenease).set_trans(transition).from(from_angle)
			else: ta.tween_property(stage.camera_target, "rotation_degrees", angle, duration).set_ease(tweenease).set_trans(transition)
			active_angle_tween = ta

func get_ease_type(ease) -> Tween.EaseType:
	match ease:
		"in":
			return Tween.EASE_IN
		"out":
			return Tween.EASE_OUT
		"in_out":
			return Tween.EASE_IN_OUT
		"out_in":
			return Tween.EASE_OUT_IN
		_:
			return Tween.EASE_OUT
func get_transition_type(ease) -> Tween.TransitionType:
	match ease:
		"linear":
			return Tween.TRANS_LINEAR
		"sine":
			return Tween.TRANS_SINE
		"quint":
			return Tween.TRANS_QUINT
		"quart":
			return Tween.TRANS_QUART
		"quad":
			return Tween.TRANS_QUAD
		"expo":
			return Tween.TRANS_EXPO
		"elastic":
			return Tween.TRANS_ELASTIC
		"cubic":
			return Tween.TRANS_CUBIC
		"circ":
			return Tween.TRANS_CIRC
		"bounce":
			return Tween.TRANS_BOUNCE
		"back":
			return Tween.TRANS_BACK
		"spring":
			return Tween.TRANS_SPRING
		_:
			return Tween.TRANS_LINEAR
