class_name XMLSprite
extends Sprite2D








@export_file("*.xml") var xml_file: String


var animation_player: = AnimationPlayer.new()

var xml_data: Array


func _ready():
	_setup_anim_player()
	add_sparrow_atlas()



func add_sparrow_atlas(path = xml_file):
	xml_file = path
	_setup_xml_data(path)

	var image_path = _get_image_path()
	texture = load(image_path)

	hframes = 1
	vframes = 1
	frame = 0

	region_enabled = true
	centered = false



func add_by_prefix(anim_name, xml_name, anim_offset = Vector2.ZERO, fps = 24, loops = false, indices = []):
	var anim = Animation.new()


	var region_track = anim.add_track(Animation.TYPE_VALUE)
	anim.value_track_set_update_mode(region_track, Animation.UPDATE_DISCRETE)
	anim.track_set_path(region_track, name + ":region_rect")


	var offset_track = anim.add_track(Animation.TYPE_VALUE)
	anim.value_track_set_update_mode(offset_track, Animation.UPDATE_DISCRETE)
	anim.track_set_path(offset_track, name + ":offset")


	var frame_time = 0.0
	for frame_data in xml_data:
		var frame_name = frame_data.get("name", "")
		if not frame_name.begins_with(xml_name):
			continue

		var frame_number = float(frame_name.right(4))
		if not indices.is_empty() and not indices.has(frame_number):
			continue

		var frame_position = Vector2(float(frame_data.get("x", "0")), float(frame_data.get("y", "0")))
		var frame_size = Vector2(float(frame_data.get("width", "0")), float(frame_data.get("height", "0")))
		var frame_fposition = Vector2(float(frame_data.get("frameX", "0")), float(frame_data.get("frameY", "0")))

		anim.track_insert_key(region_track, frame_time, Rect2(frame_position, frame_size))
		anim.track_insert_key(offset_track, frame_time, - frame_fposition + anim_offset)
		frame_time += 1.0 / float(fps)


	if loops:
		anim.loop_mode = Animation.LOOP_LINEAR
	else:
		anim.loop_mode = Animation.LOOP_NONE

	anim.length = frame_time

	var library = animation_player.get_animation_library("")
	library.add_animation(anim_name, anim)


func play(anim_name):
	animation_player.play(anim_name)


func get_sprite_size(main_anim: String = ""):
	var sprite_size

	if main_anim == "" or not animation_player.has_animation(main_anim):
		for anim_name in animation_player.get_animation_list():
			var anim = animation_player.get_animation(anim_name)
			var region = anim.track_get_key_value(0, 0)

			if region == null:
				continue

			var this_size = region.size
			if sprite_size == null or this_size < sprite_size:
				sprite_size = this_size
	else:
		var anim = animation_player.get_animation(main_anim)
		var region = anim.track_get_key_value(0, 0)

		if region != null:
			sprite_size = region.size

	if sprite_size == null:
		sprite_size = Vector2.ZERO

	return sprite_size



func _setup_anim_player():
	var library = AnimationLibrary.new()
	animation_player.add_animation_library("", library)

	animation_player.root_node = "../../"

	add_child(animation_player)


func _setup_xml_data(path = xml_file):
	xml_file = path
	var parser = XMLParser.new()

	if not FileAccess.file_exists(path):
		return

	var open_error = parser.open(path)
	if open_error != OK:
		return

	var cur_xml_data: = []
	while parser.read() != ERR_FILE_EOF:
		if parser.get_attribute_count() > 0:
			var attribute_data: = {}
			for i in range(parser.get_attribute_count()):
				attribute_data[parser.get_attribute_name(i)] = parser.get_attribute_value(i)

			if not attribute_data in cur_xml_data:
				cur_xml_data.append(attribute_data)

	xml_data = cur_xml_data


func _get_image_path():
	var path = xml_file.trim_suffix(".xml") + ".png"
	if xml_data.is_empty():
		return path

	for data in xml_data:
		var image_path = data.get("imagePath", null)
		if image_path != null:
			path = path.rsplit("/", true, 1)[0]
			return path + "/" + image_path

	return path
