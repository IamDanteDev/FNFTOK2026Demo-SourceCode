extends CanvasLayer

var sfx_up = preload("res://assets/sounds/soundtray/Volup.ogg")
var sfx_max = preload("res://assets/sounds/soundtray/VolMAX.ogg")
var sfx_down = preload("res://assets/sounds/soundtray/Voldown.ogg")

var level: int = 0

@onready var sprite = $MarginContainer / Control / Volumebox


func _ready():
	$MarginContainer.visible = false

	Settings.config.load(Settings.SETTINGS_FILE_PATH)
	await get_tree().create_timer(0.05).timeout
	level = Settings.config.get_value("sound", "sound_level")

	update_volume(0)



func _process(_delta):
	pass

func update_volume(value):

	if value != 0:
		appear()

	level += value
	level = clamp(level, 0, 10)
	$MarginContainer / Control / Volumebox / Bars.frame = level

	Settings.config.set_value("sound", "sound_level", level)
	Settings.config.save(Settings.SETTINGS_FILE_PATH)

	var volume
	match level:
		0:
			volume = - INF
		1:
			volume = -30
		2:
			volume = -25
		3:
			volume = -21
		4:
			volume = -18
		5:
			volume = -15
		6:
			volume = -12
		7:
			volume = -9
		8:
			volume = -6
		9:
			volume = -3
		10:
			volume = 0

	AudioServer.set_bus_volume_db(0, volume)


	var stream
	if value != 0:
		if level + value != 11:
			if value > 0:
				stream = sfx_up
			else:
				stream = sfx_down
		else:
			stream = sfx_max

		$sfx.stream = stream
		$sfx.play()

	if value != 0:
		$Timer.start(1)

func appear():
	$MarginContainer.visible = true
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "position", Vector2(0, 180), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.parallel().tween_property(sprite, "modulate", Color8(255, 255, 255, 255), 0.3)

func disappear():
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "position", Vector2(0, 50), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.parallel().tween_property(sprite, "modulate", Color8(255, 255, 255, 0), 0.3)
	await tween.finished
	$MarginContainer.visible = false

func _on_timer_timeout():
	disappear()
