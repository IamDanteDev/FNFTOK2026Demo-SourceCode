class_name StrumButton
extends Node2D








signal pressed(whiffed)

signal released()

signal note_hit(note)

signal held_hit(note)
signal note_held(note)

signal note_missed(note)

const COVER_SCENE = preload("res://scenes/game/note_cover/note_cover.tscn")


@export var note_type: int = 0:
	set = _set_note_type


@export var action: String = ""


@export var frame: int = 0:
	set = _set_frame


@export var bot: bool = false


var offset: float = 0.0:
	set = _set_offset

var offset_lerp: float = 0.0:
	set = _set_offset_lerp


var scroll_multi: float = 1.0:
	set = _set_scroll_multi

var showcase = Settings.showcase



@onready var notes: Node2D = $Notes

@onready var sprite: Sprite2D = $notes_player
@onready var other_sprite = "res://assets/sprites/game/notes/strum_line_2.png"
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var tape_line: AnimatedSprite2D = $tape
@export var right_strum_taped: bool = false
@export var up_strum_taped: bool = false
@export var left_strum_taped: bool = false
@export var down_strum_taped: bool = false


func _ready():

	notes.child_entered_tree.connect(_on_note_added)


	_update_sprite()


	tape_line.visible = false
	tape_line.frame = 0

func _unhandled_input(event):

	if bot or showcase:
		return


	if InputMap.has_action(action):

		if event.is_action_pressed(action):
			if up_strum_taped || left_strum_taped || down_strum_taped || right_strum_taped:
				pass
			else:
				animation_player.play("press")


			var hittable_notes = get_hittable_notes()


			if not hittable_notes.is_empty():
				var note = hittable_notes.pop_front()

				if up_strum_taped || left_strum_taped || down_strum_taped || right_strum_taped:
					pass
				else:
					note.hit_note()

				for extra_note in hittable_notes:
					extra_note.queue_free()

				pressed.emit(false)
			else:
				pressed.emit(true)


		if event.is_action_released(action):
			animation_player.play("idle")

			released.emit()


func get_hittable_notes(first_strum_time = null, ignore_missed = false):
	var hittable_notes = []


	var time_offset = 5

	if notes.get_child_count() > 0:
		for note in notes.get_children():
			if not ignore_missed:

				if note.missed:
					continue


				if not note.can_be_hit():
					continue

			if first_strum_time == null:
				first_strum_time = note.strum_time
			elif note.strum_time > first_strum_time + time_offset:
				break

			hittable_notes.append(note)

	if not hittable_notes.is_empty():
		hittable_notes.sort_custom( func(a, b):
			return a.sustain_length > b.sustain_length
		)

	return hittable_notes


func _on_note_added(note):
	note.offset = offset
	note.scroll_multi = scroll_multi


	note.note_hit.connect(_on_note_hit.bind(note))
	note.note_missed.connect(_on_note_missed.bind(note))

	note.note_reached.connect(_on_note_reached.bind(note))
	note.note_held.connect(_on_note_held.bind(note))
	note.held_hit.connect(_on_held_hit.bind(note))


	released.connect(note.release_sustain)

func _on_note_hit(note):

	note_hit.emit(note)



	if bot or showcase:
		animation_player.animation_set_next("hit", "idle")


	animation_player.stop(true)
	animation_player.play("hit")

	match note.note_value:
		"Hurt Note":
			tape_line.visible = true
			tape_line.play("default")
			do_tape_note_stuff();
		_:
			pass

func do_tape_note_stuff():
	match note_type:
		0:
			right_strum_taped = true
			await get_tree().create_timer(1).timeout
			tape_line.play_backwards("default")
			await get_tree().create_timer(0.3636).timeout
			right_strum_taped = false
			tape_line.visible = false
		1:
			up_strum_taped = true
			await get_tree().create_timer(1).timeout
			tape_line.play_backwards("default")
			await get_tree().create_timer(0.3636).timeout
			up_strum_taped = false
			tape_line.visible = false
		2:
			left_strum_taped = true
			await get_tree().create_timer(1).timeout
			tape_line.play_backwards("default")
			await get_tree().create_timer(0.3636).timeout
			left_strum_taped = false
			tape_line.visible = false
		3:
			down_strum_taped = true
			await get_tree().create_timer(1).timeout
			tape_line.play_backwards("default")
			await get_tree().create_timer(0.3636).timeout
			down_strum_taped = false
			tape_line.visible = false

func _on_note_missed(note):
	if !bot:
		note_missed.emit(note)

func _on_note_reached(note):


	if bot or showcase:
		if !note.missable_bot:
			note.hit_note()

func _on_note_held(_note):

	if animation_player.current_animation_position >= Conductor.step_crochet / 1000:
		animation_player.stop(true)
		animation_player.play("hit")

func _on_held_hit(note):
	held_hit.emit(note)


func _update_sprite():
	if sprite == null:
		return


	var frame_offset = sprite.hframes * note_type


	var max_frames = sprite.hframes * sprite.vframes
	if frame + frame_offset >= max_frames:
		return


	sprite.frame = frame + frame_offset


func _set_frame(value):
	frame = value
	_update_sprite()

func _set_note_type(value):
	note_type = value
	_update_sprite()

func _set_offset(value):
	offset = value

	for note in notes.get_children():
		note.offset = offset

func _set_offset_lerp(value):
	offset_lerp = value

	for note in notes.get_children():
		note.offset_lerp = offset_lerp

func _set_scroll_multi(value):
	scroll_multi = value

	for note in notes.get_children():
		note.scroll_multi = scroll_multi
