extends Node2D

@onready var coin = $Coin
@onready var shine = $Shine

var speed_y = 0
var gravity = 2

var bounced = false
var played = false

var target_y = 0

var results_scene

func _ready():
	coin.visible = true
	shine.visible = false
	position.x = randf_range(-700, 700)
	target_y = randf_range(-100, 50)
	if target_y < -20:
		show_behind_parent = true

func _physics_process(delta):

	speed_y += gravity
	position.y += speed_y

	if !bounced:
		if position.y >= target_y:
			speed_y = randf_range(-30, -40)
			bounced = true
	else:
		if speed_y >= 0:
			kill()

func kill():
	gravity = 0
	speed_y = 0
	coin.visible = false
	shine.visible = true
	shine.play("0")

	if results_scene:
		if !played:
			results_scene.play_coin_sfx()
			played = true
		await shine.animation_finished
	queue_free()
