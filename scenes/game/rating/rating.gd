extends Node2D


const COMBO_NUMBER_SPRITE = preload("res://scenes/game/rating/rating_numbers-tok.png")



const GRAVITY = 0



var rating_frames: Dictionary = {
	"sick": 0, 
	"good": 1, 
	"bad": 2, 
	"shit": 3, 
	"miss": 4, 
}



var rating: String


var combo: int



var velocity: Vector2

var _combo_numbers = []


@onready var _tween = create_tween().set_parallel(true)

@onready var _sprite = $Sprite
@onready var _numbers = $Numbers


func _ready():
	var combo_settings = Settings.load_combos()
	var rating_offset = combo_settings.get("rating_offset")
	var numbers_offset = combo_settings.get("numbers_offset")

	_sprite.position.x += rating_offset[0]
	_sprite.position.y += rating_offset[1]

	_numbers.position.x += numbers_offset[0]
	_numbers.position.y += numbers_offset[1]


	_sprite.frame = rating_frames.get(rating, 0)


	velocity.y -= randi_range(140, 175)
	velocity.x -= randi_range(0, 10)

	_sprite.rotation_degrees = randf_range(-5, 5)


	_tween.tween_property(_sprite, "scale", Vector2(0.3, 0.3), 0.2).from(Vector2(0.35, 0.35)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(_sprite, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)


	if combo >= 10:
		_create_combo_numbers()


	_tween.finished.connect(queue_free)

func _process(delta):



	for combo_number in _combo_numbers:
		var c_sprite = combo_number[0]
		var c_gravity = combo_number[1]
		var c_velocity = combo_number[2]




		combo_number[2] = c_velocity


func _create_combo_numbers(miss = false):
	var score_string = "%03d" % combo

	for i in len(score_string):
		var character = score_string[ - i - 1]
		_create_score_number(i, character, miss)

func _create_score_number(pos, character, miss = false):
	var sprite = Sprite2D.new()

	sprite.texture = COMBO_NUMBER_SPRITE
	sprite.hframes = 10
	sprite.frame = int(character)

	sprite.position = Vector2(-50, 100)
	sprite.position.x -= (65 * pos)
	sprite.scale = Vector2(0.325, 0.325)

	sprite.rotation_degrees = randf_range(-10, 10)


	_numbers.add_child(sprite)

	_tween.tween_property(sprite, "scale", Vector2(0.275, 0.275), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(sprite, "modulate:v", 1, 0.5).from(1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	_tween.tween_property(sprite, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)

	var c_gravity = randi_range(200, 300)
	var c_velocity = Vector2(
		randf_range(-5, 5), - randi_range(140, 160)
	)

	var array = [sprite, c_gravity, c_velocity]
	_combo_numbers.append(array)

func on_miss():
	_create_combo_numbers(true)
