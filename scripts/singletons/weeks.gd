extends Node

var week_list = []
var freeplay_json
var unlocks_json

var weekFolder = "res://assets/weeks/week1.json"
var week_path = "res://assets/weeks/"
var freeplay_path = "res://assets/weeks/freeplay_list_weeks.json"
var unlocks_path = "res://assets/weeks/freeplay_list_unlocks.json"

func _ready():
	freeplay_json = load_json_file(freeplay_path)
	unlocks_json = load_json_file(unlocks_path)
	week_list.append(freeplay_json)
	week_list.append(unlocks_json)

func load_json_file(filePath: String):
	if ResourceLoader.exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading file")
	else:
		print("File doesn't exsist")
