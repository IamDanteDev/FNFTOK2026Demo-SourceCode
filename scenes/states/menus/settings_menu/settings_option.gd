extends Control

var description = ""
var type = ""
var key = ""

@onready var title = $title
@onready var status = $status

func update_status(amt):
	match type:
		"bool":
			if key == "anti_aliasing":
				update_bool(amt)

func update_bool(amt):
	get_child(1).text = str(Settings)
