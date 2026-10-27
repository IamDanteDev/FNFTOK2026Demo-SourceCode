extends AnimatedSprite2D

var speed = 6
var delay = 0


var frequency = 2
var amplitude = 1
var time = 0

func _ready():

	play("float")

	frequency *= speed
	amplitude += (speed) / 2

func _physics_process(delta):
	delay -= 1
	if delay <= 0:

		time += delta
		var movement = cos(time * frequency) * amplitude
		position.y += movement
		var rot = cos((time * frequency) - (frequency)) * amplitude / 200
		rotation += rot
		position.x += speed

	if position.x >= 750:
		queue_free()
