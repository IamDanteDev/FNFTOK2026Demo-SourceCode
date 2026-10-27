class_name ChartGenerator
extends Node


signal section_changed(data)


const NOTE_SCENE = preload("res://scenes/game/note/note.tscn")


var chart: ChartData

var current_section: Array


var registered_strums: = []

var notes: = []


func _process(_delta):

	if chart == null:
		return


	_get_section()


	if registered_strums.is_empty():
		return


	_get_notes()


func register_strum(strum_line: StrumLine, must_hit: bool = false):
	var data_array = [strum_line, must_hit]
	registered_strums.append(data_array)


func _get_section():
	if len(chart.sections) <= 0:
		return

	var next_section = chart.sections[0]
	if next_section[0] - Conductor.song_position <= 0:

		var section_bpm = next_section[2]

		if section_bpm != Conductor.bpm:
			Conductor.change_bpm(section_bpm)

		current_section = next_section

		section_changed.emit(next_section)

		chart.sections.remove_at(0)


func _get_notes() -> void :
	if len(chart.notes) <= 0:
		return

	var next_note = chart.notes[0]
	if next_note[0] - Conductor.song_position < (Conductor.step_crochet / chart.scroll_speed) * 24:
		_spawn_note(next_note)

		chart.notes.remove_at(0)

func _spawn_note(note_data):
	var strum_time = note_data[0]
	var note_type = note_data[1]
	var sustain_length = note_data[2]
	var note_value = ""
	if note_data.size() == 4:
		note_value = note_data[3]

	var note_must_hit = true
	if note_type >= chart.buttons:
		note_type -= chart.buttons
		note_must_hit = false

	if note_type < 0:
		return

	if note_type >= chart.buttons:
		return

	var strums = _get_strums(note_must_hit)
	if strums.is_empty():
		return

	for strum in strums:
		var button = strum.buttons[note_type]

		var scene = NOTE_SCENE.instantiate()

		scene.strum_time = strum_time
		scene.note_type = note_type
		scene.sustain_length = sustain_length
		scene.note_value = note_value

		scene.scroll_speed = chart.scroll_speed
		scene.must_hit = note_must_hit

		button.notes.add_child(scene)
		notes.append(scene)

func _get_strums(must_hit: bool):
	var strum_array: = []
	for strum_data in registered_strums:
		if strum_data[1] != must_hit:
			continue

		strum_array.append(strum_data[0])

	return strum_array
