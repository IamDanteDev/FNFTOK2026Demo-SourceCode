extends AnimatedSprite2D

var current: bool
var section: String = "gameplay"
var key: String = "downscroll"

func _ready():
	current = Settings.config.get_value(section, key)
	play(str(current))
	frame = 4


func _process(delta):
	if Settings.config.get_value(section, key, false) != current:
		play(str(Settings.config.get_value(section, key, false)))
		current = Settings.config.get_value(section, key, false)
