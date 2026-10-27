extends Node

const SAVE_DATA = "user://save_data.save"
var song_list = []
var data_array = []
var song_miss_data = {}
var song_rating_data = {}
var song_score_data = {}
var song_combat_data = {}
var toad_data = {}
var coin_total: int
var flags = {
	"title_screen_viewed": false, 
	"ch1_complete": false, 
	"ch2_complete": false, 
	"ch3_complete": false, 
	"ch4_complete": false, 
	"ch5_complete": false, 
	"ch5.5_complete": false, 
	"ch6_complete": false, 
	"ch1_unlock": true, 
	"ch2_unlock": false, 
	"ch3_unlock": false, 
	"ch4_unlock": false, 
	"ch5_unlock": false, 
	"ch5.5_unlock": false, 
	"ch6_unlock": false
}
const diff = ["normal", "hard", "harder"]

func _ready():
	if !FileAccess.file_exists(SAVE_DATA):
		var file = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
		get_all_songs()
		for songs in song_list.size():
			song_miss_data[song_list[songs]] = 0
			song_rating_data[song_list[songs]] = 0.0
			song_score_data[song_list[songs]] = 0
			song_combat_data[song_list[songs]] = 0.0
		data_array.append(song_miss_data)
		data_array.append(song_rating_data)
		data_array.append(song_score_data)
		data_array.append(song_combat_data)
		coin_total = 0
		data_array.append(coin_total)
		data_array.append(flags)
		var json_string = JSON.stringify(data_array)
		file.store_line(json_string)
		file.close()

	if FileAccess.file_exists(SAVE_DATA):
		get_all_songs()
		var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var save_data = json.get_data()
		file.close()
		var og_songs: Array
		var all_songs: Array


		for i in flags:
			if !save_data[5].has(i):
				save_data[5][i] = flags[i]


		var full_path = "res://assets/weeks/freeplay_list_unlocks.json"
		if FileAccess.file_exists(full_path):
			var shop_file = FileAccess.open(full_path, FileAccess.READ)

			var shop_json_string = shop_file.get_as_text()
			var shop_json = JSON.new()
			var shop_parse_result = shop_json.parse(shop_json_string)
			var shop_data = shop_json.get_data()
			for i in shop_data["songs"].size():
				var unlocked_name: String = shop_data["songs"][i].get("name") + "_song_unlocked"
				if !save_data[5].has(unlocked_name):
					save_data[5][unlocked_name] = false
				var purchased_name: String = shop_data["songs"][i].get("name") + "_purchased"
				if !save_data[5].has(purchased_name):
					save_data[5][purchased_name] = false

		var n: int = 0

		for songs in save_data[0].size():
			var og_data_string = str(save_data[0].keys()[n])
			var string
			for difficulty in diff:
				string = "-" + str(difficulty)
				og_data_string = og_data_string.replace(string, "")
			og_songs.append(og_data_string)
			n += 1


		for songs in song_list:
			var string
			for difficulty in diff:
				string = "-" + str(difficulty)
				songs = songs.replace(string, "")
			all_songs.append(songs)

		for t in all_songs.size():
			if og_songs.find(all_songs[t]) == -1:
				for difficulty in diff:
					var new_song = all_songs[t] + "-" + str(difficulty)
					save_data[0][new_song] = 0
					save_data[1][new_song] = 0
					save_data[2][new_song] = 0
					save_data[3][new_song] = 0

		var file2 = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
		var json_string_2 = JSON.stringify(save_data)
		file2.store_line(json_string_2)
		file2.close()

func load_misses():
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	if FileAccess.file_exists(SAVE_DATA):
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var save_data = json.get_data()
			return save_data[0]

func load_rating():
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	if FileAccess.file_exists(SAVE_DATA):
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var save_data = json.get_data()
			return save_data[1]

func load_scores():
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	if FileAccess.file_exists(SAVE_DATA):
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var save_data = json.get_data()
			return save_data[2]

func load_combats():
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	if FileAccess.file_exists(SAVE_DATA):
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var save_data = json.get_data()
			return save_data[3]

func load_coin_total():
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	if FileAccess.file_exists(SAVE_DATA):
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var save_data = json.get_data()
			return save_data[4]

func load_flags():
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	if FileAccess.file_exists(SAVE_DATA):
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var save_data = json.get_data()
			return save_data[5]

func save_misses(song_name, new_misses):
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	var cur_save_data
	if FileAccess.file_exists(SAVE_DATA):
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		cur_save_data = json.get_data()
		file.close()

	cur_save_data[0][song_name + "-" + Main.difficulty.to_lower()] = new_misses
	var file2 = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
	var json_string = JSON.stringify(cur_save_data)
	file2.store_line(json_string)
	file2.close()

func save_rating(song_name, new_rating):
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	var cur_save_data
	if FileAccess.file_exists(SAVE_DATA):
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		cur_save_data = json.get_data()
		file.close()

	cur_save_data[1][song_name + "-" + Main.difficulty.to_lower()] = new_rating
	var file2 = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
	var json_string = JSON.stringify(cur_save_data)
	file2.store_line(json_string)
	file2.close()

func save_score(song_name, new_score):
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	var cur_save_data
	if FileAccess.file_exists(SAVE_DATA):
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		cur_save_data = json.get_data()
		file.close()

	cur_save_data[2][song_name + "-" + Main.difficulty.to_lower()] = new_score
	var file2 = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
	var json_string = JSON.stringify(cur_save_data)
	file2.store_line(json_string)
	file2.close()

func save_combat(song_name, new_combat):
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	var cur_save_data
	if FileAccess.file_exists(SAVE_DATA):
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		cur_save_data = json.get_data()
		file.close()

	cur_save_data[3][song_name + "-" + Main.difficulty.to_lower()] = new_combat
	var file2 = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
	var json_string = JSON.stringify(cur_save_data)
	file2.store_line(json_string)
	file2.close()

func add_coin_total(amount):
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	var cur_save_data
	if FileAccess.file_exists(SAVE_DATA):
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		cur_save_data = json.get_data()
		file.close()

	cur_save_data[4] = cur_save_data[4] + amount
	var file2 = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
	var json_string = JSON.stringify(cur_save_data)
	file2.store_line(json_string)
	file2.close()

func save_flag(flag_name, bool):
	var file = FileAccess.open(SAVE_DATA, FileAccess.READ)
	var cur_save_data
	if FileAccess.file_exists(SAVE_DATA):
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		cur_save_data = json.get_data()
		file.close()

	cur_save_data[5][flag_name] = bool
	var file2 = FileAccess.open(SAVE_DATA, FileAccess.WRITE)
	var json_string = JSON.stringify(cur_save_data)
	file2.store_line(json_string)
	file2.close()

func get_all_songs():
	for week in Weeks.week_list:
		for song in week.songs:
			song_list.append(song.get("name") + "-" + diff[0])
			song_list.append(song.get("name") + "-" + diff[1])
			song_list.append(song.get("name") + "-" + diff[2])
	var dir = DirAccess.open("res://assets/songs/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if !song_list.has(file_name):
					song_list.append(file_name + "-" + diff[0])
					song_list.append(file_name + "-" + diff[1])
					song_list.append(file_name + "-" + diff[2])
			file_name = dir.get_next()
