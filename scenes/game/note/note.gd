class_name Note
extends Node2D






const COVER_SCENE = preload("res://scenes/game/note_cover/note_cover.tscn")


signal note_hit()

signal note_held()

signal held_hit()

signal note_missed()


signal note_reached()


var default_noteskin = preload("res://scenes/game/note/note_skins/default_noteskin.tscn")
var hurt_noteskin = preload("res://scenes/game/note/note_skins/hurt_noteskin.tscn")



var sustain_color: Color = Color(1, 1, 1, 1)


var sustain_seperation: float = 50

var cover


var hit_timings: Dictionary = {
	"shit": [180, 50, 0], 
	"bad": [135, 100, 0.4], 
	"good": [90, 200, 0.7], 
	"sick": [45, 350, 1], 
}



var strum_time: float

var note_type: int

var note_value

var sustain_length: float

var health_on_hit: float = 0.03
var health_on_miss: float = -0.1


var scroll_speed: float

var must_hit: bool



var reached: bool

var missed: bool

var been_hit: bool

var missable: bool = false

var missable_bot: bool = false


var held: bool

var held_timing: float

var been_held: bool



var _move: bool = true

var _fake_pos: float

var _forced_pos = null


var offset: float = 0.0
var offset_lerp: float = 0.0

var scroll_multi: float = 1.0


var _sprite


func _ready():
	setup_noteskin()
	_sprite = get_child(0)

	match note_value:
		"":
			pass
		"Hurt Note":

			missable = true
			missable_bot = true


		"Tape Note":

			missable = true
			missable_bot = true
			health_on_hit = -0.0475



	_fake_pos = get_song_position()
	_update_note_position()


	_sprite.anim.play(str(note_type))

func _process(delta):
	_update_fake_pos(delta)

	if not held:
		_update_note_position()
		_update_note_state(delta)

	_update_note_sustain(delta)
	_update_note_visuals()

func _draw():
	_draw_note_sustain()




func hit_note():
	if sustain_length <= 0:
		queue_free()
	else:
		held = true
		held_timing = get_timing()

	note_hit.emit()
	been_hit = true


func missed_note():
	if !missable:
		missed = true
		note_missed.emit()


func release_sustain():
	if not held:
		return

	held = false
	been_held = true

	if cover != null:

		missed_note()

	strum_time = get_song_position() + held_timing
	_fake_pos = get_song_position()

	if sustain_length <= Conductor.step_crochet:
		queue_free()



func can_be_hit():
	var timing = get_timing()
	var max_timing = get_max_timing()

	return (timing < max_timing and timing > - max_timing)


func get_song_position():
	if _forced_pos != null:
		return _forced_pos

	return Conductor.song_position + offset_lerp

func set_forced_position(pos):
	_forced_pos = pos
	_update_fake_pos(0)


func get_max_timing():
	return hit_timings[hit_timings.keys().front()][0]

func get_min_timing():
	return hit_timings[hit_timings.keys().back()][0]


func get_timing():
	return get_to_strum_time()

func get_to_strum_time():
	return strum_time - _fake_pos

func get_real_to_strum_time():
	return strum_time - get_song_position()


func get_rating():
	var timing = get_timing()

	var ratings = hit_timings.keys()
	var chosen_rating = ratings[ratings.size() - 1]

	for rating in ratings:
		var max_timing = 0
		if ratings.find(rating) + 1 < ratings.size():
			max_timing = hit_timings[ratings[ratings.find(rating) + 1]][0]

		if abs(timing) < max_timing:
			continue
		else:
			chosen_rating = rating
			break

	return chosen_rating


func _get_scroll_speed():
	return scroll_speed / global_scale.y


func _update_fake_pos(delta):
	_fake_pos += delta * 1000

	if abs(get_song_position() - _fake_pos) >= 100:
		_fake_pos = get_song_position()

	if _forced_pos != null:
		_fake_pos = _forced_pos

func _update_note_position():
	if not _move:
		return

	position.y = (get_to_strum_time() * _get_scroll_speed()) * scroll_multi

func _update_note_state(delta):

	if not reached and get_timing() <= 0:
		reached = true
		note_reached.emit()


	if not missed:
		if get_timing() < - get_max_timing():
			missed_note()


	if get_timing() < - get_max_timing() * 2:
		if sustain_length > 0:
			_move = false
			sustain_length -= delta * 1000

			queue_redraw()
		else:
			queue_free()

func _update_note_sustain(delta):
	if held:


		if cover == null:
			cover = COVER_SCENE.instantiate()
			cover._set_note_type(note_type)
			cover.position.y *= scroll_multi
			cover.scale.y *= scroll_multi
			add_child(cover)


		if not been_held or held_timing >= 0:
			position.y = 0

		_sprite.visible = false

		var sustain_change = delta * 1000
		sustain_length -= sustain_change

		queue_redraw()

		if sustain_length <= 0:
			held_hit.emit()
			queue_free()

		note_held.emit()

func _update_note_visuals():
	if missed:
		modulate.a = 0.3

func _draw_note_sustain():
	if sustain_length <= 0:
		return

	var color = sustain_color


	var texture_size = _sprite.sustain_texture.get_size()
	var size = Vector2(texture_size.x / 2, texture_size.y / 4)


	var sustain_height_real = (sustain_length * _get_scroll_speed()) / sustain_seperation
	var sustain_height = floor(sustain_height_real)
	var sustain_remainder = sustain_height_real - sustain_height


	for sustain_part in sustain_height + 1:
		var part_size = Vector2(size.x, sustain_seperation)

		var rect = Rect2(Vector2( - size.x / 2, sustain_part * sustain_seperation), part_size)
		var src_rect = Rect2(Vector2(0, size.y * note_type), part_size)

		rect.position.y *= scroll_multi
		rect.size.y *= scroll_multi
		if scroll_multi < 0:
			rect.position.y -= part_size.y


		if sustain_part == sustain_height:
			src_rect.size.y = size.y
			src_rect.position.x = size.x



		if sustain_part == 0:
			rect.size.y *= sustain_remainder

		if (scroll_multi > 0 and not sustain_part == 0) or (scroll_multi < 0):
			var strum_offset = part_size.y * sustain_remainder
			rect.position.y -= (part_size.y - strum_offset) * scroll_multi


		draw_texture_rect_region(
			_sprite.sustain_texture, rect, src_rect, color
		)

func setup_noteskin():

	var note_skin
	if str(note_value) == "Hurt Note" or str(note_value) == "Tape Note":
		note_skin = hurt_noteskin
	else:
		note_skin = default_noteskin

	var note_inst = note_skin.instantiate()
	add_child(note_inst)
