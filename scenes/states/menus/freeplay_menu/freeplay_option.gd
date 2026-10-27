extends MarginContainer

@export_category("Nodes")
@export var title: Label
@export var sprite: AnimatedSprite2D
@export var ribbon: AnimatedSprite2D
@export var anim: AnimationPlayer
@export var icon: TextureRect
@export_category("Values")
@export var min_y: float
@export var min_x: float
@export var max_y: float
@export var score: Label
@export var accuracy: Label
@export var combat: HBoxContainer
@export var total_completion: Label

var chart: ChartData
var map_value: int = 0
var selected: bool = false

var bg_sprite: Texture

func _process(delta):
	var target_min
	var target_y
	var target_scale

	if selected:
		target_min = max_y
		target_y = 8.0
		target_scale = Vector2.ONE

	else:
		target_min = min_y
		target_y = 110.0
		target_scale = Vector2.ONE * 0.95


	var speed = delta * 15
	custom_minimum_size.y = lerp(custom_minimum_size.y, target_min, speed)
	sprite.position.y = lerp(sprite.position.y, target_y, speed)
	sprite.scale = lerp(sprite.scale, target_scale, speed)
