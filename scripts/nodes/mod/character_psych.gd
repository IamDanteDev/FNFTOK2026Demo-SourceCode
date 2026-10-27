class_name CharacterPsych
extends Character


@export_file("*.json") var psych_character: String

@export_file("*.xml") var xml_file: String


var json_data: Dictionary

var loaded: bool = false


func _ready():
	if not loaded:
		load_character()

	_setup_sprite()
	_setup_psych_character()

	super ()

func load_character():
	_load_psych_json()

	loaded = true


func _setup_sprite():
	var image_path = json_data.get("image")
	if image_path != null:
		var character_folder = _get_character_folder()
		image_path = character_folder + "/" + image_path.trim_prefix("characters/")

		xml_file = image_path + ".xml"

	sprite = XMLSprite.new()
	sprite.xml_file = xml_file
	add_child(sprite)

	animation_player = sprite.animation_player

func _setup_psych_character():
	sing_animations = ["singLEFT", "singDOWN", "singUP", "singRIGHT"]
	miss_suffix = "miss"

	_load_psych_animations()
	_load_psych_other()

	_on_beat(0)


func _load_psych_json():
	var _file = FileAccess.open(psych_character, FileAccess.READ)

	if _file != null:
		json_data = JSON.parse_string(_file.get_as_text())

func _load_psych_animations():
	if json_data.is_empty():
		return

	var animations = json_data.get("animations", [])
	for animation in animations:
		var pose_name = animation.get("anim", "")
		var anim_name = animation.get("name", "")

		if pose_name == "" or anim_name == "":
			continue

		var offsets = animation.get("offsets", [0, 0])
		var indices = animation.get("indices", [])

		var loop = animation.get("loop", false)
		var fps = animation.get("fps", 24)

		sprite.add_by_prefix(pose_name, anim_name, - Vector2(offsets[0], offsets[1]), fps, loop, indices)


func _load_psych_other():



	if json_data.get("no_antialiasing", false):
		sprite.texture_filter = TEXTURE_FILTER_NEAREST



	var character_folder = _get_character_folder()
	icon = load(character_folder + "/icon-" + json_data.get("healthicon", "") + ".png")



	var healthbar_colors = json_data.get("healthbar_colors", null)
	if healthbar_colors != null:
		healthbar_color = Color(
			healthbar_colors[0] / 255, 
			healthbar_colors[1] / 255, 
			healthbar_colors[2] / 255)



	sprite.scale = Vector2.ONE * json_data.get("scale", null)



	if json_data.get("flip_x", false):
		flip_x = not flip_x

	if flip_x:
		sprite.scale.x = - sprite.scale.x



	sprite.position.x -= sprite.get_sprite_size("idle").x * json_data.get("scale", null) / 2
	sprite.position.x *= sign(sprite.scale.x)

	sprite.position.y -= sprite.get_sprite_size("idle").y * json_data.get("scale", null)



	var json_position_offset = json_data.get("fbn_position_offset", [0, 0])
	var multi_x = -1
	if flip_x:
		multi_x = 1

	sprite.position += Vector2(json_position_offset[0] * multi_x, json_position_offset[1])

	var json_camera_offset = json_data.get("camera_position", [camera_offset.x, camera_offset.y])
	camera_offset = Vector2(json_camera_offset[0], json_camera_offset[1])




func _get_character_folder():
	return psych_character.rsplit("/", true, 1)[0]
