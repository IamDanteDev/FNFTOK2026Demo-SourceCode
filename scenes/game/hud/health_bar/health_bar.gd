extends Node2D

@onready var sprite = $hb

var health_cap: float = 1

var health: float = 1:
	set = _set_health

func _ready():
	Conductor.beat_changed.connect(_on_beat_changed)

func _process(delta):
	var _progress_bar: = $ProgressBar

	var speed = 5
	for i in $Icons.get_children():
		i.scale = lerp(i.scale, Vector2(0.275, 0.275), delta * speed)


func update_from_character(character: Character, player: bool = false):
	var icon: Sprite2D = $Icons / EnemyIcon
	var icon_s: Sprite2D = $Icons / EnemyIcon / EnemyIconS
	if player:
		icon = $Icons / PlayerIcon
		icon_s = $Icons / PlayerIcon / PlayerIconS
		$ProgressBar.tint_progress = character.healthbar_color
	else:
		$ProgressBar.tint_under = character.healthbar_color

	icon.texture = character.icon
	icon_s.texture = character.icon
	icon.hframes = character.icon_count
	icon_s.hframes = character.icon_count






func _on_beat_changed(_beat):
	for i in $Icons.get_children():
		i.scale = Vector2.ONE * 0.325

func set_holepunch(state = true):
	if state:
		health_cap = 0.5
		sprite.frame = 3
		$ProgressBar / HurtBar.value = 50
		_set_health(clampf(health, 0, health_cap))
		$Icons / PlayerIcon.frame = 1
		$Icons / EnemyIcon.frame = 2
	else:
		health_cap = 1
		sprite.frame = 2
		$ProgressBar / HurtBar.value = 0

func _set_health(value):

	$ProgressBar / HurtBar.value = 100 - (health_cap * 100)
	health = clampf(value, 0, health_cap)

	$ProgressBar.value = health * 100



	if health < 0.4:
		$Icons / PlayerIcon.frame = 1
		$Icons / EnemyIcon.frame = 2
	elif health > 0.8:
		$Icons / PlayerIcon.frame = 2
		$Icons / EnemyIcon.frame = 1
	else:
		$Icons / PlayerIcon.frame = 0
		$Icons / EnemyIcon.frame = 0

	$Icons / PlayerIcon / PlayerIconS.frame = $Icons / PlayerIcon.frame
	$Icons / EnemyIcon / EnemyIconS.frame = $Icons / EnemyIcon.frame
