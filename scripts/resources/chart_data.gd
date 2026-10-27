class_name ChartData
extends Resource







var buttons: int = 4



var load_note_data: bool = true



var file_path: String
var song_path: String



var song_name: String

var file_name: String


var bpm: float

var scroll_speed: float

var use_voices: bool



var char_player: String

var char_enemy: String

var char_gf: String


var stage: String



var sections: Array

var notes: Array



func load_json(json_file_path: String):
	json_file_path = json_file_path.simplify_path()

	var file = FileAccess.open(json_file_path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()

	var json = JSON.new()
	var json_error = json.parse(file.get_as_text())
	if json_error != OK:
		return json_error

	file_path = json_file_path
	song_path = json_file_path.rsplit("/", true, 1)[0] + "/"
	file_name = song_path.rsplit("/", true)[4]
	return load_chart(json.data)



func load_chart(data: Dictionary):
	var song_data: Dictionary = data.get("song", {})


	song_name = song_data.get("song", "NO SONG NAME SPECIFIED")
	bpm = song_data.get("bpm", 100)
	use_voices = song_data.get("needsVoices", false)

	char_player = song_data.get("player1", "bf")
	char_enemy = song_data.get("player2", "bf")
	char_gf = song_data.get("gfVersion", "gf")

	stage = song_data.get("stage", "stage")

	scroll_speed = song_data.get("speed", 0.5)
	scroll_speed *= 0.45


	if load_note_data:
		var section_data = song_data.get("notes", [])

		var cur_bpm: = bpm
		var cur_section_time: = 0.0
		for section in section_data:
			var must_hit = section.get("mustHitSection", false)

			var section_bpm = section.get("bpm", null)
			var bpm_change = section.get("changeBPM", false)
			var section_notes = section.get("sectionNotes", [])

			if section_bpm == null:
				section_bpm = bpm
			if bpm_change:
				cur_bpm = section_bpm

			var new_section = [cur_section_time, must_hit, cur_bpm, section_notes]
			cur_section_time += (((60 / cur_bpm) / 4) * 16) * 1000

			for note in section.get("sectionNotes"):
				var note_type = note[1]


				if note_type == -1:
					continue



				if not must_hit:
					if note_type < buttons:
						note_type += buttons
					else:
						note_type -= buttons

				note[1] = note_type
				notes.append(note)

			sections.append(new_section)


		notes.sort_custom(
			func(a, b): return a[0] < b[0]
		)

	return OK
