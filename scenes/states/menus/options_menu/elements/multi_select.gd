extends Label

var current
var section: String = "visuals"
var key: String = "Time Bar"

func _ready():
	current = Settings.config.get_value(section, key)


func _process(delta):
	if Settings.config.get_value(section, key) != current:
		text = "<" + Settings.config.get_value(section, key).capitalize() + ">"

		current = Settings.config.get_value(section, key, false)
