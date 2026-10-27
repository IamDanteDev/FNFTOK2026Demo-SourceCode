extends RichTextLabel


var sep = " | "
var prefix_sep = ""
var suffix_sep = ""


func _ready():
	update_info({
		"N/A": ""
	})


func update_info(info: Dictionary):
	var string: String = ""
	string += "[center]"

	string += "[color=tan]"
	string += prefix_sep
	string += "[/color]"

	var i = 0
	for item in info:
		if item == "X":
			string += "[color=red]"
			string += item
			string += "[/color]"
		else:
			string += "[color=yellow]"
			string += item + ": "
			string += "[/color]"

		var value = str(info[item])
		if value != "":
			string += value

		var cur_sep = sep
		if i == len(info) - 1:
			cur_sep = suffix_sep

		string += "[color=tan]"
		string += cur_sep
		string += "[/color]"

		i += 1

	text = string


func get_accuracy(accuracy, misses):
	var nan_accuracy = false
	if is_nan(accuracy):
		nan_accuracy = true
		accuracy = 1

	var accuracy_string = "%0.2f%%" % (accuracy * 100)

	if misses > 0 or nan_accuracy:
		return accuracy_string
	else:
		var fc_string = "FC"
		if accuracy == 1:
			fc_string = "SFC"

		return accuracy_string


func get_rating(accuracy: float):
	var rating = "N/A"
	var rating_array = {"S": 100, "A": 90, "B": 80, "C": 70}

	var acc = null

	if not is_nan(accuracy):
		acc = accuracy * 100

		for cur_rating in rating_array.keys():
			if (acc >= rating_array[cur_rating]):
				rating = cur_rating
				break

	return rating
