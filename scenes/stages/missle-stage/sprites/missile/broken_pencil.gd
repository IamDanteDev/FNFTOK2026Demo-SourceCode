extends Sprite2D

var velocity = Vector2(20, -30)
var gravity = 0.6

func _ready() -> void :
	pass

func _physics_process(delta: float) -> void :
	position += velocity
	velocity.y += gravity
